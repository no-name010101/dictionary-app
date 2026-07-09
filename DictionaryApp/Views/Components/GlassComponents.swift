//
//  GlassComponents.swift
//  词典
//
//  iOS 26 液态玻璃 (Liquid Glass) 效果组件库
//  使用 SwiftUI .glassEffect() / .glassBackgroundEffect() API
//

import SwiftUI

// MARK: - 沙态玻璃卡片
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    
    init(cornerRadius: CGFloat = 20, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - 沙态玻璃导航栏
struct GlassNavigationBar: View {
    let title: String
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if showBack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

// MARK: - 沙态玻璃搜索框
struct GlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索单词、成语、汉字..."
    var onSubmit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .font(.body)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}

// MARK: - 沙态玻璃按钮
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: GlassButtonStyle = .primary
    
    enum GlassButtonStyle {
        case primary, secondary, destructive
    }
    
    init(_ title: String, icon: String? = nil, style: GlassButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                Text(title)
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(style == .primary ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
    }
}

// MARK: - 沙态玻璃标签
struct GlassTag: View {
    let text: String
    var color: Color = .blue
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .glassEffect(.regular, in: .rect(cornerRadius: 8))
    }
}

// MARK: - 沙态玻璃分段控制器
struct GlassSegmentedControl: View {
    @Binding var selected: Int
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: { selected = index }) {
                    Text(options[index])
                        .font(.subheadline.weight(selected == index ? .semibold : .regular))
                        .foregroundStyle(selected == index ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .glassEffect(
                            selected == index ? .regular : .regular.interactive,
                            in: .rect(cornerRadius: 10)
                        )
                }
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
}

// MARK: - 沙态玻璃浮动操作按钮
struct GlassFloatingButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .glassEffect(.regular, in: .circle)
        }
    }
}

// MARK: - 沙态玻璃列表行
struct GlassListRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassBackgroundEffect(.regular, displayMode: .always)
    }
}

// MARK: - iOS 26 兼容性适配
// 对于 iOS 26 以下版本提供 fallback
extension View {
    @ViewBuilder
    func adaptiveGlassEffect(_ glass: Glass, in shape: some Shape) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(glass, in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
    
    @ViewBuilder
    func adaptiveGlassBackgroundEffect(_ effect: some GlassBackgroundEffect, displayMode: GlassBackgroundDisplayMode) -> some View {
        if #available(iOS 26, *) {
            self.glassBackgroundEffect(effect, displayMode: displayMode)
        } else {
            self.background(.ultraThinMaterial)
        }
    }
}
