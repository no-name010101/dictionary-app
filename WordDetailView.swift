//
//  WordDetailView.swift
//  词典
//
//  单词详情视图 - 液态玻璃卡片布局
//

import SwiftUI

struct WordDetailView: View {
    let word: WordEntry
    @EnvironmentObject var appState: AppState
    @State private var isFavorite = false
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 词头卡片
                    wordHeaderCard
                    
                    // 释义卡片
                    if word.translation != nil || word.definition != nil {
                        definitionCard
                    }
                    
                    // 词形变换卡片
                    if !word.exchangeForms.isEmpty {
                        exchangeCard
                    }
                    
                    // 考试标签卡片
                    if !word.examTags.isEmpty {
                        examTagCard
                    }
                    
                    // 详细释义卡片
                    if let detail = word.detail, !detail.isEmpty {
                        detailCard(detail)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(word.word)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(isFavorite ? .red : .primary)
                        }
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .onAppear {
            isFavorite = appState.favoriteWords.contains(word.word)
        }
    }
    
    // MARK: - 词头
    private var wordHeaderCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                // 单词
                Text(word.word)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                // 音标 + 发音按钮
                if let phonetic = word.phonetic {
                    HStack(spacing: 16) {
                        Text(phonetic)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        // 美式发音
                        Button(action: {
                            PronunciationService.shared.speakEnglish(word.word)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("美")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glassEffect(.regular, in: .rect(cornerRadius: 8))
                        }
                        
                        // 英式发音
                        Button(action: {
                            PronunciationService.shared.speakBritish(word.word)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("英")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glassEffect(.regular, in: .rect(cornerRadius: 8))
                        }
                    }
                }
                
                // 词性标签
                if let pos = word.pos, !pos.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(pos.split(separator: " "), id: \.self) { p in
                            GlassTag(text: String(p), color: .purple)
                        }
                    }
                }
                
                // 柯林斯星级
                if let collins = word.collins, collins > 0 {
                    HStack(spacing: 2) {
                        Text("柯林斯")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        ForEach(1...min(collins, 5), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                
                // 牛津核心词标识
                if word.oxford == true {
                    GlassTag(text: "牛津3000", color: .orange)
                }
            }
        }
    }
    
    // MARK: - 释义
    private var definitionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "释义", icon: "text.word.spacing")
                
                // 中文翻译
                if let translation = word.translation {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(translation.split(separator: "\n"), id: \.self) { line in
                            Text("• \(line)")
                                .font(.body)
                        }
                    }
                }
                
                Divider()
                
                // 英文释义
                if let definition = word.definition {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("英文释义")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ForEach(definition.split(separator: "\n"), id: \.self) { line in
                            Text("• \(line)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 词形变换
    private var exchangeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "词形变换", icon: "arrow.triangle.2.circlepath")
                
                let forms = word.exchangeForms
                let labels: [(String, String)] = [
                    ("p", "过去式"), ("d", "过去分词"), ("i", "现在分词"),
                    ("3", "第三人称"), ("r", "比较级"), ("t", "最高级"),
                    ("s", "复数"), ("0", "原形")
                ]
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(labels, id: \.0) { key, label in
                        if let value = forms[key] {
                            HStack {
                                Text(label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(value)
                                    .font(.caption.weight(.medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassEffect(.regular, in: .rect(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 考试标签
    private var examTagCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "考试范围", icon: "graduationcap.fill")
                
                HStack(spacing: 8) {
                    ForEach(word.examTags, id: \.self) { tag in
                        GlassTag(text: tag, color: .green)
                    }
                }
            }
        }
    }
    
    // MARK: - 详细释义
    private func detailCard(_ detail: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "详细释义", icon: "doc.text.fill")
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 分节标题
    private struct SectionHeader: View {
        let title: String
        let icon: String
        
        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
        }
    }
    
    // MARK: - 收藏切换
    private func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            appState.favoriteWords.append(word.word)
        } else {
            appState.favoriteWords.removeAll { $0 == word.word }
        }
    }
}
