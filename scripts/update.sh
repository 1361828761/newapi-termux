#!/usr/bin/env bash
# 更新脚本
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
NEWAPI_BIN="$BIN_DIR/newapi"

echo "=== 更新 NEW API ==="
LATEST=$(curl -s "https://api.github.com/repos/QuantumNous/new-api/releases/latest" 2>/dev/null | grep '"tag_name":' | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
[ -z "$LATEST" ] && { echo "无法获取版本"; exit 1; }
CURRENT=$("$BIN_DIR/newapi-run" --version 2>/dev/null | head -1 || echo "unknown")
echo "当前: $CURRENT | 最新: $LATEST"
[ "$CURRENT" = "$LATEST" ] && { echo "已是最新"; exit 0; }
read -rp "更新? [Y/n] " c; [[ "$c" =~ ^[Nn]$ ]] && exit 0

# 记录当前端口（如果服务在运行）
CURRENT_PORT="3000"
if [ -f "$PROJECT_DIR/newapi.pid" ]; then
    # 尝试从进程获取端口
    CURRENT_PORT=$(netstat -tlnp 2>/dev/null | grep "$(cat "$PROJECT_DIR/newapi.pid")" | grep -o ':[0-9]*' | head -1 | tr -d ':' || echo "3000")
fi

# 执行备份和停止（使用脚本路径而非na命令）
bash "$SCRIPT_DIR/backup.sh"
bash "$BIN_DIR/newapi-stop" 2>/dev/null || true

echo "下载 $LATEST..."
URL="https://github.com/QuantumNous/new-api/releases/download/${LATEST}/new-api-arm64-${LATEST}"
curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "$URL" || curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "https://ghfast.top/$URL"
mv "$NEWAPI_BIN" "$NEWAPI_BIN.bak"
mv "$NEWAPI_BIN.tmp" "$NEWAPI_BIN"
chmod +x "$NEWAPI_BIN"
echo -e "${GREEN}[OK]${NC} 更新完成"
bash "$BIN_DIR/newapi-start" "$CURRENT_PORT"
