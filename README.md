# URL 文件下载工具 (Bash版)

一个强大的批量文件下载工具，支持从URL列表下载图片和文件，自动重命名防止文件覆盖，并提供详细的下载日志。

## 📋 功能特性

- ✅ **批量下载**: 从 `files/file.txt` 中读取URL列表，自动批量下载
- ✅ **智能命名**: 自动添加数字序号前缀，防止文件重名覆盖
- ✅ **URL编码**: 自动处理URL中的特殊字符（空格、括号等）
- ✅ **重名保护**: 多重保护机制确保文件不会意外覆盖
- ✅ **详细日志**: 完整记录下载过程、成功/失败列表
- ✅ **错误恢复**: 支持重试机制和超时处理
- ✅ **文件验证**: 检查下载文件的完整性
- ✅ **统计分析**: 提供下载成功率等统计信息

## 🚀 快速开始

### 1. 准备URL列表

将需要下载的文件URL，一行一个，添加到 `files/file.txt` 中：

```bash
# files/file.txt 示例内容
https://example.com/image1.jpg
https://example.com/images/photo (1).png
https://example.com/files/document.pdf
```

### 2. 运行脚本

```bash
chmod +x url_download_scripts_v4.sh
./url_download_scripts_v4.sh
```

### 3. 查看下载结果

- 下载的文件保存在: `files/downloads/` 目录
- 查看详细日志: `logs/download.log`
- 查看成功列表: `logs/success.log`
- 查看失败列表: `logs/fail.log`

## 📁 目录结构

```
.
├── url_download_scripts_v4.sh    # 主下载脚本
├── README.md                     # 说明文档
├── files/
│   ├── file.txt                 # URL列表文件（需要手动编辑）
│   ├── encoded_urls.txt         # 编码后的URL（自动生成）
│   └── downloads/               # 下载文件存放目录
└── logs/
    ├── download.log             # 详细下载日志
    ├── success.log              # 成功下载列表
    └── fail.log                 # 失败下载列表
```

## 🔧 文件命名规则

下载的文件会按以下规则重命名：

- **格式**: `{序号}_{原始文件名}`
- **示例**:
  - `1_image1.jpg`
  - `2_photo (1).png`
  - `3_document.pdf`

如果出现重名冲突，会自动添加时间戳：
- `4_document_20250618_143022.pdf`

## 📊 日志文件说明

### download.log
完整的下载过程日志，包含：
- 下载开始/结束时间
- 每个文件的处理详情
- 成功/失败状态
- 文件大小信息
- 重复文件检查结果

### success.log
记录成功下载的文件信息：
```
https://example.com/image1.jpg -> files/downloads/1_image1.jpg (102400 bytes)
```

### fail.log
记录下载失败的URL：
```
https://failed-example.com/missing.jpg
https://timeout-example.com/large-file.pdf
```

## ⚙️ 配置选项

脚本中的可配置参数：

```bash
# 文件路径配置
URL_FILE="files/file.txt"                    # URL列表文件
ENCODED_URL_FILE="files/encoded_urls.txt"    # 编码URL保存文件
LOG_FILE="logs/download.log"                 # 主日志文件
SUCCESS_FILE="logs/success.log"              # 成功日志
FAIL_FILE="logs/fail.log"                    # 失败日志
DOWNLOAD_DIR="files/downloads"               # 下载目录

# wget参数配置
--timeout=30        # 下载超时时间（秒）
--tries=3           # 重试次数
sleep 1             # 下载间隔（秒）
```

## 🛠️ 环境要求

- **操作系统**: Linux/macOS/Windows (WSL)
- **必需工具**: `wget`, `awk`, `sed`
- **Bash版本**: 4.0+

### 检查依赖
```bash
which wget awk sed
```

## 📝 使用示例

### 示例1：下载图片
```bash
# 创建URL列表
echo "https://picsum.photos/800/600" > files/file.txt
echo "https://picsum.photos/900/700" >> files/file.txt

# 运行下载脚本
./url_download_scripts_v4.sh
```

### 示例2：批量处理
```bash
# 使用curl下载URL列表
curl -s "https://api.example.com/images" | jq -r '.[].url' > files/file.txt

# 批量下载
./url_download_scripts_v4.sh

# 检查结果
echo "成功下载: $(cat logs/success.log | wc -l) 个文件"
echo "失败数量: $(cat logs/fail.log | wc -l) 个文件"
```

## 🔍 故障排除

### 常见问题

1. **下载失败率高**
   - 检查网络连接
   - 验证URL是否有效
   - 考虑增加超时时间

2. **文件为空或损坏**
   - 脚本会自动检测并删除空文件
   - 检查 `logs/fail.log` 获取详细信息

3. **权限问题**
   ```bash
   chmod +x url_download_scripts_v4.sh
   chmod -R 755 files/ logs/
   ```

### 清理缓存
```bash
# 清理下载的文件
rm -rf files/downloads/*

# 清理日志文件
> logs/download.log
> logs/success.log
> logs/fail.log
> files/encoded_urls.txt
```

## 📈 性能特点

- **内存友好**: 逐行处理，不会占用大量内存
- **网络友好**: 内置1秒延迟，避免对服务器造成压力
- **错误处理**: 自动重试和异常恢复
- **并发控制**: 单线程下载，保证稳定性

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👤 作者

- **Author**: vxhs888p
- **Organization**: linuxjk.cn
- **Version**: V4.0

---

**⚠️ 注意**: 请遵守相关网站的 robots.txt 和使用条款，合理使用下载工具。