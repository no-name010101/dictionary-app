#!/bin/bash
# =============================================================
#  build_and_sign.sh - 词典.ipa 构建与签名脚本
#  
#  用法:
#    方式1: TrollStore 永久签名  →  ./build_and_sign.sh trollstore
#    方式2: AltStore 7天签名    →  ./build_and_sign.sh altstore
#    方式3: 开发者证书签名       →  ./build_and_sign.sh developer
#    方式4: 仅构建不签名         →  ./build_and_sign.sh build
# =============================================================

set -e

# ===== 配置 =====
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="DictionaryApp"
SCHEME="DictionaryApp"
BUNDLE_ID="com.dictionary.liquidglass"
CONFIGURATION="Release"
ARCHIVE_PATH="${PROJECT_DIR}/build/${PROJECT_NAME}.xcarchive"
IPA_PATH="${PROJECT_DIR}/build/词典.ipa"
EXPORT_PATH="${PROJECT_DIR}/build/export"

echo "========================================"
echo "  词典.ipa 构建与签名工具"
echo "  项目目录: ${PROJECT_DIR}"
echo "========================================"

METHOD="${1:-build}"

# ===== Step 1: 清理并构建 =====
echo ""
echo "[1/4] 清理构建目录..."
rm -rf "${PROJECT_DIR}/build"
mkdir -p "${PROJECT_DIR}/build"

echo "[2/4] 开始构建 Archive..."
xcodebuild archive \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=iOS" \
    -sdk iphoneos \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    | tail -20

echo "[3/4] 导出 IPA..."

# ===== Step 2: 根据签名方式导出 =====
case "${METHOD}" in
    trollstore)
        echo ">>> 使用 TrollStore 方式导出 (无需签名)"
        # TrollStore 可以直接安装未签名的 IPA
        # 从 archive 中提取 app 并打包为 ipa
        extract_and_package
        echo ""
        echo "✅ 构建完成: ${IPA_PATH}"
        echo "📌 安装方式: 将 IPA 传输到 iPhone，用 TrollStore 打开安装"
        ;;
    
    altstore)
        echo ">>> 使用 AltStore 方式导出 (需要 Apple ID 签名)"
        echo "请输入你的 Apple ID:"
        read -r APPLE_ID
        echo "请输入你的 Apple ID 密码:"
        read -rs APPLE_PASSWORD
        echo ""
        
        # AltStore 使用个人开发者证书签名
        # 需要先通过 AltServer 侧载
        export_adhoc_with_signing "${APPLE_ID}" "${APPLE_PASSWORD}"
        echo ""
        echo "✅ 构建完成: ${IPA_PATH}"
        echo "📌 安装方式: 确保 AltServer 在 Mac/PC 上运行，通过 AltStore 安装"
        ;;
    
    developer)
        echo ">>> 使用开发者证书签名导出"
        echo "请输入 Team ID:"
        read -r TEAM_ID
        echo "请输入证书名称 (如: 'Apple Development: your@email.com'): "
        read -r CERT_NAME
        
        export_with_developer_cert "${TEAM_ID}" "${CERT_NAME}"
        echo ""
        echo "✅ 构建完成: ${IPA_PATH}"
        echo "📌 安装方式: 通过 Xcode 或 Apple Configurator 安装"
        ;;
    
    build)
        echo ">>> 仅构建，不签名"
        extract_and_package
        echo ""
        echo "✅ 构建完成 (未签名): ${IPA_PATH}"
        echo "📌 需要自行签名后才能安装"
        ;;
    
    *)
        echo "❌ 未知方式: ${METHOD}"
        echo "可用方式: trollstore | altstore | developer | build"
        exit 1
        ;;
esac

echo ""
echo "[4/4] 构建信息:"
echo "  文件: ${IPA_PATH}"
echo "  大小: $(du -h "${IPA_PATH}" | cut -f1)"
echo "  Bundle ID: ${BUNDLE_ID}"
echo "  最低系统: iOS 26.0"
echo "========================================"

# ===== 辅助函数 =====

# 从 Archive 提取 App 并打包为 IPA
extract_and_package() {
    local APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"
    
    if [ ! -d "${APP_PATH}" ]; then
        echo "❌ 未找到 .app 文件，构建可能失败"
        exit 1
    fi
    
    mkdir -p "${EXPORT_PATH}/Payload"
    cp -R "${APP_PATH}" "${EXPORT_PATH}/Payload/"
    
    # 添加元数据
    cat > "${EXPORT_PATH}/iTunesMetadata.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>bundleIdentifier</key>
    <string>com.dictionary.liquidglass</string>
    <key>bundleShortVersionString</key>
    <string>1.0.0</string>
    <key>bundleVersion</key>
    <string>1</string>
    <key>itemName</key>
    <string>词典</string>
    <key>softwareVersionBundleId</key>
    <string>com.dictionary.liquidglass</string>
</dict>
</plist>
EOF
    
    cd "${EXPORT_PATH}"
    zip -r "${IPA_PATH}" Payload iTunesMetadata.plist
    cd "${PROJECT_DIR}"
}

# Ad-Hoc 签名导出
export_adhoc_with_signing() {
    local APPLE_ID="$1"
    local PASSWORD="$2"
    
    cat > "${EXPORT_PATH}/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string></string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportOptionsPlist "${EXPORT_PATH}/ExportOptions.plist" \
        -exportPath "${EXPORT_PATH}" \
        | tail -10
    
    # 重命名为 词典.ipa
    if [ -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" ]; then
        mv "${EXPORT_PATH}/${PROJECT_NAME}.ipa" "${IPA_PATH}"
    fi
}

# 开发者证书签名导出
export_with_developer_cert() {
    local TEAM_ID="$1"
    local CERT_NAME="$2"
    
    cat > "${EXPORT_PATH}/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${BUNDLE_ID}</key>
        <string>${BUNDLE_ID}_dev_profile</string>
    </dict>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportOptionsPlist "${EXPORT_PATH}/ExportOptions.plist" \
        -exportPath "${EXPORT_PATH}" \
        | tail -10
    
    if [ -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" ]; then
        mv "${EXPORT_PATH}/${PROJECT_NAME}.ipa" "${IPA_PATH}"
    fi
}
