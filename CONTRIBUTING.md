# 贡献指南

## 改规则的正确姿势

1. **只改 `core/`**。任何平台文件（`AGENTS.md`、`CLAUDE.md`、`.cursor/rules/*.mdc` …）都是生成物，直接改会被覆盖。
2. 跑构建并提交生成物：
   ```bash
   python3 scripts/build.py
   git add core AGENTS.md CLAUDE.md .cursor .trae skills chatgpt doubao
   ```
3. CI 会跑 `python3 scripts/build.py --check`；生成物与 `core/` 不一致会直接失败。

## 新增平台

1. 在 `platforms/<平台>/` 放模板（用 `{{CORE}}` / `{{VERSION}}` 占位）。
2. 在 `scripts/build.py` 的 `TARGETS` 追加 `(模板, 输出)`。
3. 若有平台硬限制，在 `BYTE_LIMITS` / `CHAR_LIMITS` / `LINE_WARN` 登记，让门禁替你把关。
4. 更新两份 README 的支持矩阵。

## 提交规范

- 提交信息用 Conventional Commits：`feat:` / `fix:` / `docs:` / `chore:`。
- 一个 PR 只做一件事；规则类改动请在描述里写清「为什么」——只写「禁止 X」的规则遵循率明显更低。

## 不涉及的内容

- 不提交密钥、真实个人数据、公司内部域名。
- 不接受与具体商业产品绑定的推广内容。
