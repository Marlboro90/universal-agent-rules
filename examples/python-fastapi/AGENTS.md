# 本示例项目规则（Python FastAPI）

<!-- 项目专属规则；通用规则见仓库根 AGENTS.md（由 core/ 生成） -->

## 命令

- `pytest -q` —— 单元测试
- `ruff check .` —— lint
- `uvicorn src.main:app --reload` —— 本地起服务（示例不含该文件，仅示意）

## 项目约定

1. Python ≥ 3.10，类型注解必写；对外函数都要有 docstring 一句话说明。
2. 接口层只做校验与转发，业务逻辑放 `src/`，不在路由里写业务。
3. 错误用明确异常 + 中文说明「什么失败 / 为什么 / 怎么办」，不返回裸 500。
4. 新增依赖先说明用途；生产依赖需评估体积与维护活跃度。
5. 路径级规则：本文件只约束 `src/api/**`，数据层另有 `src/store/AGENTS.md` 时以更近的为准。

## 怎么验证规则生效

```bash
pip install -r requirements.txt
pytest -q
ruff check .
```

把根 `AGENTS.md` 一并放进项目根，问 AI 一句「给 items 加一个删除接口」，
检查它是否：先确认改动范围 → 只在 `src/api/` 与 `tests/` 改动 → 跑 `pytest` → 汇报检查结果。
