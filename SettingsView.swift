//
//  SettingsView.swift
//  词典
//
//  设置视图 - 液态玻璃效果设置面板
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var databaseService: DatabaseService
    @State private var showDictionaryManager = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 词典设置
                    dictionarySection
                    
                    // 显示设置
                    displaySection
                    
                    // 功能开关
                    featureSection
                    
                    // 词库管理
                    databaseSection
                    
                    // 签名信息
                    signingSection
                    
                    // 关于
                    aboutSection
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
            .navigationTitle("设置")
        }
    }
    
    // MARK: - 词典设置
    private var dictionarySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "词典设置", icon: "book.fill")
                
                Picker("默认词典", selection: $appState.selectedDictionary) {
                    ForEach(AppState.DictionaryType.allCases, id: \.self) { dict in
                        Text(dict.rawValue).tag(dict)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    // MARK: - 显示设置
    private var displaySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "显示设置", icon: "textformat.size")
                
                HStack {
                    Text("字体大小")
                    Spacer()
                    Text("\(Int(appState.fontSize))pt")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $appState.fontSize, in: 14...24, step: 1)
                    .tint(.blue)
            }
        }
    }
    
    // MARK: - 功能开关
    private var featureSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "功能设置", icon: "switch.2")
                
                Toggle("发音功能", isOn: $appState.enablePronunciation)
                Toggle("自动搜索", isOn: $appState.enableAutoSearch)
            }
        }
    }
    
    // MARK: - 词库管理
    private var databaseSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "词库管理", icon: "externaldrive.fill")
                
                HStack {
                    Text("词库状态")
                    Spacer()
                    if databaseService.isDatabaseReady {
                        Label("已就绪", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    } else {
                        Label("加载中", systemImage: "progress.indicator")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
                
                HStack {
                    Text("词条总数")
                    Spacer()
                    Text("\(databaseService.totalEntries)")
                        .foregroundStyle(.secondary)
                }
                
                Button("重新加载词库") {
                    Task {
                        await databaseService.initializeDatabase()
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.blue)
            }
        }
    }
    
    // MARK: - 签名信息
    private var signingSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "签名与安装", icon: "lock.shield.fill")
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(.blue)
                        Text("TrollStore 永久签名")
                    }
                    .font(.subheadline)
                    Text("利用 CoreTrust 漏洞实现永久签名，无需续签")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(.blue)
                        Text("AltStore 7天签名")
                    }
                    .font(.subheadline)
                    Text("使用 Apple ID 签名，7天自动续签")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundStyle(.blue)
                        Text("开发者证书签名")
                    }
                    .font(.subheadline)
                    Text("Apple Developer 账号签名，有效期1年")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - 关于
    private var aboutSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "关于", icon: "info.circle.fill")
                
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                HStack {
                    Text("最低系统")
                    Spacer()
                    Text("iOS 26.0")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                HStack {
                    Text("词库来源")
                    Spacer()
                    Text("ECDICT")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                HStack {
                    Text("设计风格")
                    Spacer()
                    Text("Liquid Glass")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
    }
    
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
}
