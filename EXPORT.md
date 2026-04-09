# 项目导出指南

将 newapi-termux 项目从手机导出到电脑的方法。

## 方法1: 压缩打包后传输（推荐）

### 步骤1: 在Termux中打包

```bash
cd ~
tar -czvf newapi-termux.tar.gz newapi-termux/
```

### 步骤2: 传输到电脑

**方式A - 使用termux-storage（推荐）**

```bash
# 将文件复制到手机共享存储
cp newapi-termux.tar.gz ~/storage/shared/Download/

# 然后在手机文件管理器中找到并分享
# 路径: /storage/emulated/0/Download/newapi-termux.tar.gz
```

**方式B - 使用Python HTTP服务器**

```bash
cd ~
# 启动临时HTTP服务器
python3 -m http.server 8080 &

# 在同一WiFi下的电脑上访问:
# http://<手机IP>:8080/newapi-termux.tar.gz
```

**方式C - 使用scp（如果电脑有SSH）**

```bash
# 从Termux推送到电脑
scp newapi-termux.tar.gz 用户名@电脑IP:~/

# 示例:
# scp newapi-termux.tar.gz user@192.168.1.100:~/
```

**方式D - 使用adb（需要USB调试）**

```bash
# 在电脑上运行
adb pull /data/data/com.termux/files/home/newapi-termux.tar.gz ./
```

### 步骤3: 在电脑上解压

```bash
# 在电脑上
tar -xzvf newapi-termux.tar.gz
```

---

## 方法2: 使用GitHub（需要Git配置）

### 步骤1: 检查Git配置

```bash
# 检查是否已配置
git config --global user.name
git config --global user.email

# 如果未配置，先设置:
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### 步骤2: 初始化并推送

```bash
cd ~/newapi-termux

# 初始化git仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: NEW API Termux"

# 添加远程仓库（替换为你的用户名）
git remote add origin https://github.com/你的用户名/newapi-termux.git

# 推送
git push -u origin main
```

如果提示输入密码，需要使用GitHub Personal Access Token:
1. 访问 https://github.com/settings/tokens
2. 生成新的Token（选择repo权限）
3. 用Token代替密码输入

---

## 方法3: 使用Termux文件传输工具

### 安装dufs（文件服务器）

```bash
pkg install dufs

# 启动文件服务器
dufs --port 5000 ~/

# 在电脑浏览器访问: http://<手机IP>:5000
# 下载 newapi-termux 文件夹
```

---

## 方法4: 使用在线存储

### 上传到GitHub Gist或类似服务

```bash
# 创建单文件归档
cd ~
zip -r newapi-termux.zip newapi-termux/

# 然后使用任何文件传输工具:
# - 微信文件传输助手
# - QQ文件传输
# - Telegram文件
# - 百度网盘
# 等...
```

---

## 方法5: 直接复制文件内容

如果只需要几个关键文件，可以直接复制内容：

```bash
# 查看install.sh内容
cat ~/newapi-termux/install.sh

# 然后长按选择并复制
# 在电脑上粘贴到新文件
```

---

## 推荐方案总结

| 方法 | 难度 | 速度 | 适用场景 |
|------|------|------|----------|
| **方法1A** (storage) | ⭐ 简单 | ⭐⭐⭐ 快 | 最推荐，手机自带 |
| **方法1B** (HTTP) | ⭐⭐ 中等 | ⭐⭐⭐ 快 | 局域网传输 |
| **方法2** (GitHub) | ⭐⭐⭐ 复杂 | ⭐⭐ 中等 | 需要版本管理 |
| **方法3** (dufs) | ⭐⭐ 中等 | ⭐⭐⭐ 快 | 需要安装dufs |
| **方法5** (复制) | ⭐ 简单 | ⭐ 慢 | 仅几个文件 |

---

## 最快步骤示例

```bash
# 1. 打包
cd ~ && tar -czvf newapi-termux.tar.gz newapi-termux/

# 2. 复制到手机存储
cp newapi-termux.tar.gz ~/storage/shared/Download/

# 3. 在手机上用微信/QQ/邮件发送给电脑
# 或者直接用数据线连接电脑复制

# 4. 在电脑上解压
tar -xzvf newapi-termux.tar.gz
```

完成！
