#!/usr/bin/env python3
"""
csv_to_sqlite.py - 将 ECDICT CSV 数据转换为 SQLite 数据库

用法: python3 csv_to_sqlite.py --csv stardict.csv --db ecdict.db
"""

import csv
import sqlite3
import argparse
import sys
import os

def create_database(csv_path, db_path):
    """将 ECDICT CSV 文件导入 SQLite 数据库"""
    
    if not os.path.exists(csv_path):
        print(f"❌ CSV 文件不存在: {csv_path}")
        sys.exit(1)
    
    # 删除已有数据库
    if os.path.exists(db_path):
        os.remove(db_path)
    
    # 创建数据库连接
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 创建表
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS stardict (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            sw TEXT NOT NULL,
            phonetic TEXT,
            definition TEXT,
            translation TEXT,
            pos TEXT,
            collins INTEGER,
            oxford INTEGER DEFAULT 0,
            tag TEXT,
            bnc INTEGER,
            frq INTEGER,
            exchange TEXT,
            detail TEXT,
            audio TEXT
        )
    """)
    
    # 创建索引
    cursor.execute("CREATE INDEX idx_word ON stardict(word)")
    cursor.execute("CREATE INDEX idx_sw ON stardict(sw)")
    cursor.execute("CREATE INDEX idx_collins ON stardict(collins)")
    cursor.execute("CREATE INDEX idx_oxford ON stardict(oxford)")
    cursor.execute("CREATE INDEX idx_tag ON stardict(tag)")
    
    # 读取 CSV 并插入
    print(f"正在读取 {csv_path} ...")
    
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)  # 跳过标题行
        
        batch = []
        count = 0
        total = 770000  # 预估总条数
        
        for row in reader:
            if len(row) < 14:
                continue
            
            # 生成 sw (小写排序键)
            word = row[0]
            sw = word.lower().replace("'", "").replace("-", "")
            
            try:
                collins = int(row[6]) if row[6] else None
            except ValueError:
                collins = None
            
            try:
                oxford = int(row[7]) if row[7] else 0
            except ValueError:
                oxford = 0
            
            try:
                bnc = int(row[9]) if row[9] else None
            except ValueError:
                bnc = None
            
            try:
                frq = int(row[10]) if row[10] else None
            except ValueError:
                frq = None
            
            batch.append((
                word, sw,
                row[1] if len(row) > 1 else None,   # phonetic
                row[2] if len(row) > 2 else None,   # definition
                row[3] if len(row) > 3 else None,   # translation
                row[4] if len(row) > 4 else None,   # pos
                collins, oxford,
                row[8] if len(row) > 8 else None,   # tag
                bnc, frq,
                row[11] if len(row) > 11 else None, # exchange
                row[12] if len(row) > 12 else None, # detail
                row[13] if len(row) > 13 else None  # audio
            ))
            
            count += 1
            
            # 批量插入 (每 5000 条提交一次)
            if len(batch) >= 5000:
                cursor.executemany("""
                    INSERT OR IGNORE INTO stardict 
                    (word, sw, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, batch)
                conn.commit()
                batch = []
                
                if count % 50000 == 0:
                    pct = count / total * 100
                    print(f"  进度: {count:,} / ~{total:,} ({pct:.1f}%)")
    
        # 插入剩余数据
        if batch:
            cursor.executemany("""
                INSERT OR IGNORE INTO stardict 
                (word, sw, phonetic, definition, translation, pos, collins, oxford, tag, bnc, frq, exchange, detail, audio)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, batch)
            conn.commit()
    
    # 优化数据库
    print("优化数据库...")
    cursor.execute("ANALYZE")
    cursor.execute("VACUUM")
    
    # 统计
    cursor.execute("SELECT COUNT(*) FROM stardict")
    total_count = cursor.fetchone()[0]
    
    conn.close()
    
    # 显示结果
    db_size = os.path.getsize(db_path)
    print(f"\n✅ 数据库创建完成!")
    print(f"   文件: {db_path}")
    print(f"   词条数: {total_count:,}")
    print(f"   文件大小: {db_size / 1024 / 1024:.1f} MB")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='ECDICT CSV to SQLite converter')
    parser.add_argument('--csv', required=True, help='CSV 文件路径')
    parser.add_argument('--db', required=True, help='SQLite 输出路径')
    args = parser.parse_args()
    
    create_database(args.csv, args.db)
