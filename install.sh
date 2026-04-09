#!/usr/bin/env bash
# install.sh - 主安装脚本
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"
PROJECT_DIR="$HOME/.newapi-termux"

echo "======================================"
echo -e "${BOLD}NEW API Termux 安装器${NC}"
echo "======================================"
echo ""

# [1/4] 检查
echo "[1/4] 环境检查..."
[ -z "${PREFIX:-}" ] && { echo -e "${RED}[FAIL]${NC} 请在Termux中运行"; exit 1; }
[ "$(uname -m)" != "aarch64" ] && { echo -e "${RED}[FAIL]${NC} 需要aarch64架构"; exit 1; }
check_glibc
echo -e "${GREEN}[OK]${NC} 环境正常"

# [2/4] 依赖
echo "[2/4] 安装依赖..."
for cmd in curl jq; do command -v $cmd &>/dev/null || pkg install -y $cmd; done
echo -e "${GREEN}[OK]${NC} 依赖就绪"

# [3/4] 平台安装
echo "[3/4] 安装平台..."
bash "$SCRIPT_DIR/platforms/newapi/install.sh"

# [4/4] CLI工具
echo "[4/4] 安装CLI..."
cat > "$PREFIX/bin/na" << 'NA'
#!/data/data/com.termux/files/usr/bin/bash
NEWAPI_DIR="$HOME/.newapi-termux"; BIN="$NEWAPI_DIR/bin"
case "${1:-}" in
    start|-s) shift; "$BIN/newapi-start" "${1:-3000}" ;;
    stop|-p) "$BIN/newapi-stop" ;;
    restart) "$BIN/newapi-stop" 2>/dev/null; sleep 1; "$BIN/newapi-start" "${2:-3000}" ;;
    status) "$BIN/newapi-status" ;;
    log) tail -f "$NEWAPI_DIR/logs/newapi.log" ;;
    backup) bash "$NEWAPI_DIR/scripts/backup.sh" ;;
    restore) bash "$NEWAPI_DIR/scripts/backup.sh" restore ;;
    update) bash "$NEWAPI_DIR/scripts/update.sh" ;;
    uninstall) 
  read -rp "确定卸载? 数据将保留在 $NEWAPI_DIR/data/ [y/N] " c
  [[ "$c" =~ ^[Yy]$ ]] && { 
    "$BIN/newapi-stop" 2>/dev/null || true
    rm -rf "$NEWAPI_DIR/bin" "$PREFIX/bin/na"
    # 清理.bashrc
    sed -i '/newapi-termux/d' "$HOME/.bashrc" 2>/dev/null || true
    echo "已卸载 (数据保留在 $NEWAPI_DIR/data/)"
  } 
  ;;
    help|-h|*) echo "用法: na {start|stop|restart|status|log|backup|restore|update|uninstall}" ;;
esac
NA
chmod +x "$PREFIX/bin/na"

# 环境配置
if ! grep -q "newapi-termux" "$HOME/.bashrc" 2>/dev/null; then
  echo "PATH=\"$PROJECT_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

echo ""
echo "======================================"
echo -e "${GREEN}${BOLD}安装完成!${NC}"
echo "======================================"
echo "命令: na start [端口] | na stop | na status"
echo "访问: http://localhost:3000"
echo "注意: 首次访问需设置管理员账号"
