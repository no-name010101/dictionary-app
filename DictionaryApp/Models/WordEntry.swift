//
//  WordEntry.swift
//  词典
//
//  词库数据模型 - 对应 ECDICT 数据库结构
//

import Foundation

// MARK: - 单词词条
struct WordEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let word: String
    let phonetic: String?        // 音标
    let definition: String?      // 英文释义
    let translation: String?     // 中文翻译
    let pos: String?             // 词性 (noun, verb, adj...)
    let collins: Int?            // 柯林斯星级 (1-5)
    let oxford: Bool?            // 是否牛津3000核心词
    let tag: String?             // 考试标签 (zk/gk/cet4/cet6/ielts/toefl/gre)
    let bnc: Int?                // BNC 词频排名
    let frq: Int?                // 当代语料库词频排名
    let exchange: String?        // 词形变换 (时态/复数/比较级...)
    let detail: String?          // 详细释义
    let audio: String?           // 发音音频路径
    
    init(
        id: UUID = UUID(),
        word: String,
        phonetic: String? = nil,
        definition: String? = nil,
        translation: String? = nil,
        pos: String? = nil,
        collins: Int? = nil,
        oxford: Bool? = nil,
        tag: String? = nil,
        bnc: Int? = nil,
        frq: Int? = nil,
        exchange: String? = nil,
        detail: String? = nil,
        audio: String? = nil
    ) {
        self.id = id
        self.word = word
        self.phonetic = phonetic
        self.definition = definition
        self.translation = translation
        self.pos = pos
        self.collins = collins
        self.oxford = oxford
        self.tag = tag
        self.bnc = bnc
        self.frq = frq
        self.exchange = exchange
        self.detail = detail
        self.audio = audio
    }
    
    // 解析词形变换
    var exchangeForms: [String: String] {
        guard let exchange = exchange, !exchange.isEmpty else { return [:] }
        var forms: [String: String] = [:]
        let parts = exchange.split(separator: "/")
        for part in parts {
            let keyValue = part.split(separator: ":")
            if keyValue.count == 2 {
                forms[String(keyValue[0])] = String(keyValue[1])
            }
        }
        return forms
    }
    
    // 解析考试标签
    var examTags: [String] {
        guard let tag = tag, !tag.isEmpty else { return [] }
        let tagMap: [String: String] = [
            "zk": "中考", "gk": "高考", "cet4": "四级",
            "cet6": "六级", "ielts": "雅思", "toefl": "托福",
            "gre": "GRE", "sat": "SAT", "kaoyan": "考研"
        ]
        return tag.split(separator: " ").compactMap { tagMap[String($0)] }
    }
}

// MARK: - 搜索结果
struct SearchResult: Identifiable {
    let id = UUID()
    let word: String
    let phonetic: String?
    let briefTranslation: String?
    let isFavorite: Bool
}

// MARK: - 成语词条
struct IdiomEntry: Identifiable, Codable {
    let id: UUID
    let word: String          // 成语
    let pinyin: String?       // 拼音
    let definition: String?   // 释义
    let origin: String?       // 出处
    let example: String?      // 例句
    
    init(id: UUID = UUID(), word: String, pinyin: String? = nil,
         definition: String? = nil, origin: String? = nil, example: String? = nil) {
        self.id = id
        self.word = word
        self.pinyin = pinyin
        self.definition = definition
        self.origin = origin
        self.example = example
    }
}

// MARK: - 汉字词条（新华字典）
struct CharacterEntry: Identifiable, Codable {
    let id: UUID
    let character: String     // 汉字
    let pinyin: String?       // 拼音
    let radical: String?      // 部首
    let strokes: Int?         // 笔画数
    let definition: String?   // 释义
    let variants: String?     // 异体字
    
    init(id: UUID = UUID(), character: String, pinyin: String? = nil,
         radical: String? = nil, strokes: Int? = nil,
         definition: String? = nil, variants: String? = nil) {
        self.id = id
        self.character = character
        self.pinyin = pinyin
        self.radical = radical
        self.strokes = strokes
        self.definition = definition
        self.variants = variants
    }
}
