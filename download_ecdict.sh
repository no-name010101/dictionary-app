#!/bin/bash
# =============================================================
#  download_ecdict.sh - 下载 ECDICT 开源英汉词典数据库
#  
#  ECDICT: 77万词条英汉词典，MIT 协议开源
#  项目地址: https://github.com/skywind3000/ECDICT
# =============================================================

set -e

RESOURCES_DIR="$(cd "$(dirname "$0")" && pwd)/DictionaryApp/Resources"
mkdir -p "${RESOURCES_DIR}"

echo "========================================"
echo "  ECDICT 词典数据库下载工具"
echo "========================================"

# Step 1: 下载 ECDICT CSV 数据
echo ""
echo "[1/3] 下载 ECDICT 词典数据..."
ECDICT_URL="https://github.com/skywind3000/ECDICT/releases/download/1.0.0/ecdict-csv-28.zip"
CSV_ZIP="${RESOURCES_DIR}/ecdict-csv.zip"

if command -v curl &> /dev/null; then
    curl -L -o "${CSV_ZIP}" "${ECDICT_URL}"
elif command -v wget &> /dev/null; then
    wget -O "${CSV_ZIP}" "${ECDICT_URL}"
else
    echo "❌ 需要 curl 或 wget 来下载数据"
    exit 1
fi

# Step 2: 解压
echo "[2/3] 解压数据文件..."
unzip -o "${CSV_ZIP}" -d "${RESOURCES_DIR}"

# Step 3: 转换为 SQLite 数据库
echo "[3/3] 转换为 SQLite 数据库..."
python3 "$(dirname "$0")/csv_to_sqlite.py" \
    --csv "${RESOURCES_DIR}/stardict.csv" \
    --db "${RESOURCES_DIR}/ecdict.db"

# 清理临时文件
rm -f "${CSV_ZIP}"

echo ""
echo "✅ ECDICT 数据库已保存到: ${RESOURCES_DIR}/ecdict.db"
echo "========================================"
