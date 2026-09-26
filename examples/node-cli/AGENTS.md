# 本示例项目规则（Node CLI）

<!-- 项目专属规则；通用规则见仓库根 AGENTS.md（由 core/ 生成） -->

## 命令

- `npm run lint` —— 语法检查
- `npm test` —— 单元测试（node:test）
- `npm run build` —— 自检入口

## 项目约定

1. 使用 ESM（`type: module`），不用 CommonJS。
2. 每个导出函数必须有对应的 `node:test` 用例，测试文件放 `test/`。
3. CLI 入口必须有 `--selftest`，能在无外部依赖下跑通。
4. 不引入运行时依赖；确需依赖先说明用途与体积。

## 怎么验证规则生效

```bash
npm test        # 期望：全部通过
npm run lint    # 期望：无输出即无语法错误
```

把根 `AGENTS.md` 一并放进项目根，问 AI 一句「给 greet 加个带称呼的分支」，
检查它是否：先复述改动范围 → 只改 `src/cli.js` → 补 `test/cli.test.js` → 跑 `npm test` 后汇报。
