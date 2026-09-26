# 更新日志 / Changelog

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。
版本号含义：MAJOR = 规则语义破坏性变更；MINOR = 新增规则或新增平台；PATCH = 文案/排版修正。

## [Unreleased]

## [0.1.0] - 2026-09-27

### Added
- `core/` 五份规则：通用原则 / 任务工作流 / 代码风格 / 输出格式 / 安全与隐私红线
- `scripts/build.py`：core + 模板 → 8 个平台文件，含 `--check` 漂移校验与平台限制门禁
  （Codex 32 KiB、Trae 20000 byte、ChatGPT 每栏 1500 字符、Claude 200 行建议）
- 平台适配：Claude Code / Codex / Cursor / Trae / OpenClaw·WorkBuddy / ChatGPT / 豆包
- 双语 README、MIT 许可证、贡献指南、GitHub Actions 构建校验与 Gitee 镜像同步
- 可运行示例：`examples/node-cli`（2 条 `node:test` 用例实测通过 + `--selftest`）、
  `examples/python-fastapi`（items 接口 + pytest 用例，含路径级规则说明）
- Issue 模板（规则建议 / 平台适配 / 缺陷）+ PR 模板（强制写「为什么」与自检清单）
- `scripts/first-publish.sh`：一键 重新生成 → 漂移校验 → git init → 提交 → 打 v0.1.0
