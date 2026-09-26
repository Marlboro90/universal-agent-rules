## 改了什么

<!-- 一句话说明，例如：core/20 新增「新增依赖先问」 -->

## 为什么

<!-- 规则类 PR 必须写清「为什么」：踩过什么坑、不这么做会怎样。
     只写「禁止 X」的规则遵循率明显低于写清原因的规则。 -->

## 影响范围

- [ ] 只改了 `core/`（通用规则）
- [ ] 改了 `platforms/` 模板或新增平台
- [ ] 改了 `scripts/build.py`（生成逻辑 / 限制门禁）
- [ ] 改了文档（README / CHANGELOG / CONTRIBUTING）

## 自检

- [ ] 已跑 `python3 scripts/build.py` 并提交生成物
- [ ] 已跑 `python3 scripts/build.py --check`（应与 CI 一致）
- [ ] 未触碰任何平台生成物（那些是自动生成的）
- [ ] CHANGELOG 已补对应条目

## 版本影响

<!-- MAJOR = 规则语义破坏性变更 / MINOR = 新增规则或平台 / PATCH = 文案修正 -->
