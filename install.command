#!/bin/bash
# OpenClaw 一键安装脚本 for macOS
# 双击 .command 文件即可运行

set -e

# ─── 颜色 ───────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

GITHUB_RAW="https://raw.githubusercontent.com/karinecsy/openclaw-deploy/main"

print_banner() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║        OpenClaw AI 助手 安装程序       ║"
  echo "  ║          一键部署，即刻使用            ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo -e "${NC}"
}

step() { echo -e "\n${BLUE}${BOLD}▶ $1${NC}"; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ─── 等待用户确认 ────────────────────────────────────
print_banner
echo -e "本脚本将在你的 Mac 上安装 ${BOLD}OpenClaw AI 助手${NC}"
echo -e "安装内容：Homebrew（如未安装）、Node.js、OpenClaw、预装技能"
echo ""
read -p "按回车键开始安装，或按 Ctrl+C 取消... "

# ─── 1. 检查 macOS ────────────────────────────────────
step "检查系统环境"
if [[ "$OSTYPE" != "darwin"* ]]; then
  fail "此脚本仅支持 macOS，当前系统：$OSTYPE"
fi
ARCH=$(uname -m)
ok "macOS 检测通过（$ARCH）"

# ─── 2. 安装 Homebrew ─────────────────────────────────
step "检查 Homebrew"
if ! command -v brew &>/dev/null; then
  echo "正在安装 Homebrew（可能需要几分钟）..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # 让 brew 命令可用
  if [[ "$ARCH" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew 安装完成"
else
  ok "Homebrew 已安装：$(brew --version | head -1)"
fi

# ─── 3. 安装 Node.js ──────────────────────────────────
step "检查 Node.js"
if ! command -v node &>/dev/null; then
  echo "正在安装 Node.js..."
  brew install node
  ok "Node.js 安装完成"
else
  NODE_VER=$(node --version)
  ok "Node.js 已安装：$NODE_VER"
fi

# ─── 4. 安装 OpenClaw ─────────────────────────────────
step "安装 OpenClaw"
if ! command -v openclaw &>/dev/null; then
  echo "正在安装 OpenClaw（可能需要 1~2 分钟）..."
  npm install -g openclaw
  ok "OpenClaw 安装完成"
else
  ok "OpenClaw 已安装：$(openclaw --version 2>/dev/null || echo '已安装')"
fi

# ─── 5. 配置向导 ──────────────────────────────────────
step "配置 AI 模型"
echo ""
echo -e "请选择 AI 模型提供商："
echo "  1) Anthropic Claude（推荐，效果最好）"
echo "  2) OpenAI GPT"
echo "  3) MiniMax（国内速度快）"
echo ""
read -p "请输入序号 [1-3，默认1]: " MODEL_CHOICE
MODEL_CHOICE=${MODEL_CHOICE:-1}

case $MODEL_CHOICE in
  1)
    MODEL_PROVIDER="anthropic"
    MODEL_ID="anthropic/claude-sonnet-4-6"
    echo ""
    echo -e "请前往 ${CYAN}https://console.anthropic.com/keys${NC} 获取 API Key"
    read -sp "请粘贴 Anthropic API Key: " API_KEY
    echo ""
    ;;
  2)
    MODEL_PROVIDER="openai"
    MODEL_ID="openai/gpt-4o"
    echo ""
    echo -e "请前往 ${CYAN}https://platform.openai.com/api-keys${NC} 获取 API Key"
    read -sp "请粘贴 OpenAI API Key: " API_KEY
    echo ""
    ;;
  3)
    MODEL_PROVIDER="minimax"
    MODEL_ID="minimax-portal/MiniMax-M2.5"
    echo ""
    echo -e "请前往 ${CYAN}https://api.minimax.chat/user-center/basic-information/interface-key${NC} 获取 API Key"
    read -sp "请粘贴 MiniMax API Key: " API_KEY
    echo ""
    ;;
  *)
    warn "无效选择，使用默认 Anthropic"
    MODEL_PROVIDER="anthropic"
    MODEL_ID="anthropic/claude-sonnet-4-6"
    read -sp "请粘贴 Anthropic API Key: " API_KEY
    echo ""
    ;;
esac

if [[ -z "$API_KEY" ]]; then
  fail "API Key 不能为空"
fi
ok "模型配置完成：$MODEL_ID"

# ─── 6. IM 渠道配置 ───────────────────────────────────
step "配置 IM 渠道（可选）"
echo ""
echo "选择要接入的 IM 平台："
echo "  1) 飞书 Feishu"
echo "  2) Telegram"
echo "  3) 暂时跳过（以后再配置）"
echo ""
read -p "请输入序号 [1-3，默认3]: " IM_CHOICE
IM_CHOICE=${IM_CHOICE:-3}

FEISHU_APP_ID=""
FEISHU_APP_SECRET=""
TELEGRAM_TOKEN=""

case $IM_CHOICE in
  1)
    echo ""
    echo -e "请前往 ${CYAN}https://open.feishu.cn${NC} 创建应用并获取凭据"
    read -p "请输入飞书 App ID: " FEISHU_APP_ID
    read -sp "请输入飞书 App Secret: " FEISHU_APP_SECRET
    echo ""
    ok "飞书配置完成"
    ;;
  2)
    echo ""
    echo -e "请在 Telegram 中找 ${CYAN}@BotFather${NC} 创建 Bot 并获取 Token"
    read -p "请输入 Telegram Bot Token: " TELEGRAM_TOKEN
    ok "Telegram 配置完成"
    ;;
  3)
    warn "跳过 IM 配置，稍后可手动运行 openclaw configure"
    ;;
