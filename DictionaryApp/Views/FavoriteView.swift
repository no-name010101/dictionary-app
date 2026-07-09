//
//  FavoriteView.swift
//  词典
//
//  收藏夹视图
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var databaseService: DatabaseService
    @State private var favoriteEntries: [WordEntry] = []
    @State private var selectedWord: WordEntry?
    
    var body: some View {
        NavigationStack {
            Group {
                if favoriteEntries.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.red.opacity(0.3))
                        Text("还没有收藏的单词")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("查词时点击心形图标即可收藏")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(favoriteEntries) { word in
                            Button(action: { selectedWord = word }) {
                                WordRowView(word: word)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    removeFavorite(word.word)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("收藏")
            .sheet(item: $selectedWord) { word in
                WordDetailView(word: word)
            }
        }
        .onChange(of: appState.favoriteWords) { _, _ in
            loadFavoriteEntries()
        }
        .onAppear {
            loadFavoriteEntries()
        }
    }
    
    private func loadFavoriteEntries() {
        favoriteEntries = appState.favoriteWords.compactMap { word in
            databaseService.lookupWord(word)
        }
    }
    
    private func removeFavorite(_ word: String) {
        appState.favoriteWords.removeAll { $0 == word }
        favoriteEntries.removeAll { $0.word == word }
    }
}
