# 跨 AI 编程助手「规则集」开源发布操作清单

> 配套仓库骨架已生成在 `~/Documents/agent-rules/`，本清单按步骤说明**每一步要创建/提交哪些文件、跑什么命令、怎么验收**。
> 事实基准：2026-09-27 核实的各平台官方文档（Codex AGENTS.md、Claude Code memory、Cursor Rules、Trae Rules、OpenClaw Skills、ChatGPT 自定义指令）。

---

## 0. 架构一句话与四项前置决策

**架构**：`core/` 手写且唯一 → `scripts/build.py` 渲染模板 → 生成各平台约定位置的文件 → 生成物**提交进仓库** → CI 用 `--check` 防止漂移。
这样用户既能「复制即用」，维护者又只需改一处。

| 决策 | 建议 | 说明 |
|---|---|---|
| 仓库名 | `universal-agent-rules`（备选：`agent-rules` / `ai-rules-kit`） | kebab-case、含核心关键词 `agent` + `rules`，便于搜索 |
| 版权人 | **已填「吴叉叉」**（据族谱技能 LICENSE 推断） | 改：`sed -i '' 's/吴叉叉/<你的署名>/' LICENSE` |
| 版本策略 | SemVer：MAJOR=规则语义破坏，MINOR=新增规则/平台，PATCH=文案修正 | 规则集也要能被"依赖"，破坏性变更必须升 MAJOR |
| 分支 | `main`（发布）+ `develop`（日常），PR 合并到 develop | 单人维护可只留 `main` |

---

## 1. 分步骤操作清单

### Step 1 — 建目录骨架

```bash
mkdir -p core platforms/{claude,codex,cursor/rules,trae/rules,openclaw/skills/ai-agent-rules,chatgpt,doubao} scripts examples .github/workflows
```

**创建**：上述目录树（已生成）
**验收**：`ls` 能看到 `core/`、`platforms/`、`scripts/`

### Step 2 — 写唯一真源规则

**创建/提交**：`core/00-principles.md`、`core/10-workflow.md`、`core/20-code-style.md`、`core/30-output-format.md`、`core/40-safety.md`（已生成，内容按你的实际经验替换）

规则写法三条：
1. **可验证**——「缩进 2 空格」而不是「格式规范」；
2. **写原因**——「禁止 X，因为我们踩过 Y，用 Z 替代」遵循率显著高于「禁止 X」；
3. **单一主题**——一个文件一个主题，便于后续按需加载与裁剪。

### Step 3 — 写平台模板与受限文本

**创建/提交**：
- `platforms/codex/AGENTS.md.tmpl` → 生成 `AGENTS.md`（Codex / Trae / Cursor 通吃）
- `platforms/claude/CLAUDE.md.tmpl` → 生成 `CLAUDE.md`（`@AGENTS.md` 一行导入 + Claude 专属段）
- `platforms/cursor/rules/core.mdc.tmpl` → `.cursor/rules/core.mdc`
- `platforms/trae/rules/core.md.tmpl` → `.trae/rules/core.md`
- `platforms/openclaw/skills/ai-agent-rules/SKILL.md.tmpl` → `skills/ai-agent-rules/SKILL.md`
- `platforms/chatgpt/field1.md`、`field2.md` → `chatgpt/field1.txt`、`field2.txt`
- `platforms/doubao/persona.md` → `doubao/persona.md`

**取舍说明**：ChatGPT 两栏（各 1500 字符）与豆包人设属于**受限 UI 字段**，无法从 core 自动派生，故人工维护、由构建脚本做**长度门禁**。这是唯一的两处"手写副本"，代价可接受。

### Step 4 — 构建脚本并首次生成

**创建/提交**：`scripts/build.py`、`VERSION`

```bash
python3 scripts/build.py            # 生成 8 个平台文件
python3 scripts/build.py --check    # 漂移校验（CI 同款，退出码 0/1）
```

**验收**：8 个产物生成成功；`AGENTS.md` 51 行 / 3.9 KB，`chatgpt/*.txt` 各 < 1500 字符，`--check` 通过。

### Step 5 — 文档与许可证

**创建/提交**：`README.md`（中文主）、`README.en.md`、`CHANGELOG.md`、`CONTRIBUTING.md`、`LICENSE`、`examples/README.md`

- **P0（已完成）**：`LICENSE` 版权人已填「吴叉叉」。如需改：`sed -i '' 's/吴叉叉/<署名>/' LICENSE`
- 两份 README 顶部互链（`[English](README.en.md)` / `[简体中文](README.md)`）。
- 两份 README 的 `<OWNER>/<REPO>` 已填 `marlboro90/universal-agent-rules`（共 6 处）。

