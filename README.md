# OpenClaw 一键部署

## 上传步骤（5分钟）

### 1. 创建 GitHub 仓库
1. 登录 github.com（用 karinecsy@gmail.com）
2. 右上角 + → New repository
3. Repository name 填：`openclaw-deploy`
4. 勾选 **Public**
5. 点击 Create repository

### 2. 上传文件
把以下文件上传到仓库根目录：
- `install.command`（Mac 一键安装脚本）
- `index.html`（落地页）

Skills 文件夹：创建 `skills/` 目录，把各个 skill 的 SKILL.md 放进去
```
skills/
├── weather/SKILL.md
├── yahoo-finance/SKILL.md
├── pptx/SKILL.md
└── ...
```

### 3. 开启 GitHub Pages（落地页托管）
1. 仓库页面 → Settings → Pages
2. Source 选 Deploy from a branch
3. Branch 选 main，目录选 / (root)
4. Save
5. 等 1~2 分钟，访问 `https://karinecsy.github.io/openclaw-deploy/`

### 4. 用户安装流程
用户访问你的网站 → 点击「一键安装（Mac）」→ 下载 install.command → 双击运行

### 注意
- macOS 首次运行 .command 文件需要右键 → 打开（绕过 Gatekeeper）
- 可在安装说明页加上这个提示

## 文件说明
- `install.command` - Mac 一键安装脚本（交互式，自动配置所有内容）
- `index.html` - 产品落地页
