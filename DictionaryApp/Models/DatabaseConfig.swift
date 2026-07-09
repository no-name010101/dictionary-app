//
//  DatabaseConfig.swift
//  词典
//
//  数据库配置和词库元信息
//

import Foundation

struct DatabaseConfig {
    // ECDICT 词库信息
    static let ecdictInfo = DictionaryInfo(
        name: "ECDICT 英汉词典",
        version: "1.0.0",
        source: "https://github.com/skywind3000/ECDICT",
        description: "开源英汉词典，含 77 万词条",
        entryCount: 770_000,
        fileName: "ecdict.db",
        fileSize: "约 60MB (SQLite)",
        format: .sqlite
    )
    
    // 成语词典信息
    static let idiomInfo = DictionaryInfo(
        name: "成语词典",
        version: "1.0.0",
        source: "内置词库",
        description: "常用成语 5 万条",
        entryCount: 50_000,
        fileName: "idiom.db",
        fileSize: "约 8MB (SQLite)",
        format: .sqlite
    )
    
    // 新华字典信息
    static let xinhuaInfo = DictionaryInfo(
        name: "新华字典",
        version: "1.0.0",
        source: "内置词库",
        description: "常用汉字 2 万字",
        entryCount: 20_000,
        fileName: "xinhua.db",
        fileSize: "约 3MB (SQLite)",
        format: .sqlite
    )
    
    // 所有词库
    static let allDictionaries = [ecdictInfo, idiomInfo, xinhuaInfo]
}

struct DictionaryInfo: Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let source: String
    let description: String
    let entryCount: Int
    let fileName: String
    let fileSize: String
    let format: DatabaseFormat
    
    enum DatabaseFormat: String {
        case sqlite = "SQLite"
        case csv = "CSV"
        case json = "JSON"
    }
}

// ECDICT SQLite 表结构
/*
 CREATE TABLE IF NOT EXISTS stardict (
     id INTEGER PRIMARY KEY,
     word TEXT NOT NULL UNIQUE,
     sw TEXT NOT NULL,
     phonetic TEXT,
     definition TEXT,
     translation TEXT,
     pos TEXT,
     collins INTEGER,
     oxford INTEGER,
     tag TEXT,
     bnc INTEGER,
     frq INTEGER,
     exchange TEXT,
     detail TEXT,
     audio TEXT
 );
 
 CREATE INDEX idx_word ON stardict(word);
 CREATE INDEX idx_sw ON stardict(sw);
 CREATE INDEX idx_collins ON stardict(collins);
 CREATE INDEX idx_oxford ON stardict(oxford);
 CREATE INDEX idx_tag ON stardict(tag);
 */
