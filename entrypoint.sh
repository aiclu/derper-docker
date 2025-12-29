#!/bin/sh
set -euo pipefail

# 打印启动信息
echo "Starting Tailscale DERP server..."

# 设置默认值
DERP_DOMAIN="${DERP_DOMAIN:-your-hostname.com}"
DERP_CERT_MODE="${DERP_CERT_MODE:-letsencrypt}"
DERP_CERT_DIR="${DERP_CERT_DIR:-/app/certs}"
DERP_ADDR="${DERP_ADDR:-:443}"
DERP_STUN="${DERP_STUN:-true}"
DERP_STUN_PORT="${DERP_STUN_PORT:-3478}"
DERP_HTTP_PORT="${DERP_HTTP_PORT:-80}"
DERP_VERIFY_CLIENTS="${DERP_VERIFY_CLIENTS:-false}"
DERP_VERIFY_CLIENT_URL="${DERP_VERIFY_CLIENT_URL:-}"

# 创建证书目录（如果不存在）
mkdir -p "${DERP_CERT_DIR}"

# 检查必需参数
if [ -z "${DERP_DOMAIN}" ] || [ "${DERP_DOMAIN}" = "your-hostname.com" ]; then
    echo "ERROR: DERP_DOMAIN must be set to a valid domain name"
    echo "Set via: -e DERP_DOMAIN=your.domain.com"
    exit 1
fi

# 打印配置信息
echo "=== DERP Server Configuration ==="
echo "Domain:            ${DERP_DOMAIN}"
echo "Cert Mode:         ${DERP_CERT_MODE}"
echo "Cert Directory:    ${DERP_CERT_DIR}"
echo "Listen Address:    ${DERP_ADDR}"
echo "STUN Enabled:      ${DERP_STUN}"
echo "STUN Port:         ${DERP_STUN_PORT}"
echo "HTTP Port:         ${DERP_HTTP_PORT}"
echo "Verify Clients:    ${DERP_VERIFY_CLIENTS}"
if [ -n "${DERP_VERIFY_CLIENT_URL}" ]; then
    echo "Verify Client URL: ${DERP_VERIFY_CLIENT_URL}"
fi
echo "================================"

# 构建参数数组
ARGS=(
    "--hostname=${DERP_DOMAIN}"
    "--certmode=${DERP_CERT_MODE}"
    "--certdir=${DERP_CERT_DIR}"
    "--a=${DERP_ADDR}"
    "--http-port=${DERP_HTTP_PORT}"
)

# 添加 STUN 参数
if [ "${DERP_STUN}" = "true" ]; then
    ARGS+=("--stun")
    ARGS+=("--stun-port=${DERP_STUN_PORT}")
fi

# 添加客户端验证参数
if [ "${DERP_VERIFY_CLIENTS}" = "true" ]; then
    ARGS+=("--verify-clients")
    if [ -n "${DERP_VERIFY_CLIENT_URL}" ]; then
        ARGS+=("--verify-client-url=${DERP_VERIFY_CLIENT_URL}")
    fi
fi

# 添加额外参数（如果有）
if [ -n "${EXTRA_ARGS}" ]; then
    # 分割额外参数
    IFS=' ' read -r -a EXTRA <<< "${EXTRA_ARGS}"
    ARGS+=("${EXTRA[@]}")
fi

# 调试模式
if [ "${DEBUG:-false}" = "true" ]; then
    echo "Debug: Command to execute:"
    echo "/app/derper ${ARGS[*]}"
    echo "================================"
fi

# 执行命令
exec /app/derper "${ARGS[@]}"
