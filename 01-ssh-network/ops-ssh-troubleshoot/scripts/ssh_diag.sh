#!/usr/bin/env bash
# 一键 SSH 故障诊断脚本
# 适用：在客户端运行，诊断到目标服务器 SSH 连接问题
# 用法：./ssh_diag.sh <target_ip> [target_port]

set -u

TARGET="${1:?Usage: $0 <target_ip> [port]}"
PORT="${2:-22}"
USER="${USER:-$(whoami)}"

echo "=========================================="
echo "SSH 诊断 - 目标: ${TARGET}:${PORT}"
echo "执行用户: ${USER}"
echo "执行时间: $(date '+%F %T')"
echo "=========================================="

# Layer 1: 网络层
echo ""
echo "[Layer 1] 网络连通性测试"
echo "--- ping ---"
ping -c 3 -W 2 "${TARGET}" 2>&1 | tail -5
PING_RESULT=$?

echo ""
echo "--- 路由追踪（最多 10 跳）---"
if command -v mtr >/dev/null 2>&1; then
    mtr -n -r -c 3 "${TARGET}" 2>&1 | head -15
else
    echo "mtr 未安装，跳过"
fi

# Layer 2: 端口层
echo ""
echo "[Layer 2] 端口可达性测试"
echo "--- TCP 端口探测 ---"
if command -v nc >/dev/null 2>&1; then
    nc -zv -w 5 "${TARGET}" "${PORT}" 2>&1
    NC_RESULT=$?
else
    echo "nc 未安装"
    NC_RESULT=1
fi

# Layer 3: 服务 banner
echo ""
echo "[Layer 3] SSH 服务 banner"
echo "--- 抓取 SSH 协议版本 ---"
timeout 5 bash -c "echo '' | nc -w 3 ${TARGET} ${PORT}" 2>&1 | head -3

# Layer 4: 认证配置
echo ""
echo "[Layer 4] 客户端 SSH 配置检查"
echo "--- ~/.ssh 权限 ---"
ls -la ~/.ssh/ 2>&1 | head -10

echo ""
echo "--- 已加载的 key ---"
ssh-add -l 2>&1 || echo "ssh-agent 未运行或无 key"

echo ""
echo "--- SSH 客户端配置（关键项）---"
grep -E "^(Host|User|Port|IdentityFile|PreferredAuthentications)" ~/.ssh/config 2>/dev/null | head -10 || echo "无 ~/.ssh/config"

# 汇总
echo ""
echo "=========================================="
echo "诊断汇总"
echo "=========================================="
echo "ping 结果: $([ ${PING_RESULT} -eq 0 ] && echo 'OK' || echo 'FAIL')"
echo "端口 ${PORT}: $([ ${NC_RESULT} -eq 0 ] && echo 'OK' || echo 'FAIL')"
echo ""
echo "下一步建议："
if [ ${PING_RESULT} -ne 0 ]; then
    echo "  → 网络层问题，检查路由/防火墙"
elif [ ${NC_RESULT} -ne 0 ]; then
    echo "  → 端口层问题，安全组/防火墙未放行 ${PORT}"
else
    echo "  → 网络端口正常，问题在 SSH 服务/认证层"
    echo "  → 建议: ssh -vvv ${USER}@${TARGET} -p ${PORT} 看详细日志"
fi