# 通用 AI 编程助手规则集（Universal Agent Rules）

[English](README.en.md) · [更新日志](CHANGELOG.md) · [贡献指南](CONTRIBUTING.md) · [许可证](LICENSE)

一套**跨 AI 编程助手复用**的规则集：规则只写一份（`core/`），由脚本自动生成各平台约定位置的文件，
让 Claude Code、Codex、Cursor、Trae、OpenClaw / WorkBuddy、ChatGPT、豆包 读到同一套约定，**不重复维护**。

## 支持矩阵

| 平台 | 读取位置 | 本仓库产物 | 硬限制 |
|---|---|---|---|
| **Claude Code** | `CLAUDE.md`（项目根）、`.claude/rules/`、`.claude/skills/` | `CLAUDE.md`（`@AGENTS.md` + Claude 专属） | 官方建议单文件 < 200 行 |
| **Codex**（CLI / 云） | `AGENTS.md`（根 → 当前目录逐级）、`~/.codex/AGENTS.md` | `AGENTS.md`（唯一真源） | 合并上限 32 KiB |
| **Cursor** | `.cursor/rules/*.mdc`（Agent 模式只读 `.mdc`）；也认 `AGENTS.md` | `.cursor/rules/core.mdc` | `.md` 在 rules 目录不生效 |
| **Trae**（含豆包系 IDE） | `.trae/rules/*.md`；可选读 `AGENTS.md` / `CLAUDE.md` | `.trae/rules/core.md` | 规则总量 ≤ 20000 byte |
| **OpenClaw / WorkBuddy** | `skills/<name>/SKILL.md`、`.agents/skills/` | `skills/ai-agent-rules/SKILL.md` | frontmatter 需含 `name` / `description` |
| **ChatGPT** | 设置 → 个性化 → 自定义指令（两栏） | `chatgpt/field1.txt` / `field2.txt` | **每栏 1500 字符** |
| **豆包（智能体）** | 智能体「人设与回复逻辑」+ 知识库 | `doubao/persona.md` + 上传 `core/*.md` | 以页面提示为准 |
| GitHub Copilot（附） | `.github/copilot-instructions.md` | 自行复制 `AGENTS.md` | — |

## 60 秒上手

```bash
# 1) 文件型平台：复制到你的项目根
curl -O https://raw.githubusercontent.com/Marlboro90/universal-agent-rules/main/AGENTS.md      # Codex / Trae / Cursor
curl -O https://raw.githubusercontent.com/Marlboro90/universal-agent-rules/main/CLAUDE.md      # Claude Code
mkdir -p .cursor/rules .trae/rules
curl -o .cursor/rules/core.mdc https://raw.githubusercontent.com/Marlboro90/universal-agent-rules/main/.cursor/rules/core.mdc
curl -o .trae/rules/core.md   https://raw.githubusercontent.com/Marlboro90/universal-agent-rules/main/.trae/rules/core.md

# 2) ChatGPT：复制 chatgpt/field1.txt → 第 1 栏；field2.txt → 第 2 栏（设置 → 个性化 → 自定义指令）

# 3) 豆包：doubao/persona.md 粘进智能体人设，core/*.md 上传为知识库

# 4) OpenClaw / WorkBuddy：把 skills/ai-agent-rules/ 整个目录放到 skills/ 或 .agents/skills/
```

> Trae 需在「设置 → 导入设置」中打开 *Include AGENTS.md in context* / *Include CLAUDE.md in context* 才会读这两个文件。

## 目录结构

```
core/                 # ★ 唯一真源（手写）：00 原则 / 10 工作流 / 20 代码风格 / 30 输出格式 / 40 安全红线
platforms/            # 各平台模板与受限文本（ChatGPT 两栏、豆包人设在此人工维护）
scripts/build.py      # core + 模板 → 生成平台文件；--check 做漂移校验
AGENTS.md             # 生成物：Codex / Trae / Cursor 通吃
CLAUDE.md             # 生成物：@AGENTS.md + Claude 专属
.cursor/rules/core.mdc
.trae/rules/core.md
skills/ai-agent-rules/SKILL.md
chatgpt/  doubao/     # 粘贴型产物
examples/             # 按语言/框架的落地示例
```

**为什么不重复维护**：`core/` 是唯一真源；所有平台文件由 `scripts/build.py` 生成并提交。
改规则 = 改 `core/` → 跑一次构建 → CI 用 `--check` 保证生成物与真源永不脱节。

## 定制

```bash
python3 scripts/build.py           # 改完 core/ 后重新生成
python3 scripts/build.py --check   # 只校验（CI 同款）
```

新增平台：在 `platforms/<平台>/` 放模板、`scripts/build.py` 的 `TARGETS` 加一行 (模板, 输出) 即可。

## 版本

语义化版本（见 `VERSION` 与 `CHANGELOG.md`）：MAJOR = 规则语义破坏性变更，MINOR = 新增规则，PATCH = 文案修正。

## 许可证

[MIT](LICENSE) —— 可商用、可修改、可分发，保留版权声明即可。
