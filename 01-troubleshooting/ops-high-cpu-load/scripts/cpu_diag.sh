#!/usr/bin/env bash
# ============================================================
# CPU 负载一键诊断脚本
# 收集系统负载、TOP 进程、热点线程、上下文切换
# 输出适合贴工单或反馈
# ============================================================

set -euo pipefail

echo "════════════════════════════════════════"
echo "  CPU 负载诊断报告 v1.0"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  主机: $(hostname)"
echo "════════════════════════════════════════"
echo ""

# 1. 系统总体负载
echo "┌─ [1] 系统负载 ─────────────────────┐"
echo ""
echo "▶ uptime:"
uptime
echo ""

echo "▶ CPU 核数:"
echo "  nproc: $(nproc)"
echo "  /proc/cpuinfo: $(grep -c ^processor /proc/cpuinfo) 核"
echo ""

echo "▶ CPU 使用率（mpstat 1 3 平均）:"
if command -v mpstat > /dev/null 2>&1; then
    mpstat 1 3 | tail -3
else
    top -bn1 | grep -E "^%?Cpu" | head -3
fi
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 2. 内存和交换
echo "┌─ [2] 内存状态 ─────────────────────┐"
echo ""
free -h
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 3. TOP 进程（按 CPU）
echo "┌─ [3] TOP 10 进程（按 CPU）─────────────┐"
echo ""
ps aux --sort=-%cpu | head -11
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 4. TOP 进程（按内存）
echo "┌─ [4] TOP 10 进程（按内存）─────────────┐"
echo ""
ps aux --sort=-%mem | head -11
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 5. 热点线程
echo "┌─ [5] 热点线程 TOP 15 ────────────────┐"
echo ""
ps -eLo pid,tid,pcpu,stat,comm --sort=-pcpu | head -16
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 6. 上下文切换和中断
echo "┌─ [6] 上下文切换 ─────────────────────┐"
echo ""
if command -v vmstat > /dev/null 2>&1; then
    vmstat 1 3
else
    echo "vmstat 未安装"
fi
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 7. 系统调用最多进程
echo "┌─ [7] 中断统计（softirq） ────────────┐"
echo ""
cat /proc/softirqs 2>/dev/null | head -10
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 8. D 状态进程（不可中断睡眠，通常是 IO 卡住）
echo "┌─ [8] D 状态进程（IO 卡住） ─────────┐"
echo ""
ps -eo stat,pid,user,cmd | awk '$1 ~ /D/' | head -10
echo ""
echo "└────────────────────────────────────┘"
echo ""

# 9. 进程树（前 3 层）
echo "┌─ [9] 进程树（前 3 层） ─────────────┐"
echo ""
if command -v pstree > /dev/null 2>&1; then
    pstree -p | head -30
else
    ps -ef --forest | head -30
fi
echo ""
echo "└────────────────────────────────────┘"
echo ""

echo "════════════════════════════════════════"
echo "  排查建议"
echo "════════════════════════════════════════"
echo ""
echo "1. 如果 load > CPU 核数:"
echo "   - 单进程 CPU 高: 抓栈分析（jstack / strace / perf）"
echo "   - iowait 高: 排查磁盘（iostat / iotop）"
echo ""
echo "2. 如果 us% > 80%:"
echo "   - 应用层问题，看 TOP 进程"
echo "   - 抓栈定位"
echo ""
echo "3. 如果 sy% > 20%:"
echo "   - 内核态高，可能是系统调用过多"
echo "   - 软中断高：检查网卡/磁盘"
echo ""
echo "4. 如果 wa% > 20%:"
echo "   - 卡 IO，跳到磁盘排查"
echo "   - 看是否有 D 状态进程"
echo ""
echo "5. 上下文切换 > 10000/s:"
echo "   - 进程/线程数过多"
echo "   - 锁竞争"
echo ""
echo "════════════════════════════════════════"