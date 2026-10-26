#!/usr/bin/env bash
# 首次发布：重新生成 → 漂移校验 → 提交（如已有改动）→ 打标签 → 推送到远端
# 用法：bash scripts/first-publish.sh        TAG=v0.1.1 REMOTE=git@github.com:u/r.git bash scripts/first-publish.sh
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_NAME="${REPO_NAME:-universal-agent-rules}"
TAG="${TAG:-v0.1.0}"
REMOTE_URL="${REMOTE:-}"

# 挑一个能用的 git：系统 git 可能因未同意 Xcode 许可而直接报错退出
GIT=""
for cand in /Applications/Xcode.app/Contents/Developer/usr/bin/git git /usr/bin/git; do
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
  if [ -t 0 ]; then
    read -r -p "确认提交？[y/N] " ok
    [ "$ok" = "y" ] || { echo "已取消"; exit 0; }
  else
    echo "（非交互模式，自动提交）"
  fi
  "$GIT" commit -m "feat: universal agent ruleset $TAG"
fi

if "$GIT" rev-parse "$TAG" >/dev/null 2>&1; then
  echo "（标签 $TAG 已存在，跳过）"
else
  "$GIT" tag -a "$TAG" -m "$TAG"
fi

BRANCH="${BRANCH:-$("$GIT" branch --show-current)}"
EXISTING_REMOTE="$("$GIT" remote get-url origin 2>/dev/null || true)"

echo ""
echo "✓ 本地就绪（分支 ${BRANCH}，标签 ${TAG}）"

# ── 情形 1：已配置远端 → 直接推 ───────────────────────────────
if [ -n "$EXISTING_REMOTE" ]; then
  echo "远端： $EXISTING_REMOTE"
  "$GIT" push -u origin "${BRANCH}"
  "$GIT" push origin "$TAG"
  echo "✓ 已推送分支 $BRANCH 与标签 $TAG"
  exit 0
fi

# ── 情形 2：命令行给了 REMOTE → 挂上再推 ──────────────────────
if [ -n "$REMOTE_URL" ]; then
  "$GIT" remote add origin "$REMOTE_URL"
  "$GIT" push -u origin "${BRANCH}"
  "$GIT" push origin "$TAG"
  echo "✓ 已推送到 $REMOTE_URL"
  exit 0
fi

# ── 情形 3：有 gh → 一条龙 ───────────────────────────────────
if command -v gh >/dev/null 2>&1; then
  echo "检测到 gh，建仓并推送："
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
  "$GIT" push origin "$TAG"
  gh release create "$TAG" --title "$TAG" --generate-notes
  exit 0
fi

# ── 情形 4：没有 gh（本机未装 brew/gh 时的 SSH 路线）───────────
PUBKEY="$(cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo '（未找到 ~/.ssh/id_ed25519.pub）')"
cat <<EOF
未检测到 gh，按下面 3 步手动发布（无需安装任何东西）：

1) 浏览器打开 https://github.com/new 建空仓库
   Repository name: ${REPO_NAME}   可见性: Public   不要勾选任何初始化文件（README / LICENSE / .gitignore 都别加）

2) 把 SSH 公钥加到 GitHub：https://github.com/settings/ssh/new
   ${PUBKEY}

3) 回到本目录执行（本机 /usr/bin/git 受 Xcode 许可拦截，必须显式用下面的路径）：
   GIT=/Applications/Xcode.app/Contents/Developer/usr/bin/git
   \$GIT remote add origin git@github.com:<你的用户名>/${REPO_NAME}.git
   \$GIT push -u origin ${BRANCH}
   \$GIT push origin ${TAG}

   或者一步到位：
   REMOTE=git@github.com:<你的用户名>/${REPO_NAME}.git bash scripts/first-publish.sh

验收：打开 https://github.com/<你的用户名>/${REPO_NAME} 能看到文件；
      Releases → Draft a new release → 选择标签 ${TAG}。
可选后续：brew install gh 之后可用 gh repo edit 批量补 Description 与 Topics。
EOF
