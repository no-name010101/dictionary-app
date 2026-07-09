//
//  MainTabView.swift
//  词典
//
//  主标签导航视图 - iOS 26 Liquid Glass Tab Bar
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tabItem {
                    Label("词典", systemImage: "book.fill")
                }
                .tag(0)
            
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "sparkles")
                }
                .tag(1)
            
            FavoriteView()
                .tabItem {
                    Label("收藏", systemImage: "heart.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.blue)
        // iOS 26 液态玻璃 Tab Bar 自动适配
    }
}