### Step 6 — CI 与忽略规则

**创建/提交**：`.github/workflows/build-check.yml`、`.gitignore`

`build-check.yml` 在 PR 与 push 时跑 `build.py --check`，**生成物与 core 不一致即失败**——这是"不重复维护"的机制保障。

### Step 7 — 本地自检（发布前必跑）

```bash
python3 scripts/build.py --check
grep -rInE "(api[_-]?key|token|secret|password|私钥)" --exclude-dir=.git . || echo "无密钥"
```

**验收**：无密钥命中；`--check` 退出码 0；所有相对链接指向的文件存在。

### Step 8 — Git 初始化与首次提交

```bash
git init -b main
git add . && git status          # 确认没有 .env/密钥/大文件被加进来
git -c user.name="<you>" -c user.email="<you@example.com>" commit -m "feat: initial universal agent ruleset"
```

**提交的文件**：Step 1–6 全部内容（含生成物 `AGENTS.md`、`CLAUDE.md`、`.cursor/`、`.trae/`、`skills/`、`chatgpt/`、`doubao/`）

> **本机坑（macOS）**：`/usr/bin/git` 是 Xcode 包装器，未同意许可时会直接报错退出，
> 且 `sudo xcodebuild -license accept` 需要管理员身份。两条出路：
> ① 一劳永逸：`sudo xcodebuild -license accept`；
> ② 立即可用：`GIT=/Applications/Xcode.app/Contents/Developer/usr/bin/git`（Apple Git 2.54.0，免许可、免 sudo）。
> `scripts/first-publish.sh` 已内置自动挑选，二选一都不影响后续命令。

### Step 9 — 创建 GitHub 仓库并推送

**路线 A（有 gh）**

```bash
gh repo create universal-agent-rules --public --source=. --remote=origin --push
```

**路线 B（无 gh / 没装 brew，推荐 SSH——本机即此情形）**

```bash
# 1) 建密钥（只做一次）
ssh-keygen -t ed25519 -C "you@example.com"        # 一路回车

# 2) 公钥加到 GitHub：https://github.com/settings/ssh/new
cat ~/.ssh/id_ed25519.pub

# 3) 网页 https://github.com/new 建空仓库（Public，切勿勾选 README/LICENSE/.gitignore）

# 4) 推送（本机请用 Xcode 内嵌 git）
GIT=/Applications/Xcode.app/Contents/Developer/usr/bin/git
cd ~/Documents/agent-rules
$GIT remote add origin git@github.com:<你的用户名>/universal-agent-rules.git
$GIT push -u origin main
$GIT push origin v0.1.0
```

> 一行等价写法：`REMOTE=git@github.com:<你的用户名>/universal-agent-rules.git bash scripts/first-publish.sh`
> 脚本会按「已有远端 → 给定 REMOTE → 有 gh → 打印 SSH 手工步骤」四档自动降级。

仓库设置（网页或 `gh repo edit`）：

| 项 | 建议值 |
|---|---|
| Description | `One ruleset for every AI coding assistant — Claude / Codex / Cursor / Trae / OpenClaw / ChatGPT / Doubao. Write once in core/, generate everywhere.` |
| Website | 先用仓库首页，后续换文档站 |
| Topics | `ai-rules, agent-rules, claude-code, codex, cursor, cursorrules, chatgpt, prompt-engineering, agents-md, claude-md, trae, openclaw, developer-experience` |

**可发现性要点**：Topics 前 5 个最重要（决定搜索权重）；Description 里同时出现中文场景词与英文平台名；README 首屏必须有「平台支持矩阵」表格（这是被 star 的第一理由）。

### Step 10 — Gitee 仓库与镜像同步

