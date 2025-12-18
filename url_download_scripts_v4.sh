#!/bin/bash
##########################################
# File Name:test.sh
# Version:V4.0
# Author:vxhs888p
# 0rganization:linuxjk.cn
# Desc: 下载url对应的图片并以数字序号作为前缀防止文件重复，序号即为file.txt中的url顺序
###########################################

# 定义变量
URL_FILE="files/file.txt"
ENCODED_URL_FILE="files/encoded_urls.txt"
LOG_FILE="logs/download.log"
SUCCESS_FILE="logs/success.log"
FAIL_FILE="logs/fail.log"
DOWNLOAD_DIR="files/downloads"

# 创建下载目录和日志目录
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ENCODED_URL_FILE")"

# 初始化计数器
total=0
success=0
fail=0

# 清空日志文件
> "$LOG_FILE"
> "$SUCCESS_FILE"
> "$FAIL_FILE"

# 记录开始时间
echo "下载开始时间: $(date)" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"

# 第一步：对URL文件进行编码处理
echo "正在对URL进行编码处理..." | tee -a "$LOG_FILE"
> "$ENCODED_URL_FILE"

while IFS= read -r url || [[ -n "$url" ]]; do
    # 跳过空行
    url=$(echo "$url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -z "$url" ]]; then
        continue
    fi
    
    # 对URL进行编码：空格 -> %20, ( -> %28, ) -> %29
    encoded_url=$(echo "$url" | sed '
        s/ /%20/g;
        s/(/%28/g;
        s/)/%29/g
    ')
    
    echo "$encoded_url" >> "$ENCODED_URL_FILE"
    echo "原始: $url" | tee -a "$LOG_FILE"
    echo "编码: $encoded_url" | tee -a "$LOG_FILE"
    echo "---" | tee -a "$LOG_FILE"
    
done < "$URL_FILE"

echo "URL编码完成！编码后的URL保存在: $ENCODED_URL_FILE" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"

# 第二步：使用编码后的URL进行下载
echo "开始下载文件..." | tee -a "$LOG_FILE"

# 创建文件映射记录，避免重复
declare -A downloaded_files

while IFS= read -r encoded_url || [[ -n "$encoded_url" ]]; do
    # 跳过空行
    encoded_url=$(echo "$encoded_url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -z "$encoded_url" ]]; then
        continue
    fi

    total=$((total + 1))

    # 从编码后的URL中提取文件名（需要先解码文件名部分）
    original_filename=$(echo "$encoded_url" | sed 's|.*/||' | sed '
        s/%20/ /g;
        s/%28/(/g;
        s/%29/)/g
    ')
    
    # 获取文件扩展名
    extension="${original_filename##*.}"
    if [[ "$extension" == "$original_filename" ]]; then
        extension=""
    else
        extension=".$extension"
    fi
    
    # 生成唯一文件名（添加序号前缀）
    base_filename=$(basename "$original_filename" "$extension")
    filename="${total}_${base_filename}${extension}"
    
    # 检查文件名是否已存在，如果存在则添加时间戳
    if [[ -n "${downloaded_files[$filename]}" ]]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        filename="${total}_${base_filename}_${timestamp}${extension}"
    fi
    
    downloaded_files[$filename]=1

    # 完整的文件路径
    filepath="${DOWNLOAD_DIR}/${filename}"

    echo "正在下载第 $total 个文件: $filename" | tee -a "$LOG_FILE"
    echo "原始文件名: $original_filename" | tee -a "$LOG_FILE"
    echo "编码URL: $(echo "$encoded_url" | cut -c1-80)..." | tee -a "$LOG_FILE"

    # 使用wget下载文件
    if wget --timeout=30 --tries=3 \
            --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
            -O "$filepath" \
            "$encoded_url" 2>> "$LOG_FILE"; then
        
        # 检查文件是否真的下载成功（文件存在且大小大于0）
        if [[ -f "$filepath" ]] && [[ -s "$filepath" ]]; then
            file_size=$(wc -c < "$filepath")
            echo "✓ 成功下载: $filename ($file_size bytes)" | tee -a "$LOG_FILE"
            echo "$encoded_url -> $filepath ($file_size bytes)" >> "$SUCCESS_FILE"
            success=$((success + 1))
            
        else
            echo "✗ 文件为空或损坏: $filename" | tee -a "$LOG_FILE"
            echo "$encoded_url -> 空文件/损坏" >> "$FAIL_FILE"
            rm -f "$filepath" 2>/dev/null
            fail=$((fail + 1))
        fi
    else
        echo "✗ 下载失败: $filename" | tee -a "$LOG_FILE"
        echo "$encoded_url" >> "$FAIL_FILE"
        fail=$((fail + 1))
    fi

    echo "---" | tee -a "$LOG_FILE"
    
    # 添加延迟，避免对服务器造成太大压力
    sleep 1

done < "$ENCODED_URL_FILE"

# 记录结束时间和统计信息
echo "==========================================" | tee -a "$LOG_FILE"
echo "下载结束时间: $(date)" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "总文件数: $total" | tee -a "$LOG_FILE"
echo "成功下载: $success" | tee -a "$LOG_FILE"
echo "下载失败: $fail" | tee -a "$LOG_FILE"

# 使用awk计算成功率（避免bc命令不存在）
if [[ $total -gt 0 ]]; then
    success_rate=$(awk "BEGIN {printf \"%.2f%%\", $success * 100 / $total}")
    echo "成功率: ${success_rate}" | tee -a "$LOG_FILE"
else
    echo "成功率: 0%" | tee -a "$LOG_FILE"
fi

# 输出下载目录的内容和实际文件数
actual_files=$(ls -1 "$DOWNLOAD_DIR" 2>/dev/null | wc -l)
echo "实际下载文件数: $actual_files" | tee -a "$LOG_FILE"

echo "==========================================" | tee -a "$LOG_FILE"
echo "下载目录内容:" | tee -a "$LOG_FILE"
ls -la "$DOWNLOAD_DIR/" | head -15 | tee -a "$LOG_FILE"

# 检查重复文件
echo "==========================================" | tee -a "$LOG_FILE"
echo "检查重复文件..." | tee -a "$LOG_FILE"
ls -1 "$DOWNLOAD_DIR/" | sed 's/^[0-9]*_//' | sort | uniq -d | while read duplicate; do
    count=$(ls -1 "$DOWNLOAD_DIR/" | grep "_${duplicate}$" | wc -l)
    echo "重复文件: $duplicate (出现 $count 次)" | tee -a "$LOG_FILE"
done

# 输出日志文件位置
echo "=========================================="
echo "详细日志: $LOG_FILE"
echo "成功下载列表: $SUCCESS_FILE"
echo "失败下载列表: $FAIL_FILE"
echo "编码后的URL文件: $ENCODED_URL_FILE"
echo "文件下载到: $DOWNLOAD_DIR/"
