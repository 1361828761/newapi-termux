#!/usr/bin/env bash
# 备份/恢复脚本
set -euo pipefail
NEWAPI_DIR="$HOME/.newapi-termux"; BACKUP_DIR="$NEWAPI_DIR/backup"; DB="$HOME/one-api.db"

backup() {
    echo "=== 备份数据 ==="
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FILE="$BACKUP_DIR/newapi-${TIMESTAMP}.tar.gz"
    [ -f "$DB" ] || { echo "数据库不存在"; exit 1; }
    tar -czf "$FILE" -C "$HOME" "$(basename "$DB")" 2>/dev/null && echo "备份完成: $FILE" || echo "备份失败"
}

restore() {
    echo "=== 恢复数据 ==="
    BACKUPS=($(ls -1t "$BACKUP_DIR"/newapi-*.tar.gz 2>/dev/null))
    [ ${#BACKUPS[@]} -eq 0 ] && { echo "无可用备份"; exit 1; }
    for i in "${!BACKUPS[@]}"; do echo "[$((i+1))] $(basename "${BACKUPS[$i]}")"; done
    read -rp "选择: " n
    [ "$n" -ge 1 ] && [ "$n" -le ${#BACKUPS[@]} ] || { echo "无效选择"; exit 1; }
    read -rp "确认恢复? [y/N] " c; [[ ! "$c" =~ ^[Yy]$ ]] && { echo "取消"; exit 0; }
    "$NEWAPI_DIR/bin/newapi-stop" 2>/dev/null || true
    tar -xzf "${BACKUPS[$((n-1))]}" -C "$HOME" && echo "恢复完成" || echo "恢复失败"
}

case "${1:-backup}" in
    backup) backup ;;
    restore) restore ;;
    *) echo "用法: $0 {backup|restore}" ;;
esac
