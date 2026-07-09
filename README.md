---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'ac2047e6-6b58-47f0-a7b3-38fc4a3248ca'
  PropagateID: 'ac2047e6-6b58-47f0-a7b3-38fc4a3248ca'
  ReservedCode1: '741aa4ce-108e-4a25-9b87-5cacca88a310'
  ReservedCode2: '741aa4ce-108e-4a25-9b87-5cacca88a310'
---

# 词典 App - iOS 26 Liquid Glass Dictionary

> 基于 SwiftUI + Liquid Glass 设计语言的离线词典应用，适配 iPhone 14+

## 功能特性

| 功能 | 说明 |
|------|------|
| 英汉互查 | ECDICT 77万词条，英→中 / 中→英双向查询 |
| 成语词典 | 5万成语，含释义、出处、例句 |
| 新华字典 | 2万汉字，含拼音、部首、笔画 |
| 离线使用 | SQLite 本地词库，无需联网 |
| 发音功能 | 美式/英式发音，TTS 语音合成 |
| 每日推荐 | 随机推荐高频词汇学习 |
| 考试标签 | 四六级/雅思/托福/GRE 考试范围标注 |
| 收藏夹 | 生词本功能，支持滑动删除 |
| 搜索建议 | 实时联想补全，模糊查询 |
| 词形变换 | 时态/复数/比较级等变形展示 |

## 系统要求

- **最低系统**: iOS 26.0
- **适配设备**: iPhone 14 / 14 Plus / 14 Pro / 14 Pro Max / 15 / 16 / 17 全系列
- **设计语言**: Liquid Glass (iOS 26 沙态玻璃效果)
- **开发框架**: SwiftUI 6.0

## 项目结构

```
词典App/
├── DictionaryApp/
│   ├── DictionaryApp.swift          # 应用入口
│   ├── Models/
│   │   ├── WordEntry.swift          # 词库数据模型
│   │   └── DatabaseConfig.swift     # 数据库配置
│   ├── Views/
│   │   ├── Components/
│   │   │   └── GlassComponents.swift # 沙态玻璃UI组件库
│   │   ├── MainTabView.swift        # 主标签导航
│   │   ├── SearchView.swift         # 搜索主页
│   │   ├── WordDetailView.swift     # 单词详情
│   │   ├── DiscoverView.swift       # 发现页
│   │   ├── FavoriteView.swift       # 收藏夹
│   │   ├── SettingsView.swift       # 设置页
│   │   └── LaunchScreen.swift       # 启动屏幕
│   ├── Services/
│   │   ├── DatabaseService.swift    # SQLite 数据库服务
│   │   └── PronunciationService.swift # 语音发音服务
│   └── Resources/
│       ├── ecdict.db                # 英汉词典 (需下载)
│       ├── idiom.db                 # 成语词典
│       └── xinhua.db               # 新华字典
├── build_and_sign.sh               # 构建与签名脚本
├── download_ecdict.sh              # 词典数据下载脚本
└── csv_to_sqlite.py                # CSV→SQLite 转换工具
```

## 构建步骤

### 1. 准备词库数据

```bash
# 下载 ECDICT 数据并转换为 SQLite
chmod +x download_ecdict.sh
./download_ecdict.sh
```

或手动下载：
- 访问 https://github.com/skywind3000/ECDICT
- 下载 CSV 数据，用 `csv_to_sqlite.py` 转换为 `ecdict.db`
- 将 `ecdict.db` 放入 `DictionaryApp/Resources/` 目录

### 2. 用 Xcode 构建项目

```bash
# 在 Mac 上打开 Xcode
open DictionaryApp.xcodeproj

# 或命令行构建
xcodebuild -project DictionaryApp.xcodeproj \
    -scheme DictionaryApp \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    build
```

### 3. 签名与安装

#### 方案 A: TrollStore 永久签名 (推荐)

1. 确保 iPhone 已安装 TrollStore (需 CoreTrust 漏洞支持)
2. 构建 IPA: `./build_and_sign.sh trollstore`
3. 将 `词典.ipa` 传输到 iPhone (AirDrop/网页/USB)
4. 用 TrollStore 打开 IPA 文件安装
5. **优势**: 永久有效，无需续签

#### 方案 B: AltStore 7天签名

1. 在 Mac/PC 上安装 AltServer
2. iPhone 上安装 AltStore
3. 构建 IPA: `./build_and_sign.sh altstore`
4. 通过 AltStore 侧载 IPA
5. AltServer 每 7 天自动刷新签名
6. **注意**: 需保持 AltServer 运行，WiFi 连接同一网络

#### 方案 C: Apple Developer 证书签名

1. 拥有 Apple Developer 账号 ($99/年)
2. 在 Xcode 中配置 Team ID 和证书
3. 构建: `./build_and_sign.sh developer`
4. 通过 Xcode 直接安装到设备
5. **优势**: 有效期1年，最稳定

#### 方案 D: 免费开发者账号 (最简单)

1. 在 Xcode → Settings → Accounts 添加 Apple ID
2. 选择自动签名 (Automatically manage signing)
3. 直接 Run 到连接的 iPhone
4. **注意**: 免费账号签名7天有效，需重新 Run

## iOS 26 沙态玻璃效果说明

本项目使用 iOS 26 全新 Liquid Glass API:

| SwiftUI API | 用途 |
|-------------|------|
| `.glassEffect(.regular, in: Shape)` | 给视图添加沙态玻璃效果 |
| `.glassBackgroundEffect(_:displayMode:)` | 沙态玻璃背景效果 |
| `.glassEffectID(_:in:)` | 标识沙态玻璃元素 |
| `.glassEffectTransition(_:)` | 沙态玻璃转场动画 |
| `UIGlassEffect` | UIKit 沙态玻璃视觉效果 |
| `UIGlassContainerEffect` | 多个沙态玻璃元素组合 |

低版本兼容: 提供 `.adaptiveGlassEffect()` 方法，iOS 26 以下回退为 `.ultraThinMaterial`

## iPhone 14+ 屏幕适配

| 设备 | 分辨率 | 逻辑分辨率 | 缩放因子 |
|------|--------|-----------|---------|
| iPhone 14 | 2532×1170 | 390×844 | @3x |
| iPhone 14 Plus | 2778×1284 | 428×926 | @3x |
| iPhone 14 Pro | 2556×1179 | 393×852 | @3x |
| iPhone 14 Pro Max | 2796×1290 | 430×932 | @3x |
| iPhone 15 全系列 | 同上 | 同上 | @3x |
| iPhone 16 全系列 | 同上 | 同上 | @3x |

SwiftUI 使用逻辑分辨率自动适配，无需手动处理。

## 词库来源

- **ECDICT**: https://github.com/skywind3000/ECDICT (MIT 协议, 77万词条)
- **成语词典**: 内置常用成语数据
- **新华字典**: 内置常用汉字数据

## 许可证

本项目代码 MIT 协议开源。ECDICT 词库同样为 MIT 协议。

> AI生成