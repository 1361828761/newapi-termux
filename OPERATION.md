# NEW API Termux 操作手册

## 快速启动

```bash
# 方法1: 使用CLI工具 (推荐)
source ~/.bashrc
na start

# 方法2: 直接运行
~/.newapi-termux/bin/newapi-start
```

## 命令详解

### 启动服务
```bash
na start           # 默认端口 3000
na start 8080      # 指定端口 8080
```

### 停止服务
```bash
na stop
```

### 重启服务
```bash
na restart         # 重启并使用默认端口
na restart 3001    # 重启并使用端口 3001
```

### 查看状态
```bash
na status
```

### 查看日志
```bash
na log             # 实时日志
cat ~/.newapi-termux/logs/newapi.log  # 查看完整日志
```

### 备份与恢复
```bash
na backup          # 备份数据库
na restore         # 恢复数据（交互式选择）
```

### 更新版本
```bash
na update          # 检查并更新到最新版本
```

### 卸载
```bash
na uninstall       # 卸载CLI工具（保留数据）
```

## 访问方式

| 方式 | 地址 |
|------|------|
| 本地访问 | http://localhost:3000 |
| 局域网访问 | http://<手机IP>:3000 |

查看手机IP:
```bash
ip route get 8.8.8.8 | awk '{print $7}'
```

## 首次使用

1. 启动服务: `na start`
2. 打开浏览器访问 `http://localhost:3000`
3. 点击"设置管理员账号"，填写账号和密码
4. 登录后添加渠道（Channels）：点击"渠道" → "新增渠道"
5. 添加你的API Key（OpenAI/Claude等）
6. 创建令牌（Tokens）：点击"令牌" → "新增令牌"
7. 使用令牌调用API

## API调用示例

```bash
# 使用令牌调用
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

## 常见问题

### 服务启动失败
```bash
# 查看错误日志
na log

# 检查端口是否被占用
netstat -tlnp | grep 3000
```

### 端口被占用
```bash
na start 8080  # 使用其他端口
```

### 服务意外停止
Android后台可能杀死进程，建议：
- 关闭电池优化
- 允许自启动
- 使用 tmux 保持运行: `tmux new -s newapi && na start`

### 忘记管理员密码
```bash
# 重置密码（需要SQLite工具）
sqlite3 ~/one-api.db "UPDATE users SET password='$2a$10$...' WHERE role=100;"
# 或直接删除数据库重新配置
rm ~/one-api.db
na restart
```

## 后台运行（推荐）

```bash
# 安装 tmux
pkg install tmux

# 创建会话并启动
tmux new -s newapi
na start
# 按 Ctrl+B 然后按 D 退出 tmux

# 重新进入查看
tmux attach -t newapi
```