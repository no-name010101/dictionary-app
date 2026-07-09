#!/bin/bash
# =============================================================
#  push_to_github.sh - 一键推送项目到 GitHub 并触发云编译
#  
#  前提: 已安装 git，已有 GitHub 账号
#  用法: ./push_to_github.sh <你的GitHub用户名> [仓库名]
# =============================================================

set -e

USERNAME="${1:?用法: ./push_to_github.sh <GitHub用户名> [仓库名]}"
REPO_NAME="${2:-dictionary-app}"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "  推送词典 App 到 GitHub 云编译"
echo "========================================"
echo "  GitHub 用户: $USERNAME"
echo "  仓库名称: $REPO_NAME"
echo "  项目目录: $PROJECT_DIR"
echo ""

# Step 1: 初始化 Git
echo "[1/5] 初始化 Git 仓库..."
cd "$PROJECT_DIR"

if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Step 2: 创建 .gitignore
echo "[2/5] 创建 .gitignore..."
cat > .gitignore << 'EOF'
# Xcode
build/
DerivedData/
*.xcuserdata/
*.xcworkspace/
xcuserdata/

# macOS
.DS_Store
*.swp
*~

# 临时文件
*.zip
词典.ipa
词典.ipa.build/
.temp/
EOF

# Step 3: 创建 GitHub 仓库
echo "[3/5] 创建 GitHub 仓库..."
if command -v gh &> /dev/null; then
    gh repo create "$USERNAME/$REPO_NAME" --public --source=. --remote=origin || true
else
    echo "  未安装 gh CLI，请手动在 GitHub 创建仓库: https://github.com/new"
    echo "  仓库名: $REPO_NAME (Public)"
    echo "  创建后运行以下命令:"
    echo "    git remote add origin https://github.com/$USERNAME/$REPO_NAME.git"
    echo "    git add . && git commit -m '词典 App 初始版本' && git push -u origin main"
    exit 0
fi

# Step 4: 提交代码
echo "[4/5] 提交代码..."
git add -A
git commit -m "词典 App v1.0.0 - iOS 26 Liquid Glass Dictionary" || true
git push -u origin main --force

# Step 5: 触发编译
echo "[5/5] 触发 GitHub Actions 编译..."
gh workflow run "Build 词典.ipa" --repo "$USERNAME/$REPO_NAME" 2>/dev/null || \
gh workflow run build-ipa.yml --repo "$USERNAME/$REPO_NAME" 2>/dev/null || \
echo "  工作流将在推送后自动触发，或手动到 GitHub Actions 页面点击 Run workflow"

echo ""
echo "========================================"
echo "  推送完成!"
echo ""
echo "  查看编译进度:"
echo "    https://github.com/$USERNAME/$REPO_NAME/actions"
echo ""
echo "  编译完成后下载 IPA:"
echo "    https://github.com/$USERNAME/$REPO_NAME/actions"
echo "    → 点击最新的 workflow → Artifacts → 词典-ipa"
echo "========================================"
