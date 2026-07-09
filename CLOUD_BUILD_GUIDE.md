---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: '7196b928-6491-48e8-826e-abd288810954'
  PropagateID: '7196b928-6491-48e8-826e-abd288810954'
  ReservedCode1: '7ecc3814-92c8-432b-a7d1-38195b7b49fe'
  ReservedCode2: '7ecc3814-92c8-432b-a7d1-38195b7b49fe'
---

# GitHub 云编译操作指南

> 在 Windows 上无需安装 Git，通过浏览器操作即可完成云编译

## 操作步骤（共 3 步）

### 第 1 步：在 GitHub 上创建仓库

1. 打开 https://github.com 登录你的账号
2. 点击右上角 **+** → **New repository**
3. 填写信息：
   - Repository name: `dictionary-app`
   - 选择 **Public**（公开仓库，GitHub Actions 免费版需要）
   - **不要**勾选 "Add a README file"
4. 点击 **Create repository**

### 第 2 步：上传项目文件

1. 进入刚创建的仓库页面
2. 点击 **uploading an existing file**
3. 打开本机 `D:\TeleAgent\任务\词典App` 目录
4. **把所有文件和文件夹拖到浏览器窗口**，保持目录结构：
   ```
   .github/workflows/build-ipa.yml
   DictionaryApp/DictionaryApp.swift
   DictionaryApp/Models/WordEntry.swift
   DictionaryApp/Models/DatabaseConfig.swift
   DictionaryApp/Services/DatabaseService.swift
   DictionaryApp/Services/PronunciationService.swift
   DictionaryApp/Views/MainTabView.swift
   DictionaryApp/Views/SearchView.swift
   DictionaryApp/Views/WordDetailView.swift
   DictionaryApp/Views/DiscoverView.swift
   DictionaryApp/Views/FavoriteView.swift
   DictionaryApp/Views/SettingsView.swift
   DictionaryApp/Views/LaunchScreen.swift
   DictionaryApp/Views/Components/GlassComponents.swift
   DictionaryApp/Assets.xcassets/Contents.json
   DictionaryApp/Assets.xcassets/AppIcon.appiconset/Contents.json
   DictionaryApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png
   DictionaryApp/Assets.xcassets/AccentColor.colorset/Contents.json
   DictionaryApp/Resources/ecdict.db
   DictionaryApp/Resources/idiom.db
   DictionaryApp/Resources/xinhua.db
   DictionaryApp.xcodeproj/project.pbxproj
   ```
5. 在底部 Commit 信息填写 `词典 App v1.0.0`
6. 点击 **Commit changes**

### 第 3 步：等待自动编译 & 下载 IPA

1. 上传完成后，点击仓库页面顶部的 **Actions** 标签
2. 左侧选择 **Build 词典.ipa** workflow
3. 如果没有自动运行，点击右侧 **Run workflow** → **Run workflow** 按钮
4. 等待编译完成（约 5-15 分钟）
5. 编译成功后，点击该次运行记录
6. 在页面底部的 **Artifacts** 区域找到 **词典-ipa**
7. 点击下载，得到 `词典-ipa.zip`
8. 解压后即为 **词典.ipa**

### 安装到 iPhone

将 词典.ipa 传到 iPhone 后：

| 方式 | 操作 | 有效期 |
|------|------|--------|
| **TrollStore** | 用 TrollStore 打开 IPA 安装 | 永久 |
| **AltStore** | 通过 AltServer 侧载 | 7天自动续 |
| **Xcode** | 连接设备直接安装 | 7天 |

---

## 备选方案：手动创建仓库后用命令推送

如果你后续安装了 Git，可以使用以下命令：

```bash
cd D:\TeleAgent\任务\词典App
git init
git branch -M main
git remote add origin https://github.com/你的用户名/dictionary-app.git
git add .
git commit -m "词典 App v1.0.0"
git push -u origin main
```

然后在 GitHub Actions 页面手动触发编译。

> AI生成