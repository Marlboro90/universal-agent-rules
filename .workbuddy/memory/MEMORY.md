# agent-rules · 项目长期记忆

## 项目定位
跨 AI 编程助手复用的「规则/提示词集」开源仓库（GitHub `marlboro90/universal-agent-rules` + Gitee 镜像）。
核心架构：`core/` 唯一真源 → `scripts/build.py` 渲染 `platforms/` 模板 → 8 个平台文件（生成物提交进仓库）→ CI `--check` 防漂移。

## 硬约束（勿随意改）
- **只改 `core/`**，平台文件是生成物；改完必须跑 `python3 scripts/build.py` 并提交生成物。
- CI 跑 `build.py --check`，漂移即失败。
- ChatGPT 两栏（各 1500 字符）与豆包人设是**唯一人工维护**的两处（`platforms/chatgpt/`、`platforms/doubao/`），由构建脚本做长度门禁。
- 版权署名：LICENSE 填「吴叉叉」（用户此前技能的署名）；GitHub 用户名 `marlboro90`。

## 平台事实（2026-09-27 核实官方文档）
| 平台 | 读取位置 | 硬限制 / 坑 |
|---|---|---|
| Claude Code | `CLAUDE.md`（根/子目录/`~/.claude/`） | **不读 AGENTS.md** → `@AGENTS.md` 导入；`@import` 相对导入文件解析、最深 4 跳；建议 <200 行 |
| Codex | `AGENTS.md`（根→cwd 逐级）、`~/.codex/AGENTS.md` | 合并上限 **32 KiB**；`AGENTS.override.md` 优先；建议 <150 行 |
| Cursor | `.cursor/rules/*.mdc` | Agent 模式只读 `.mdc`，`.md` 被忽略；legacy `.cursorrules` 仅 Ask/Edit |
| Trae | `.trae/rules/*.md` | 总量 ≤20000 byte；文件名仅小写/数字/连字符；读 AGENTS.md 需手动开设置开关 |
| OpenClaw / WorkBuddy | `skills/<name>/SKILL.md`、`.agents/skills/` | frontmatter `name`/`description` 决定发现；分组最深 6 层 |
| ChatGPT | 设置 → 个性化 → 自定义指令（两栏） | **每栏 1500 字符**，超出不保存 |
| 豆包 | 智能体人设 + 知识库 | 无文件约定，上传 `core/*.md` 作知识库 |
| Gitee 镜像 | `Yikun/hub-mirror-action` | Secrets：`GITEE_USER` / `GITEE_PRIVATE_KEY`（SSH 私钥）/ `GITEE_TOKEN`；单向同步 |

## 本机环境坑
- **git 被 Xcode 许可协议阻断**：任何 git 调用都会提示 `sudo xcodebuild -license accept`。需用户本人在终端执行一次。
- 无 `gh`、无 `brew`；发布推仓需用户自行安装并登录。
- Node 测试：`node --test <裸目录>` 会被当模块解析 → 用 `node --test "test/**/*.test.js"`。
- 沙箱 `Path.mkdir()` 在目录已存在时抛 PermissionError，脚本里别无脑 mkdir。

## 交付文件
`RELEASE-PLAN.md`（13 步操作清单 + 平台速查 + 12 项自检 + 维护建议）、`scripts/first-publish.sh`（一键首发）。
