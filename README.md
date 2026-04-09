# NEW API Termux 操作手册

## 快速启动

```bash
# 启动服务（默认端口3000）
~/.newapi-termux/bin/newapi-start

# 或者带端口
~/.newapi-termux/bin/newapi-start 8080
```

## 启停命令

| 操作 | 命令 |
|------|------|
| 启动 | `~/.newapi-termux/bin/newapi-start` |
| 启动(指定端口) | `~/.newapi-termux/bin/newapi-start 3001` |
| 停止 | `~/.newapi-termux/bin/newapi-stop` |
| 查看状态 | `~/.newapi-termux/bin/newapi-status` |
| 查看日志 | `tail -f ~/.newapi-termux/logs/newapi.log` |

## 访问地址

| 方式 | 地址 |
|------|------|
| 本地 | http://localhost:3000 |
| 局域网 | http://\<手机IP\>:3000 |

查看手机IP:
```bash
ip route get 8.8.8.8 | awk '{print $7}'
```

## 首次配置

1. 启动服务: `~/.newapi-termux/bin/newapi-start`
2. 浏览器访问 `http://localhost:3000`
3. 设置管理员账号密码
4. 添加渠道: 点击「渠道」→「新增渠道」→「填写API Key」
5. 创建令牌: 点击「令牌」→「新增令牌」→「获取Token」

## 备份与恢复

```bash
# 备份
~/.newapi-termux/scripts/backup.sh

# 恢复
~/.newapi-termux/scripts/backup.sh restore
```

## 更新版本

```bash
~/.newapi-termux/scripts/update.sh
```

## 数据位置

| 类型 | 路径 |
|------|------|
| 数据库 | ~/one-api.db |
| 安装目录 | ~/.newapi-termux/ |
| 日志 | ~/.newapi-termux/logs/newapi.log |
| 备份 | ~/.newapi-termux/backup/ |

## 常见问题

### 服务启动失败
```bash
tail -f ~/.newapi-termux/logs/newapi.log
```

### 端口被占用
```bash
~/.newapi-termux/bin/newapi-start 8080
```

### 服务被杀死（使用tmux保持运行）
```bash
pkg install tmux
tmux new -s newapi
~/.newapi-termux/bin/newapi-start
# 按 Ctrl+B 然后按 D 退出tmux
```

### 忘记管理员密码
```bash
rm ~/one-api.db
~/.newapi-termux/bin/newapi-stop
~/.newapi-termux/bin/newapi-start
```

## 目录说明

| 目录 | 说明 |
|------|------|
| `~/newapi-termux/` | 项目源代码目录（你下载的那个） |
| `~/.newapi-termux/` | 实际安装目录（运行程序在这里） |
| `~/.newapi-termux/bin/` | 启停脚本和程序 |
| `~/.newapi-termux/scripts/` | 备份更新脚本 |
| `~/.newapi-termux/logs/` | 运行日志 |
| `~/.newapi-termux/data/` | 配置数据 |
| `~/one-api.db` | SQLite数据库 |

## 安装新项目（从电脑拷贝后）

```bash
cd ~/newapi-termux
bash install.sh
```

这会在 `~/.newapi-termux/` 创建 bin 目录并安装程序。