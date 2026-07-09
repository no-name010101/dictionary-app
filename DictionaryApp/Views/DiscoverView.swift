//
//  DiscoverView.swift
//  词典
//
//  发现页面 - 每日推荐 / 热门词汇 / 学习统计
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var databaseService: DatabaseService
    @EnvironmentObject var appState: AppState
    @State private var dailyWords: [WordEntry] = []
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 每日推荐卡片组
                    dailyRecommendSection
                    
                    // 考试词汇入口
                    examVocabularySection
                    
                    // 搜索历史
                    if !appState.searchHistory.isEmpty {
                        searchHistorySection
                    }
                    
                    // 词库信息
                    dictionaryInfoSection
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
            .navigationTitle("发现")
        }
        .task {
            loadDailyWords()
        }
    }
    
    // MARK: - 每日推荐
    private var dailyRecommendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "每日推荐", icon: "sparkles")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dailyWords) { word in
                        DailyWordMiniCard(word: word)
                    }
                }
            }
        }
    }
    
    // MARK: - 考试词汇
    private var examVocabularySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "考试词汇", icon: "graduationcap.fill")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ExamCard(title: "四级词汇", count: "4,000+", color: .blue, tag: "cet4")
                ExamCard(title: "六级词汇", count: "5,500+", color: .purple, tag: "cet6")
                ExamCard(title: "雅思词汇", count: "7,000+", color: .orange, tag: "ielts")
                ExamCard(title: "托福词汇", count: "8,000+", color: .red, tag: "toefl")
                ExamCard(title: "GRE词汇", count: "9,000+", color: .green, tag: "gre")
                ExamCard(title: "高考词汇", count: "3,500+", color: .pink, tag: "gk")
            }
        }
    }
    
    // MARK: - 搜索历史
    private var searchHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(title: "搜索历史", icon: "clock.arrow.circlepath")
                Spacer()
                Button("清除") {
                    appState.searchHistory = []
                }
                .font(.caption)
                .foregroundStyle(.red)
            }
            
            GlassCard {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(appState.searchHistory.prefix(10), id: \.self) { word in
                        HStack {
                            Text(word)
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 词库信息
    private var dictionaryInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "词库信息", icon: "externaldrive.fill")
            
            ForEach(DatabaseConfig.allDictionaries) { dict in
                GlassCard(cornerRadius: 14, padding: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dict.name)
                                .font(.subheadline.weight(.semibold))
                            Text("\(dict.entryCount) 词条 · \(dict.fileSize)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }
    
    private func loadDailyWords() {
        dailyWords = (0..<5).compactMap { _ in databaseService.randomWord() }
    }
}

// MARK: - 子组件

private struct SectionTitle: View {
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

private struct DailyWordMiniCard: View {
    let word: WordEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word.word)
                .font(.title3.weight(.bold))
            
            if let phonetic = word.phonetic {
                Text(phonetic)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let translation = word.translation {
                Text(translation.components(separatedBy: "\n").first ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

private struct ExamCard: View {
    let title: String
    let count: String
    let color: Color
    let tag: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(count)
                .font(.caption)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}
