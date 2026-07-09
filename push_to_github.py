#!/usr/bin/env python3
"""
push_to_github.py - Windows 版一键推送 + 云编译脚本

用法:
  python push_to_github.py <GitHub用户名> [仓库名]

前提:
  1. 已安装 git (https://git-scm.com/download/win)
  2. 已有 GitHub 账号
  3. git 已配置登录凭据

步骤:
  1. 在 GitHub 上创建仓库 (https://github.com/new)
  2. 运行: python push_to_github.py 你的用户名
  3. 等待 GitHub Actions 自动编译
  4. 下载编译好的 词典.ipa
"""

import subprocess
import sys
import os

def run(cmd, check=True):
    """执行命令"""
    print(f"  > {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.stdout.strip():
        print(f"    {result.stdout.strip()}")
    if check and result.returncode != 0:
        print(f"    ❌ 错误: {result.stderr.strip()}")
    return result

def main():
    if len(sys.argv) < 2:
        print("用法: python push_to_github.py <GitHub用户名> [仓库名]")
        print("")
        print("步骤:")
        print("  1. 先在 https://github.com/new 创建仓库 (Public)")
        print("  2. 运行: python push_to_github.py 你的用户名")
        print("  3. 等待 GitHub Actions 编译完成")
        print("  4. 在 Actions 页面下载 词典.ipa")
        sys.exit(1)
    
    username = sys.argv[1]
    repo_name = sys.argv[2] if len(sys.argv) > 2 else "dictionary-app"
    project_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 50)
    print("  推送词典 App 到 GitHub 云编译")
    print("=" * 50)
    print(f"  GitHub 用户: {username}")
    print(f"  仓库名称: {repo_name}")
    print(f"  项目目录: {project_dir}")
    print()
    
    # [1] 检查 git
    print("[1/5] 检查 git...")
    result = run("git --version", check=False)
    if result.returncode != 0:
        print("  ❌ 未安装 git，请先安装: https://git-scm.com/download/win")
        sys.exit(1)
    
    # [2] 初始化 Git
    print("[2/5] 初始化 Git 仓库...")
    os.chdir(project_dir)
    
    if not os.path.exists(".git"):
        run("git init")
        run("git branch -M main")
    
    # 创建 .gitignore
    gitignore = """# Xcode
build/
DerivedData/
*.xcuserdata/
xcuserdata/

# macOS / Windows
.DS_Store
Thumbs.db
*.swp

# 临时文件
*.zip
词典.ipa
词典.ipa.build/
.temp/
"""
    with open(".gitignore", "w", encoding="utf-8") as f:
        f.write(gitignore)
    
    # [3] 添加远程仓库
    print("[3/5] 配置远程仓库...")
    repo_url = f"https://github.com/{username}/{repo_name}.git"
    result = run("git remote get-url origin", check=False)
    if result.returncode != 0:
        run(f"git remote add origin {repo_url}")
    else:
        run(f"git remote set-url origin {repo_url}")
    
    # [4] 提交代码
    print("[4/5] 提交代码...")
    run("git add -A")
    result = run('git commit -m "词典 App v1.0.0 - iOS 26 Liquid Glass"', check=False)
    run("git push -u origin main --force", check=False)
    
    # [5] 完成
    print("[5/5] 推送完成!")
    print()
    print("=" * 50)
    print("  下一步操作:")
    print()
    print("  1. 打开浏览器查看编译进度:")
    print(f"     https://github.com/{username}/{repo_name}/actions")
    print()
    print("  2. 编译完成后，下载 IPA:")
    print(f"     https://github.com/{username}/{repo_name}/actions")
    print("     → 点击最新的 workflow → Artifacts → 词典-ipa")
    print()
    print("  3. 将 词典.ipa 传到 iPhone 安装:")
    print("     TrollStore → 直接打开安装 (永久)")
    print("     AltStore  → 通过 AltServer 侧载 (7天)")
    print("=" * 50)

if __name__ == "__main__":
    main()