esac

# ─── 7. 创建目录和配置文件 ────────────────────────────
step "写入配置"
mkdir -p ~/.openclaw/workspace/skills
mkdir -p ~/.openclaw/workspace/.learnings
mkdir -p ~/.openclaw/workspace/memory

# 生成 openclaw.json
cat > ~/.openclaw/openclaw.json << JSONEOF
{
  "gateway": {
    "bind": "loopback",
    "port": 18789
  },
  "providers": {
    "${MODEL_PROVIDER}": {
      "apiKey": "${API_KEY}"
    }
  },
  "agent": {
    "model": {
      "primary": "${MODEL_ID}"
    }
  }
}
JSONEOF
chmod 600 ~/.openclaw/openclaw.json
ok "配置文件已写入 ~/.openclaw/openclaw.json"

# ─── 8. 飞书插件配置（如选择）────────────────────────
if [[ -n "$FEISHU_APP_ID" ]]; then
  FEISHU_EXT_DIR=~/.openclaw/extensions/feishu
  mkdir -p "$FEISHU_EXT_DIR"
  cat > "$FEISHU_EXT_DIR/config.json" << FEISHUEOF
{
  "appId": "${FEISHU_APP_ID}",
  "appSecret": "${FEISHU_APP_SECRET}"
}
FEISHUEOF
  chmod 600 "$FEISHU_EXT_DIR/config.json"
  ok "飞书配置已写入"
fi

# Telegram 配置
if [[ -n "$TELEGRAM_TOKEN" ]]; then
  echo "TELEGRAM_BOT_TOKEN=${TELEGRAM_TOKEN}" >> ~/.openclaw/.env
  chmod 600 ~/.openclaw/.env
  ok "Telegram 配置已写入"
fi

# ─── 9. 下载预装 Skills ───────────────────────────────
step "安装预装技能"
SKILLS_DIR=~/.agents/skills
mkdir -p "$SKILLS_DIR"

SKILLS=("weather" "yahoo-finance" "pptx" "feishu-doc" "feishu-wiki" "xiaohongshu" "self-improving-agent" "easylink-easydoc-parse" "equity-research" "find-skills")

SUCCESS_COUNT=0
for skill in "${SKILLS[@]}"; do
  SKILL_URL="${GITHUB_RAW}/skills/${skill}/SKILL.md"
  SKILL_DIR="$SKILLS_DIR/$skill"
  mkdir -p "$SKILL_DIR"
  if curl -fsSL "$SKILL_URL" -o "$SKILL_DIR/SKILL.md" 2>/dev/null; then
    ok "  ✓ $skill"
    ((SUCCESS_COUNT++))
  else
    warn "  ⚠ $skill（跳过，可稍后手动安装）"
  fi
done
ok "已安装 ${SUCCESS_COUNT}/${#SKILLS[@]} 个技能"

# ─── 10. 创建基础 Workspace 文件 ──────────────────────
step "初始化工作区"
WS=~/.openclaw/workspace

# SOUL.md
[[ -f "$WS/SOUL.md" ]] || cat > "$WS/SOUL.md" << 'EOF'
# SOUL.md - Who You Are
Be genuinely helpful, not performatively helpful. Have opinions. Be resourceful before asking.
EOF

# MEMORY.md
[[ -f "$WS/MEMORY.md" ]] || cat > "$WS/MEMORY.md" << 'EOF'
# 重要记忆
EOF

# .learnings
[[ -f "$WS/.learnings/LEARNINGS.md" ]] || echo "# Learnings" > "$WS/.learnings/LEARNINGS.md"
[[ -f "$WS/.learnings/ERRORS.md" ]] || echo "# Errors" > "$WS/.learnings/ERRORS.md"

ok "工作区初始化完成"

# ─── 11. 启动 Gateway ────────────────────────────────
step "启动 OpenClaw Gateway"
# 先停止可能已有的实例
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# 后台启动
nohup openclaw gateway start > /tmp/openclaw-gateway.log 2>&1 &
GATEWAY_PID=$!
sleep 3

if kill -0 $GATEWAY_PID 2>/dev/null; then
  ok "Gateway 已启动（PID: $GATEWAY_PID）"
else
  warn "Gateway 启动异常，请查看日志：cat /tmp/openclaw-gateway.log"
fi

# ─── 12. 打开控制台 ────────────────────────────────────
step "打开控制台"
sleep 2
open "http://127.0.0.1:18789" 2>/dev/null || true

# ─── 完成 ──────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║           🎉 安装完成！               ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  控制台地址：${CYAN}http://127.0.0.1:18789${NC}"
echo -e "  工作区路径：${CYAN}~/.openclaw/workspace${NC}"
echo -e "  Gateway日志：${CYAN}/tmp/openclaw-gateway.log${NC}"
echo ""
echo -e "  开机自动启动命令（可选）："
echo -e "  ${YELLOW}openclaw gateway enable-autostart${NC}"
echo ""
echo -e "如有问题，请联系客服（飞书扫码咨询）"
echo ""
read -p "按回车键关闭此窗口..."
