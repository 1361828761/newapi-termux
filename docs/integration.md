# 与 OpenClaw on Android 集成指南

本指南说明如何将 NEW API Termux 作为平台插件集成到 openclaw-android 项目中。

## 集成方式

### 方式一: 作为新平台插件 (推荐)

这种方式让 openclaw-android 安装器提供 NEW API 作为可选平台。

#### 步骤

1. **复制平台文件**

```bash
# 复制 newapi 平台到 openclaw-android
cp -r ~/newapi-termux/platforms/newapi \
      ~/.openclaw-android/installer/platforms/

# 复制共享脚本
cp ~/newapi-termux/scripts/lib.sh \
   ~/.openclaw-android/installer/scripts/
```

2. **修改 openclaw-android 的 install.sh**

在 `step 2 "Platform Selection"` 部分，添加平台选择:

```bash
step 2 "Platform Selection"
echo "选择要安装的平台:"
echo "  1) OpenClaw (AI Agent平台)"
echo "  2) NEW API (AI模型网关)"
echo ""
read -rp "请选择 [1-2, 默认1]: " platform_choice < /dev/tty 2>/dev/null || platform_choice="1"

case "$platform_choice" in
    2)
        SELECTED_PLATFORM="newapi"
        echo -e "${GREEN}[OK]${NC} 平台: NEW API"
        ;;
    *)
        SELECTED_PLATFORM="openclaw"
        echo -e "${GREEN}[OK]${NC} 平台: OpenClaw"
        ;;
esac

load_platform_config "$SELECTED_PLATFORM" "$SCRIPT_DIR"
```

3. **修改 openclaw-android 的 oa.sh**

添加 NEW API 命令支持:

```bash
# 在 oa.sh 的命令处理部分添加
"--newapi-start")
    ~/.newapi-termux/bin/newapi-start "${2:-3000}"
    ;;
"--newapi-stop")
    ~/.newapi-termux/bin/newapi-stop
    ;;
"--newapi-status")
    ~/.newapi-termux/bin/newapi-status
    ;;
```

4. **创建联合更新脚本**

创建 `~/.openclaw-android/installer/scripts/update-newapi.sh`:

```bash
#!/usr/bin/env bash
# 更新 NEW API
source "$SCRIPT_DIR/lib.sh"
bash "$NEWAPI_DIR/scripts/update.sh"
```

### 方式二: 作为可选工具

这种方式让 NEW API 作为可选组件，与 OpenClaw 一起安装。

#### 步骤

1. **添加工具选择**

在 openclaw-android 的 `install.sh` 的 L3 步骤中添加:

```bash
step 3 "Optional Tools Selection (L3)"
# ... 现有选项 ...
INSTALL_NEWAPI=false

# ... 现有询问 ...
if ask_yn "Install NEW API (AI model gateway, ~50MB)?"; then
    INSTALL_NEWAPI=true
fi
```

2. **添加安装步骤**

在平台安装步骤后添加:

```bash
step 7 "Install NEW API"
if [ "$INSTALL_NEWAPI" = true ]; then
    bash "$SCRIPT_DIR/platforms/newapi/install.sh"
fi
```

3. **添加更新支持**

在 `update-core.sh` 中添加:

```bash
# 在 Update Optional Tools 部分
if [ -d "$HOME/.newapi-termux" ]; then
    echo ""
    echo "更新 NEW API..."
    bash "$SCRIPT_DIR/platforms/newapi/update.sh" || true
fi
```

### 方式三: 独立安装 (当前方式)

保持 NEW API Termux 作为独立项目，用户分别安装。

优点:
- 两个项目独立维护
- 用户可自由选择
- 无依赖冲突

缺点:
- 需要分别更新
- 无统一界面

## 数据共享

### SQLite 数据库位置

两种安装方式的数据库位置相同:
- 位置: `~/one-api.db`
- 配置: `~/.newapi-termux/`

### 备份兼容

openclaw-android 的备份系统可以扩展支持 NEW API:

```bash
# 在 backup.sh 中添加
if [ -d "$HOME/.newapi-termux" ]; then
    echo "备份 NEW API 数据..."
    # 数据库
    [ -f "$HOME/one-api.db" ] && cp "$HOME/one-api.db" "$BACKUP_DIR/"
    # 配置
    [ -d "$HOME/.newapi-termux/data" ] && cp -r "$HOME/.newapi-termux/data" "$BACKUP_DIR/"
fi
```

## 统一 CLI

可以创建一个统一的命令入口 `oc` (OpenClaw) 和 `na` (NEW API):

```bash
# ~/.openclaw-android/bin/oc-newapi
case "$1" in
    start) ~/.newapi-termux/bin/newapi-start "${2:-3000}" ;;
    stop) ~/.newapi-termux/bin/newapi-stop ;;
    status) ~/.newapi-termux/bin/newapi-status ;;
    *) echo "用法: oc newapi {start|stop|status}" ;;
esac
```

## 配置文件示例

### platforms/newapi/config.env

```bash
PLATFORM_NAME="newapi"
PLATFORM_DISPLAY_NAME="NEW API"
PLATFORM_VERSION="1.0.0"
PLATFORM_NEEDS_GLIBC=true
PLATFORM_NEEDS_NODEJS=false
PLATFORM_NEEDS_BUILD_TOOLS=false
PLATFORM_DEFAULT_PORT=3000
```

## 测试集成

1. 完整卸载测试:
```bash
oa --uninstall
rm -rf ~/.newapi-termux ~/.openclaw-android
```

2. 重新安装测试:
```bash
curl -sL myopenclawhub.com/install | bash
# 选择安装 NEW API
```

3. 验证功能:
```bash
na start
curl http://localhost:3000
na stop
```

## 维护建议

- 保持 `lib.sh` 兼容
- 版本号同步
- 共享 glibc 环境
- 统一的备份机制
