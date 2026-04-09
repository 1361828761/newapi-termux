#!/usr/bin/env bash
# lib.sh - 共享函数库

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'; BOLD='\033[1m'
PROJECT_DIR="$HOME/.newapi-termux"; BIN_DIR="$PROJECT_DIR/bin"

ask_yn() {
    local prompt="$1" reply
    read -rp "$prompt [Y/n] " reply < /dev/tty 2>/dev/null || reply="y"
    [[ "${reply:-y}" =~ ^[Nn]$ ]] && return 1; return 0
}

detect_platform() {
    [ -f "$PROJECT_DIR/.platform" ] && cat "$PROJECT_DIR/.platform" && return 0
    command -v newapi-start &>/dev/null && echo "newapi" && return 0
    echo ""; return 1
}

check_glibc() {
    [ -x "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" ] && return 0
    echo -e "${RED}[FAIL]${NC} glibc未安装"; echo "运行: pkg install pacman && pacman -S glibc-runner"; exit 1
}
