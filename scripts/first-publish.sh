#!/usr/bin/env bash
# 首次发布：初始化仓库 → 提交 → 打 v0.1.0 标签
# 前置：git 可用（macOS 若提示 Xcode 许可，先跑 `sudo xcodebuild -license accept`）
# 用法：bash scripts/first-publish.sh
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_NAME="${REPO_NAME:-universal-agent-rules}"
TAG="${TAG:-v0.1.0}"

command -v git >/dev/null || { echo "✖ 未找到 git"; exit 1; }
git --version >/dev/null 2>&1 || { echo "✖ git 被 Xcode 许可协议阻断，先跑：sudo xcodebuild -license accept"; exit 1; }

echo "→ 重新生成平台文件"
python3 scripts/build.py
echo "→ 漂移校验"
python3 scripts/build.py --check

if [ ! -d .git ]; then
  git init -b main
fi

git add -A
git status --short | head -40
echo
read -r -p "确认提交？[y/N] " ok
[ "$ok" = "y" ] || { echo "已取消"; exit 0; }

git commit -m "feat: universal agent ruleset v0.1.0 (Claude/Codex/Cursor/Trae/OpenClaw/ChatGPT/Doubao)"
git tag -a "$TAG" -m "$TAG: 首个公开版本（7 平台适配 + 2 个可跑示例）"

echo
echo "✓ 本地就绪。接下来在 GitHub 建仓库并推送（需 gh）："
echo "    gh repo create $REPO_NAME --public --source=. --remote=origin --push"
echo "    git push origin $TAG"
echo "    gh release create $TAG --title '$TAG' --generate-notes"
