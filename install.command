#!/bin/bash
# OpenClaw 一键安装 for macOS
# 双击运行，全程自动，最后在浏览器里配置

set -e
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     OpenClaw AI 助手 · 正在安装      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo "  全程自动完成，请不要关闭此窗口..."
echo ""

ok()   { echo -e "  ${GREEN}✓${NC}  $1"; }
info() { echo -e "  ${CYAN}→${NC}  $1"; }
warn() { echo -e "  ${YELLOW}!${NC}  $1"; }

# ── 1. Homebrew ──────────────────────────────────────────────────
info "检查 Homebrew..."
if ! command -v brew &>/dev/null; then
  info "安装 Homebrew（需要输入 Mac 开机密码）..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ "$(uname -m)" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" && \
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi
ok "Homebrew 就绪"

# ── 2. Node.js ───────────────────────────────────────────────────
info "检查 Node.js..."
if ! command -v node &>/dev/null; then
  info "安装 Node.js..."
  brew install node --quiet
fi
ok "Node.js 就绪 ($(node --version))"

# ── 3. OpenClaw ──────────────────────────────────────────────────
info "安装 OpenClaw..."
if ! command -v openclaw &>/dev/null; then
  npm install -g openclaw --silent
fi
ok "OpenClaw 就绪"

# ── 4. 目录 & Workspace ──────────────────────────────────────────
info "初始化工作区..."
mkdir -p ~/.openclaw/workspace/.learnings
mkdir -p ~/.openclaw/workspace/memory
mkdir -p ~/.agents/skills

# 基础配置文件（空配置，等用户在 Dashboard 填写）
if [[ ! -f ~/.openclaw/openclaw.json ]]; then
  cat > ~/.openclaw/openclaw.json << 'EOF'
{
  "gateway": {
    "bind": "loopback",
    "port": 18789
  }
}
EOF
fi

# SOUL.md
[[ -f ~/.openclaw/workspace/SOUL.md ]] || cat > ~/.openclaw/workspace/SOUL.md << 'EOF'
# SOUL.md
Be genuinely helpful. Have opinions. Be resourceful before asking.
EOF

[[ -f ~/.openclaw/workspace/MEMORY.md ]] || echo "# 重要记忆" > ~/.openclaw/workspace/MEMORY.md
[[ -f ~/.openclaw/workspace/.learnings/LEARNINGS.md ]] || echo "# Learnings" > ~/.openclaw/workspace/.learnings/LEARNINGS.md
ok "工作区就绪"

# ── 5. 下载预装 Skills ───────────────────────────────────────────
info "下载预装技能..."
BASE="https://karinecsy-collab.github.io/openclaw-deploy/skills"
SKILLS=(weather yahoo-finance pptx feishu-doc self-improving-agent xiaohongshu)
for s in "${SKILLS[@]}"; do
  mkdir -p ~/.agents/skills/$s
  curl -fsSL "$BASE/$s/SKILL.md" -o ~/.agents/skills/$s/SKILL.md 2>/dev/null && true
done
ok "技能安装完成"

# ── 6. 启动 Gateway ──────────────────────────────────────────────
info "启动 OpenClaw..."
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1
nohup openclaw gateway start > /tmp/openclaw.log 2>&1 &
sleep 4
ok "OpenClaw 已启动"

# ── 7. 开机自启 ──────────────────────────────────────────────────
PLIST=~/Library/LaunchAgents/ai.openclaw.gateway.plist
if [[ ! -f "$PLIST" ]]; then
  OPENCLAW_BIN=$(which openclaw)
  cat > "$PLIST" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>ai.openclaw.gateway</string>
  <key>ProgramArguments</key>
  <array>
    <string>${OPENCLAW_BIN}</string>
    <string>gateway</string>
    <string>start</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>/tmp/openclaw.log</string>
  <key>StandardErrorPath</key><string>/tmp/openclaw-error.log</string>
</dict>
</plist>
PLISTEOF
  launchctl load "$PLIST" 2>/dev/null || true
fi
ok "开机自动启动已设置"

# ── 8. 打开配置页 ─────────────────────────────────────────────────
sleep 1
open "http://127.0.0.1:18789"

# ── 完成 ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║         🎉  安装完成！               ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo "  浏览器已打开配置页，在里面填入 API Key 就能用了"
echo "  控制台：http://127.0.0.1:18789"
echo ""
echo "  如遇问题，在朋友圈找我 😊"
echo ""
read -p "  按回车键关闭此窗口..."