1. 生成 SSH 密钥对：`ssh-keygen -t ed25519 -C "gitee-mirror"`；公钥加到 [Gitee SSH 公钥](https://gitee.com/profile/sshkeys)。
2. 生成 Gitee 私人令牌（需要 `projects` 权限）：https://gitee.com/profile/personal_access_tokens
3. 在 GitHub 仓库 Settings → Secrets 添加：`GITEE_USER`、`GITEE_PRIVATE_KEY`（私钥全文）、`GITEE_TOKEN`。
4. **创建/提交**：`.github/workflows/gitee-sync.yml`（已生成，用 `Yikun/hub-mirror-action@master`，`force_update: true`）。
5. 首次可先用 Gitee「+ → 从 GitHub/GitLab 导入仓库」一次性导入（注意导入后默认私有，需手动改公开），之后由 Actions 持续单向同步。

**验收**：push 到 main → Actions 的 `gitee-sync` 绿 → Gitee 上提交数与 GitHub 一致。
**注意**：镜像是**单向**的（GitHub → Gitee），Gitee 侧的 issue/PR 不回流，README 需写明"请到 GitHub 提 PR"。

### Step 11 — 打标签与首个 Release

```bash
git tag -a v0.1.0 -m "v0.1.0: 首个公开版本（7 平台适配）"
git push origin v0.1.0
gh release create v0.1.0 --title "v0.1.0" --notes-file <(sed -n '/## \[0.1.0\]/,/^## \[/p' CHANGELOG.md | sed '$d')
```

**提交**：tag `v0.1.0` + GitHub Release（Release notes 直接取 CHANGELOG 对应小节）

### Step 12 — 发布后扩散（可选但收益高）

**无需提交文件的动作**：

- 投递 awesome 清单（awesome-claude-code、awesome-cursor-rules、awesome-codex 等），PR 只加一行链接+一句描述；
- 中文社区发一篇"为什么规则要写一份而不是七份"的短文，引流到仓库；
- Gitee 侧设置项目标签（提示词 / AI 编程 / 智能体 / 规则集），并申请加入 Gitee 开源推荐（GVP 需积累 star 与活跃度）。

### Step 13 — 后续版本维护（见第 4 节）

---

## 2. 平台适配要点速查（含坑）

| 平台 | 文件位置 | 导入方式 | 必须注意的坑 |
|---|---|---|---|
| **Claude Code** | `CLAUDE.md`（根 / `~/.claude/CLAUDE.md` / 子目录） | 复制文件 | **不读 `AGENTS.md`** → 用 `@AGENTS.md` 导入或软链；单文件建议 <200 行；`@import` 相对导入文件解析、最深 4 跳、外部路径首用需授权 |
| **Codex** | `AGENTS.md`（根→当前目录逐级）、`~/.codex/AGENTS.md` | 复制 / 全局放置 | 合并上限 **32 KiB**（`project_doc_max_bytes`）；`AGENTS.override.md` 优先；建议 <150 行；子目录放专属规则 |
| **Cursor** | `.cursor/rules/*.mdc` | 复制目录 | **Agent 模式只读 `.mdc`**，`.cursorrules` 已退居 Ask/Edit；`.md` 放在 rules 目录会被忽略；frontmatter 用 `description/globs/alwaysApply` |
| **Trae** | `.trae/rules/*.md` | 复制目录 | 规则总量 **≤20000 byte**，单条建议 <10000 字符；文件名仅小写字母/数字/连字符；**读 `AGENTS.md`/`CLAUDE.md` 需在设置里手动打开开关**；优先级：用户输入 > 智能体提示词 > user_rules > project_rules |
| **OpenClaw / WorkBuddy** | `skills/<name>/SKILL.md`、`.agents/skills/`、`~/.openclaw/skills/` | 复制整个目录 | frontmatter 的 `name`/`description` 决定被谁发现与何时加载；目录分组最深 6 层；与 ClawHub 生态兼容 |
| **ChatGPT** | 设置 → 个性化 → 自定义指令（两栏） | **粘贴文本** | **每栏 1500 字符上限**（超出的部分不会被保存）；Projects 可叠加一层项目指令 |
| **豆包（智能体）** | 智能体「人设与回复逻辑」+ 知识库 | **粘贴 + 上传 `core/*.md`** | 无文件型约定；把 `core/` 作为知识库上传，人设里写"检索知识库后再回答" |
| GitHub Copilot（附） | `.github/copilot-instructions.md` | 复制 `AGENTS.md` 内容 | — |

**拆分与复用原则**：`AGENTS.md` 作为跨平台的"公约数真源"；Claude 用导入、Cursor/Trae 用生成物内联、`SKILL.md` 用生成物内联、ChatGPT/豆包用人工压缩版。**唯一需要人工同步的只有受限字段那两份**。

---

## 3. 发布前自检清单

| # | 检查项 | 怎么查 | 不通过的处理 |
|---|---|---|---|
| 1 | `LICENSE` 版权人是本人 | `head -3 LICENSE` | `sed -i '' 's/吴叉叉/<署名>/' LICENSE` |
| 2 | 无密钥 / 个人信息 | `grep -rInE "(api[_-]?key|token|secret|password)" --exclude-dir=.git .` | 清除并改历史提交 |
| 3 | 生成物与 core 同步 | `python3 scripts/build.py --check` | 重跑 `build.py` 后提交 |
| 4 | 平台硬限制 | 构建脚本已内置门禁（32 KiB / 20000 B / 1500 字符 / 200 行） | 拆分 core 或裁剪文本 |
| 5 | 双语 README 一致 | 对照平台矩阵表 | 补齐差异项 |
| 6 | 相对链接可达 | 逐个点 README 里的链接 | 修正路径 |
| 7 | CHANGELOG 有当期条目 | 有 `[0.1.0]` 小节 | 补写 |
| 8 | 示例可验证 | 按 `examples/README.md` 跑一遍 | 写不出验证步骤就删掉该示例 |
| 9 | git 状态干净、无大文件 | `git status` + `du -sh .` | 移除大文件 / 加 .gitignore |
| 10 | GitHub 仓库已设 Description / Topics / 公开 | 仓库页面 | 补齐 |
| 11 | Gitee 三个 Secrets 配齐 | Settings → Secrets | 补齐后手动触发一次 workflow |
| 12 | 首次 push 后 Actions 全绿 | Actions 页面 | 按日志修 |

---

## 4. 后续版本维护建议

1. **规则季度审计**（每 3 个月）：删过时规则、查规则间冲突、补"最近三月重复纠正过两次"的条目——重复纠正 = 缺失规则。
2. **版本策略**：语义化版本 + `CHANGELOG.md` 固定 Added/Changed/Fixed/Deprecated 四段；破坏性变更在 README 顶部加迁移说明。
3. **新增平台流程**：`platforms/<平台>/` 放模板 → `build.py` 的 `TARGETS` 加一行 → 登记平台限制 → 更新两份 README 矩阵。三步即可，不碰 core。
4. **社区机制**：加 `.github/ISSUE_TEMPLATE/`（规则建议 / 平台适配 / bug）与 PR 模板（要求说明"为什么"）；开启 Discussions 收集场景。
5. **指标与迭代**：看 star 增速、fork 数、Release 下载、Issue 主题分布；Issue 里反复出现的"某平台不生效"优先修（通常是平台改了读取规则，需回到官方文档复核）。
6. **备份与镜像**：GitHub 为主、Gitee 为镜像（单向）。每季度确认一次 Gitee 同步仍在工作（Action 可能因令牌过期静默失败）。

---

## 附：常用命令速查

```bash
python3 scripts/build.py            # 改完 core/ 后重新生成
python3 scripts/build.py --check    # 漂移 + 平台限制校验
git add -A && git commit -m "feat: <一句话>" && git push
git tag -a v0.1.1 -m "v0.1.1" && git push origin v0.1.1
gh repo edit --add-topic ai-rules --add-topic claude-code --add-topic codex
```

---

## 附：现在就推（复制粘贴即可）

本地首发已完成：分支 `main`、标签 `v0.1.0`、49 个文件（`git log` 可查）。剩下三步在**你自己的终端**执行：

```bash
# 0) 若 git 提示 Xcode 许可（本机 /usr/bin/git 有此问题，Xcode.app 内嵌的可用）
sudo xcodebuild -license accept
# 或直接用：/Applications/Xcode.app/Contents/Developer/usr/bin/git

# 1) 建仓并推送（没有 gh 就先装：brew install gh && gh auth login）
cd ~/Documents/agent-rules
gh repo create universal-agent-rules --public --source=. --remote=origin --push
git push origin v0.1.0
gh release create v0.1.0 --title "v0.1.0" --generate-notes

# 2) 仓库设置（提升可发现性）
gh repo edit \
  --description "One ruleset for every AI coding assistant — Claude / Codex / Cursor / Trae / OpenClaw / ChatGPT / Doubao. Write once in core/, generate everywhere." \
  --add-topic ai-rules --add-topic agent-rules --add-topic claude-code \
  --add-topic codex --add-topic cursor --add-topic prompt-engineering --add-topic agents-md

# 3) Gitee 镜像（单向同步）
#    a. ssh-keygen -t ed25519 -C "gitee-mirror"，公钥加到 https://gitee.com/profile/sshkeys
#    b. 生成令牌 https://gitee.com/profile/personal_access_tokens
#    c. GitHub 仓库 Settings → Secrets 添加：GITEE_USER / GITEE_PRIVATE_KEY / GITEE_TOKEN
#    d. 推一次 main 触发 .github/workflows/gitee-sync.yml，检查 Actions 是否绿
```

**推完立刻验证三件事**：Actions 的 `build-check` 绿；README 首屏平台矩阵渲染正常；Gitee 上提交数与 GitHub 一致。
