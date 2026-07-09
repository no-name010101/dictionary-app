//
//  SearchView.swift
//  词典
//
//  主搜索视图 - 液态玻璃效果扁平化设计
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var databaseService: DatabaseService
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var searchResults: [WordEntry] = []
    @State private var suggestions: [String] = []
    @State private var isSearching = false
    @State private var selectedDictionary = 0
    @State private var showDetail = false
    @State private var selectedWord: WordEntry?
    @FocusState private var isSearchFocused: Bool
    
    private let dictionaryTabs = ["英汉", "汉英", "成语", "汉字"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 词典类型切换
                    GlassSegmentedControl(selected: $selectedDictionary, options: dictionaryTabs)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // 搜索框
                    GlassSearchBar(
                        text: $searchText,
                        placeholder: searchPlaceholder,
                        onSubmit: performSearch
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // 搜索建议
                    if isSearchFocused && !suggestions.isEmpty && searchResults.isEmpty {
                        suggestionsList
                    }
                    // 搜索结果
                    else if !searchResults.isEmpty {
                        searchResultsList
                    }
                    // 空状态
                    else {
                        emptyStateView
                    }
                }
            }
            .navigationTitle("词典")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: searchText) { _, newValue in
            if appState.enableAutoSearch && newValue.count >= 1 {
                updateSuggestions(newValue)
            }
            if newValue.isEmpty {
                searchResults = []
                suggestions = []
            }
        }
        .sheet(item: $selectedWord) { word in
            WordDetailView(word: word)
        }
    }
    
    // MARK: - 搜索占位提示
    private var searchPlaceholder: String {
        switch selectedDictionary {
        case 0: return "输入英文单词..."
        case 1: return "输入中文词语..."
        case 2: return "输入成语..."
        case 3: return "输入汉字..."
        default: return "搜索..."
        }
    }
    
    // MARK: - 搜索建议列表
    private var suggestionsList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        searchText = suggestion
                        performSearch()
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Text(suggestion)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
    
    // MARK: - 搜索结果列表
    private var searchResultsList: some View {
        List {
            ForEach(searchResults) { word in
                Button(action: { selectedWord = word }) {
                    WordRowView(word: word)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - 空状态
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue.opacity(0.3))
            
            Text("搜索单词开始学习")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
            
            Text("支持英汉互查、成语、汉字查询")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            // 每日推荐
            if databaseService.isDatabaseReady {
                DailyWordCard()
            }
            
            Spacer()
        }
    }
    
    // MARK: - 搜索操作
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        
        switch selectedDictionary {
        case 0:
            searchResults = databaseService.searchWord(searchText)
        case 1:
            searchResults = databaseService.searchByChinese(searchText)
        case 2:
            // 成语搜索转成 WordEntry 格式显示
            let idioms = databaseService.searchIdiom(searchText)
            searchResults = idioms.map { idiom in
                WordEntry(word: idiom.word, phonetic: idiom.pinyin, translation: idiom.definition)
            }
        case 3:
            // 汉字搜索转成 WordEntry 格式显示
            let chars = databaseService.searchCharacter(searchText)
            searchResults = chars.map { char in
                WordEntry(word: char.character, phonetic: char.pinyin, translation: char.definition)
            }
        default:
            break
        }
        
        // 记录搜索历史
        if !appState.searchHistory.contains(searchText) {
            appState.searchHistory.insert(searchText, at: 0)
            if appState.searchHistory.count > 50 {
                appState.searchHistory.removeLast()
            }
        }
        
        isSearching = false
        isSearchFocused = false
    }
    
    private func updateSuggestions(_ query: String) {
        switch selectedDictionary {
        case 0, 1:
            suggestions = databaseService.searchSuggestions(query)
        default:
            suggestions = []
        }
    }
}

// MARK: - 单词行视图
struct WordRowView: View {
    let word: WordEntry
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.word)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                
                if let phonetic = word.phonetic {
                    Text(phonetic)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let translation = word.translation {
                Text(translation.components(separatedBy: "\n").first ?? translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 每日一词卡片
struct DailyWordCard: View {
    @EnvironmentObject var databaseService: DatabaseService
    @State private var dailyWord: WordEntry?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("每日一词")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                Spacer()
                Image(systemName: "sparkle")
                    .foregroundStyle(.blue)
            }
            
            if let word = dailyWord {
                Text(word.word)
                    .font(.title2.weight(.bold))
                
                if let phonetic = word.phonetic {
                    Text(phonetic)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let translation = word.translation {
                    Text(translation.components(separatedBy: "\n").first ?? translation)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            } else {
                Text("加载中...")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 16)
        .task {
            dailyWord = databaseService.randomWord()
        }
    }
}
