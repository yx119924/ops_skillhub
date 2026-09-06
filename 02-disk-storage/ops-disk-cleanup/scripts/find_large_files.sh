#!/usr/bin/env bash
# ============================================================
# 大文件查找脚本
# 用法: ./find_large_files.sh [path] [size_threshold] [depth]
#   path: 搜索根目录，默认 /
#   size_threshold: 大小阈值，默认 100M
#   depth: 最大深度，默认 5
# ============================================================

set -euo pipefail

SEARCH_PATH="${1:-/}"
SIZE_THRESHOLD="${2:-100M}"
MAX_DEPTH="${3:-5}"

echo "════════════════════════════════════════"
echo "  大文件查找 v1.0"
echo "════════════════════════════════════════"
echo "搜索路径:    $SEARCH_PATH"
echo "大小阈值:    $SIZE_THRESHOLD"
echo "最大深度:    $MAX_DEPTH"
echo "════════════════════════════════════════"
echo ""

# 转 M 为 KB（find 的 size 单位）
SIZE_KB=$(echo "$SIZE_THRESHOLD" | sed 's/M$/M/' | awk '{
    if ($1 ~ /M$/) {print int($1 * 1024)}
    else if ($1 ~ /G$/) {print int($1 * 1024 * 1024)}
    else if ($1 ~ /K$/) {print int($1)}
    else {print int($1 * 1024 * 1024)}  # 默认按 M 处理
}')

echo "→ 查找大于 ${SIZE_THRESHOLD} 的文件..."
echo ""

# 排除常见不需要查的目录
EXCLUDES=(
    -path "*/proc/*"
    -path "*/sys/*"
    -path "*/dev/*"
    -path "*/run/*"
    -path "*/snap/*"
    -path "*/.git/*"
    -path "*/node_modules/*"
)

# 查找并按大小排序
find "$SEARCH_PATH" \
    -type f \
    -size +${SIZE_THRESHOLD} \
    -maxdepth $MAX_DEPTH \
    \( "${EXCLUDES[@]}" \) -prune -o -type f -size +${SIZE_THRESHOLD} -print 2>/dev/null | \
    xargs -I {} ls -lh {} 2>/dev/null | \
    awk '{print $5, $9}' | \
    sort -hr | head -30

echo ""
echo "════════════════════════════════════════"
echo "  磁盘使用概览"
echo "════════════════════════════════════════"
echo ""
echo "【磁盘空间】"
df -h | head -10
echo ""
echo "【inode 使用率】"
df -i | head -10
echo ""
echo "【根目录下 Top 10 占用】"
du -h --max-depth=1 "$SEARCH_PATH" 2>/dev/null | sort -hr | head -11 | tail -10
echo ""
echo "【/var/log Top 10】"
du -sh /var/log/* 2>/dev/null | sort -hr | head -10 || echo "权限不足或目录为空"
echo ""
echo "【/var/cache Top 10】"
du -sh /var/cache/* 2>/dev/null | sort -hr | head -10 || echo "权限不足或目录为空"
echo ""
echo "════════════════════════════════════════"
echo "  排查建议"
echo "════════════════════════════════════════"
echo ""
echo "1. 如果 /var/log 占满:"
echo "   sudo find /var/log -name '*.gz' -mtime +30 -delete"
echo "   sudo find /var/log -name '*.log.*' -mtime +30 -delete"
echo ""
echo "2. 如果 /var/cache 占满:"
echo "   sudo apt clean"
echo "   sudo yum clean all"
echo ""
echo "3. 如果 Docker 占满:"
echo "   docker system df"
echo "   docker system prune -a"
echo ""
echo "4. 截断正在写入的大日志（比删除安全）:"
echo "   sudo truncate -s 0 /path/to/large.log"
echo ""
echo "5. ⚠️ 永远不要 rm -rf /*，永远不要删 /proc /sys /dev"
echo ""