# NEW API Termux

在 Android Termux 上无需 proot 容器运行 [NEW API](https://github.com/QuantumNous/new-api) AI模型网关。

## 技术原理

使用 glibc-runner 动态链接器直接运行 Linux 二进制，存储占用仅 ~200MB，性能原生。

## 环境要求

- Android 7.0+ (推荐 Android 10+)
- Termux (从 [F-Droid](https://f-droid.org) 安装)
- 已安装 glibc-runner

```bash
# 如果未安装 glibc，先运行:
pkg install pacman
pacman -S glibc-runner
```

## 安装

```bash
cd newapi-termux
bash install.sh
source ~/.bashrc
```

## 快速启动

```bash
~/.newapi-termux/bin/newapi-start         # 启动（默认3000端口）
~/.newapi-termux/bin/newapi-start 8080    # 启动（指定端口）
~/.newapi-termux/bin/newapi-stop          # 停止
~/.newapi-termux/bin/newapi-status        # 状态
```

## 访问

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
4. 添加渠道: 点击「渠道」→ 「新增渠道」→ 填写 API Key
5. 创建令牌: 点击「令牌」→ 「新增令牌」→ 获取 Token

## API 调用示例

```bash
curl http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 你的令牌" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

## 数据位置

| 类型 | 路径 |
|------|------|
| 数据库 | ~/one-api.db |
| 安装目录 | ~/.newapi-termux/ |
| 日志 | ~/.newapi-termux/logs/newapi.log |
| 备份 | ~/.newapi-termux/backup/ |

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

## 常见问题

### 服务启动失败
```bash
# 查看日志
tail -f ~/.newapi-termux/logs/newapi.log
```

### 端口被占用
```bash
# 使用其他端口
~/.newapi-termux/bin/newapi-start 8080
```

### 服务被杀死
Android 后台可能杀死进程，建议使用 tmux:

```bash
pkg install tmux
tmux new -s newapi
~/.newapi-termux/bin/newapi-start
# 按 Ctrl+B 然后按 D 退出 tmux
```

### 忘记管理员密码
```bash
# 删除数据库重新配置
rm ~/one-api.db
~/.newapi-termux/bin/newapi-stop
~/.newapi-termux/bin/newapi-start
```

## 后台运行（推荐）

```bash
# 安装 tmux
pkg install tmux

# 创建会话并启动
tmux new -s newapi
~/.newapi-termux/bin/newapi-start
# 按 Ctrl+B 然后按 D 退出 tmux

# 重新进入
tmux attach -t newapi

# 停止服务后删除会话
tmux kill-session -t newapi
```

## 项目结构

```
newapi-termux/
├── install.sh                 # 主安装脚本
├── README.md                  # 说明文档
├── platforms/
│   └── newapi/
│       ├── config.env         # 平台配置
│       └── install.sh         # 平台安装脚本
└── scripts/
    ├── lib.sh                 # 共享函数库
    ├── backup.sh              # 备份/恢复
    └── update.sh              # 版本更新
```

## 与 OpenClaw 集成

详见 [docs/integration.md](docs/integration.md)

## 许可证

MIT License