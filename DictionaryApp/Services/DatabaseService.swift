//
//  DatabaseService.swift
//  词典
//
//  离线词库服务 - SQLite 数据库管理
//  支持 ECDICT 英汉词典 + 成语词典 + 新华字典
//

import Foundation
import SQLite3

@MainActor
class DatabaseService: ObservableObject {
    @Published var isDatabaseReady: Bool = false
    @Published var databaseStatus: DatabaseStatus = .notLoaded
    @Published var totalEntries: Int = 0
    
    private var db: OpaquePointer?
    private var ecdictDB: OpaquePointer?
    private var idiomDB: OpaquePointer?
    private var xinhuaDB: OpaquePointer?
    
    enum DatabaseStatus {
        case notLoaded
        case loading
        case ready
        case error(String)
    }
    
    // MARK: - 初始化数据库
    func initializeDatabase() async {
        await MainActor.run { databaseStatus = .loading }
        
        // 检查并复制内置词库
        copyBundledDatabasesIfNeeded()
        
        // 打开数据库连接
        let ecdictPath = databasePath(for: "ecdict.db")
        let idiomPath = databasePath(for: "idiom.db")
        let xinhuaPath = databasePath(for: "xinhua.db")
        
        if sqlite3_open(ecdictPath, &ecdictDB) == SQLITE_OK {
            print("✅ ECDICT 数据库已打开")
        }
        if sqlite3_open(idiomPath, &idiomDB) == SQLITE_OK {
            print("✅ 成语词典数据库已打开")
        }
        if sqlite3_open(xinhuaPath, &xinhuaDB) == SQLITE_OK {
            print("✅ 新华字典数据库已打开")
        }
        
        // 统计词条数
        totalEntries = countEntries()
        
        await MainActor.run {
            isDatabaseReady = true
            databaseStatus = .ready
        }
    }
    
    // MARK: - 搜索单词（英→中）
    func searchWord(_ query: String, limit: Int = 50) -> [WordEntry] {
        guard let db = ecdictDB else { return [] }
        var results: [WordEntry] = []
        
        let sql = """
        SELECT word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
        FROM stardict
        WHERE word LIKE ? OR sw LIKE ?
        ORDER BY
            CASE WHEN word = ? THEN 0
                 WHEN word LIKE ? THEN 1
                 ELSE 2
            END,
            length(word),
            word
        LIMIT ?
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        
        let queryString = query.lowercased()
        let prefixQuery = queryString + "%"
        
        sqlite3_bind_text(stmt, 1, (prefixQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (prefixQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (queryString as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (prefixQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 5, Int32(limit))
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let entry = WordEntry(
                word: String(cString: sqlite3_column_text(stmt, 0)),
                phonetic: columnString(stmt, 1),
                definition: columnString(stmt, 2),
                translation: columnString(stmt, 3),
                pos: columnString(stmt, 4),
                collins: columnInt(stmt, 5),
                oxford: columnInt(stmt, 6) == 1,
                tag: columnString(stmt, 7),
                bnc: columnInt(stmt, 8),
                frq: columnInt(stmt, 9),
                exchange: columnString(stmt, 10),
                detail: columnString(stmt, 11),
                audio: columnString(stmt, 12)
            )
            results.append(entry)
        }
        
        return results
    }
    
    // MARK: - 精确查询单词
    func lookupWord(_ word: String) -> WordEntry? {
        guard let db = ecdictDB else { return nil }
        
        let sql = """
        SELECT word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
        FROM stardict WHERE word = ? LIMIT 1
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        
        sqlite3_bind_text(stmt, 1, (word as NSString).utf8String, -1, nil)
        
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        
        return WordEntry(
            word: String(cString: sqlite3_column_text(stmt, 0)),
            phonetic: columnString(stmt, 1),
            definition: columnString(stmt, 2),
            translation: columnString(stmt, 3),
            pos: columnString(stmt, 4),
            collins: columnInt(stmt, 5),
            oxford: columnInt(stmt, 6) == 1,
            tag: columnString(stmt, 7),
            bnc: columnInt(stmt, 8),
            frq: columnInt(stmt, 9),
            exchange: columnString(stmt, 10),
            detail: columnString(stmt, 11),
            audio: columnString(stmt, 12)
        )
    }
    
