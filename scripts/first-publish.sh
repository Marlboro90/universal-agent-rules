#!/usr/bin/env bash
# 首次发布：重新生成 → 漂移校验 → 提交（如已有改动）→ 打标签
# 用法：bash scripts/first-publish.sh        TAG=v0.1.1 bash scripts/first-publish.sh
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_NAME="${REPO_NAME:-universal-agent-rules}"
TAG="${TAG:-v0.1.0}"

# 挑一个能用的 git：系统 git 可能提示 "You have not agreed to the Xcode license"
GIT=""
for cand in git /Applications/Xcode.app/Contents/Developer/usr/bin/git /usr/bin/git; do
  if command -v "$cand" >/dev/null 2>&1 && "$cand" --version >/dev/null 2>&1; then
    GIT="$cand"; break
  fi
done
[ -n "$GIT" ] || { echo "✖ 没有可用的 git。终端执行：sudo xcodebuild -license accept"; exit 1; }
echo "使用 git: $GIT ($("$GIT" --version))"

echo "→ 重新生成平台文件"
python3 scripts/build.py
echo "→ 漂移校验"
python3 scripts/build.py --check

[ -d .git ] || "$GIT" init -b main

"$GIT" add -A
if "$GIT" diff --cached --quiet; then
  echo "（无新改动，跳过提交）"
else
  "$GIT" status --short | head -40
  read -r -p "确认提交？[y/N] " ok
  [ "$ok" = "y" ] || { echo "已取消"; exit 0; }
  "$GIT" commit -m "feat: universal agent ruleset $TAG"
fi

if "$GIT" rev-parse "$TAG" >/dev/null 2>&1; then
  echo "（标签 $TAG 已存在，跳过）"
else
  "$GIT" tag -a "$TAG" -m "$TAG"
fi

cat <<EOF

✓ 本地就绪（分支 $("$GIT" branch --show-current)，标签 $TAG）

推送到 GitHub（需 gh 且已登录；没有就先装：brew install gh）：
    gh repo create $REPO_NAME --public --source=. --remote=origin --push
    git push origin $TAG
    gh release create $TAG --title "$TAG" --generate-notes
EOF
