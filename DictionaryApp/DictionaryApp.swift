//
//  DictionaryApp.swift
//  词典 - Liquid Glass Dictionary
//
//  iOS 26+ | SwiftUI | Liquid Glass Design
//  适配 iPhone 14 及以上设备
//

import SwiftUI

@main
struct DictionaryApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var databaseService = DatabaseService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(databaseService)
                .task {
                    // 启动时初始化词库
                    await databaseService.initializeDatabase()
                }
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isOnline: Bool = true
    @Published var searchHistory: [String] = []
    @Published var favoriteWords: [String] = []
    @Published var selectedDictionary: DictionaryType = .ecdict
    @Published var fontSize: CGFloat = 17
    @Published var enablePronunciation: Bool = true
    @Published var enableAutoSearch: Bool = true
    
    enum DictionaryType: String, CaseIterable {
        case ecdict = "英汉词典"
        case cedict = "汉英词典"
        case idiom = "成语词典"
        case xinhua = "新华字典"
    }
}