    // MARK: - 汉英查询（中文→英文）
    func searchByChinese(_ query: String, limit: Int = 30) -> [WordEntry] {
        guard let db = ecdictDB else { return [] }
        var results: [WordEntry] = []
        
        let sql = """
        SELECT word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
        FROM stardict
        WHERE translation LIKE ?
        ORDER BY collins DESC, frq ASC
        LIMIT ?
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        
        let likeQuery = "%" + query + "%"
        sqlite3_bind_text(stmt, 1, (likeQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(limit))
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let entry = WordEntry(
                word: String(cString: sqlite3_column_text(stmt, 0)),
                phonetic: columnString(stmt, 1),
                definition: columnString(stmt, 2),
                translation: columnString(stmt, 3),
                pos: columnString(stmt, 4),
                collins: columnInt(stmt, 5),
                oxford: columnInt(stmt, 6) == 1,
                tag: columnString(stmt, 7),
                bnc: columnInt(stmt, 8),
                frq: columnInt(stmt, 9),
                exchange: columnString(stmt, 10),
                detail: columnString(stmt, 11),
                audio: columnString(stmt, 12)
            )
            results.append(entry)
        }
        
        return results
    }
    
    // MARK: - 成语搜索
    func searchIdiom(_ query: String, limit: Int = 30) -> [IdiomEntry] {
        guard let db = idiomDB else { return [] }
        var results: [IdiomEntry] = []
        
        let sql = """
        SELECT word, pinyin, definition, origin, example
        FROM idiom WHERE word LIKE ? OR definition LIKE ?
        LIMIT ?
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        
        let likeQuery = "%" + query + "%"
        sqlite3_bind_text(stmt, 1, (likeQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (likeQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 3, Int32(limit))
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(IdiomEntry(
                word: String(cString: sqlite3_column_text(stmt, 0)),
                pinyin: columnString(stmt, 1),
                definition: columnString(stmt, 2),
                origin: columnString(stmt, 3),
                example: columnString(stmt, 4)
            ))
        }
        
        return results
    }
    
    // MARK: - 汉字搜索（新华字典）
    func searchCharacter(_ query: String) -> [CharacterEntry] {
        guard let db = xinhuaDB else { return [] }
        var results: [CharacterEntry] = []
        
        let sql = """
        SELECT character, pinyin, radical, strokes, definition, variants
        FROM xinhua WHERE character = ? OR pinyin LIKE ?
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        
        sqlite3_bind_text(stmt, 1, (query as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, ("\(query)%" as NSString).utf8String, -1, nil)
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(CharacterEntry(
                character: String(cString: sqlite3_column_text(stmt, 0)),
                pinyin: columnString(stmt, 1),
                radical: columnString(stmt, 2),
                strokes: columnInt(stmt, 3),
                definition: columnString(stmt, 4),
                variants: columnString(stmt, 5)
            ))
        }
        
        return results
    }
    
    // MARK: - 每日一词（随机推荐）
    func randomWord() -> WordEntry? {
        guard let db = ecdictDB else { return nil }
        
        let sql = """
        SELECT word, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio
        FROM stardict
        WHERE collins >= 3 AND translation IS NOT NULL
        ORDER BY RANDOM() LIMIT 1
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        
        return WordEntry(
            word: String(cString: sqlite3_column_text(stmt, 0)),
            phonetic: columnString(stmt, 1),
            definition: columnString(stmt, 2),
            translation: columnString(stmt, 3),
            pos: columnString(stmt, 4),
            collins: columnInt(stmt, 5),
            oxford: columnInt(stmt, 6) == 1,
            tag: columnString(stmt, 7),
            bnc: columnInt(stmt, 8),
            frq: columnInt(stmt, 9),
            exchange: columnString(stmt, 10),
            detail: columnString(stmt, 11),
            audio: columnString(stmt, 12)
        )
    }
    
    // MARK: - 模糊搜索建议
    func searchSuggestions(_ query: String, limit: Int = 10) -> [String] {
        guard let db = ecdictDB, !query.isEmpty else { return [] }
        
        let sql = "SELECT word FROM stardict WHERE sw LIKE ? ORDER BY length(word), word LIMIT ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        
        let likeQuery = query.lowercased() + "%"
        sqlite3_bind_text(stmt, 1, (likeQuery as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(limit))
        
        var suggestions: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            suggestions.append(String(cString: sqlite3_column_text(stmt, 0)))
        }
        return suggestions
    }
    
    // MARK: - 辅助方法
    private func databasePath(for fileName: String) -> String {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDir.appendingPathComponent(fileName).path
    }
    
    private func copyBundledDatabasesIfNeeded() {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for dbFile in ["ecdict.db", "idiom.db", "xinhua.db"] {
            let destPath = documentsDir.appendingPathComponent(dbFile)
            if !fileManager.fileExists(atPath: destPath.path) {
                if let bundlePath = Bundle.main.path(forResource: dbFile.replacingOccurrences(of: ".db", with: ""), ofType: "db") {
                    try? fileManager.copyItem(atPath: bundlePath, toPath: destPath.path)
                }
            }
        }
    }
    
    private func countEntries() -> Int {
        guard let db = ecdictDB else { return 0 }
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM stardict", -1, &stmt, nil) == SQLITE_OK else { return 0 }
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }
    
    private func columnString(_ stmt: OpaquePointer?, _ index: Int32) -> String? {
        guard let cString = sqlite3_column_text(stmt, index) else { return nil }
        let string = String(cString: cString)
        return string.isEmpty ? nil : string
    }
    
    private func columnInt(_ stmt: OpaquePointer?, _ index: Int32) -> Int? {
        let val = sqlite3_column_int(stmt, index)
        return val == 0 ? nil : Int(val)
    }
    
    deinit {
        sqlite3_close(ecdictDB)
        sqlite3_close(idiomDB)
        sqlite3_close(xinhuaDB)
    }
}
