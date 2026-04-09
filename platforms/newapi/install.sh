#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib.sh"

echo "=== 安装 NEW API ==="
NEWAPI_VERSION="v0.12.6"
PROJECT_DIR="${PROJECT_DIR:-$HOME/.newapi-termux}"
BIN_DIR="${BIN_DIR:-$PROJECT_DIR/bin}"
NEWAPI_BIN="$BIN_DIR/newapi"
GLIBC_LDSO="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
mkdir -p "$BIN_DIR" "$PROJECT_DIR"/{data,logs,backup,scripts}

# 复制脚本文件
cp "$SCRIPT_DIR/../../scripts/lib.sh" "$PROJECT_DIR/scripts/"
cp "$SCRIPT_DIR/../../scripts/backup.sh" "$PROJECT_DIR/scripts/"
cp "$SCRIPT_DIR/../../scripts/update.sh" "$PROJECT_DIR/scripts/"
chmod +x "$PROJECT_DIR/scripts/"*.sh

# 下载二进制
if [ ! -f "$NEWAPI_BIN" ]; then
    echo "下载 NEW API $NEWAPI_VERSION..."
    URL="https://github.com/QuantumNous/new-api/releases/download/${NEWAPI_VERSION}/new-api-arm64-${NEWAPI_VERSION}"
    curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "$URL" || curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "https://ghfast.top/$URL"
    mv "$NEWAPI_BIN.tmp" "$NEWAPI_BIN"
    chmod +x "$NEWAPI_BIN"
    echo -e "${GREEN}[OK]${NC} 下载完成"
fi

# 创建wrapper
cat > "$BIN_DIR/newapi-run" << EOF
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
export HOME="$HOME"
export NEWAPI_DATA_DIR="$PROJECT_DIR/data"
export NEWAPI_LOG_DIR="$PROJECT_DIR/logs"
exec "$GLIBC_LDSO" --library-path "$PREFIX/glibc/lib" "$NEWAPI_BIN" "\$@"
EOF
chmod +x "$BIN_DIR/newapi-run"

# 创建启动脚本 (使用动态生成避免单引号变量问题)
cat > "$BIN_DIR/newapi-start" << EOF
#!/data/data/com.termux/files/usr/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
PROJECT_DIR="\$HOME/.newapi-termux"; BIN="\$PROJECT_DIR/bin"
PIDFILE="\$PROJECT_DIR/newapi.pid"; PORT="\${1:-3000}"
[ -f "\$PIDFILE" ] && { kill -0 "\$(cat \$PIDFILE)" 2>/dev/null && { echo "已在运行"; exit 0; } || rm -f "\$PIDFILE"; }
mkdir -p "\$PROJECT_DIR/logs"
nohup "\$BIN/newapi-run" --port "\$PORT" >> "\$PROJECT_DIR/logs/newapi.log" 2>&1 &
echo \$! > "\$PIDFILE"; sleep 2
kill -0 "\$(cat \$PIDFILE)" 2>/dev/null && echo -e "\${GREEN}[OK]\${NC} 启动: http://localhost:\$PORT" || { echo -e "\${RED}[FAIL]\${NC} 启动失败"; exit 1; }
EOF
chmod +x "$BIN_DIR/newapi-start"

# 创建停止脚本
cat > "$BIN_DIR/newapi-stop" << 'STOP'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.newapi-termux/newapi.pid"
[ -f "$PIDFILE" ] && { kill "$(cat "$PIDFILE")" 2>/dev/null && echo "已停止"; rm -f "$PIDFILE"; } || echo "未运行"
STOP
chmod +x "$BIN_DIR/newapi-stop"

# 创建状态脚本
cat > "$BIN_DIR/newapi-status" << 'STATUS'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.newapi-termux/newapi.pid"
[ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null && echo -e "\033[0;32m运行中\033[0m (PID: $(cat "$PIDFILE"))" || echo -e "\033[0;33m未运行\033[0m"
STATUS
chmod +x "$BIN_DIR/newapi-status"

echo -e "${GREEN}[OK]${NC} 安装完成"
echo "命令: newapi-start [端口] | newapi-stop | newapi-status"
