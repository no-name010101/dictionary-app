//
//  LaunchScreen.swift
//  词典
//
//  启动屏幕 - 液态玻璃效果
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.4),
                    Color.blue.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App 图标
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .glassEffect(.regular, in: .rect(cornerRadius: 24))
                
                Text("词典")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Liquid Glass Dictionary")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
