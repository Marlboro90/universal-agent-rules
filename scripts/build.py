#!/usr/bin/env python3
"""把 core/（唯一真源）渲染成各平台的规则文件。

用法：
    python3 scripts/build.py            # 生成 / 覆盖平台文件
    python3 scripts/build.py --check    # 只校验不写入（CI 用）：有漂移则退出码 1

设计原则：
    core/ 手写，是唯一真源；platforms/ 存模板；生成物提交进仓库，
    让用户不必跑构建即可直接复制。--check 保证「生成物与 core 永不脱节」。
"""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CORE_DIR = ROOT / "core"
VERSION_FILE = ROOT / "VERSION"

# (模板, 输出) —— 输出路径即各平台约定的读取位置
TARGETS = [
    ("platforms/codex/AGENTS.md.tmpl",                       "AGENTS.md"),
    ("platforms/claude/CLAUDE.md.tmpl",                      "CLAUDE.md"),
    ("platforms/cursor/rules/core.mdc.tmpl",                 ".cursor/rules/core.mdc"),
    ("platforms/trae/rules/core.md.tmpl",                    ".trae/rules/core.md"),
    ("platforms/openclaw/skills/ai-agent-rules/SKILL.md.tmpl","skills/ai-agent-rules/SKILL.md"),
    ("platforms/chatgpt/field1.md",                          "chatgpt/field1.txt"),
    ("platforms/chatgpt/field2.md",                          "chatgpt/field2.txt"),
    ("platforms/doubao/persona.md",                          "doubao/persona.md"),
]

# 平台硬限制（超出即报错）：字节 / 字符 / 行数
BYTE_LIMITS  = {"AGENTS.md": 32768, ".trae/rules/core.md": 20000}   # Codex 32 KiB；Trae 20000 byte
CHAR_LIMITS  = {"chatgpt/field1.txt": 1500, "chatgpt/field2.txt": 1500}
LINE_WARN    = {"CLAUDE.md": 200}                                    # Anthropic 建议 <200 行


def load_core() -> str:
    files = sorted(CORE_DIR.glob("*.md"))
    if not files:
        sys.exit(f"[FATAL] core/ 下没有 .md 文件：{CORE_DIR}")
    return "\n\n".join(f.read_text(encoding="utf-8").strip() for f in files) + "\n"


def render(tmpl_rel: str, core: str, version: str) -> str:
    t = (ROOT / tmpl_rel)
    if not t.exists():
        sys.exit(f"[FATAL] 模板缺失：{tmpl_rel}")
    return (t.read_text(encoding="utf-8")
             .replace("{{CORE}}", core)
             .replace("{{VERSION}}", version))


def lint(out_rel: str, text: str) -> list[str]:
    problems = []
    b = len(text.encode("utf-8"))
    cap = BYTE_LIMITS.get(out_rel)
    if cap and b > cap:
        problems.append(f"{out_rel}: {b} 字节 > 平台上限 {cap}")
    c = len(text.strip())
    capc = CHAR_LIMITS.get(out_rel)
    if capc and c > capc:
        problems.append(f"{out_rel}: {c} 字符 > 平台上限 {capc}")
    lines = len(text.splitlines())
    warn = LINE_WARN.get(out_rel)
    if warn and lines > warn:
        problems.append(f"[建议] {out_rel}: {lines} 行 > 建议值 {warn}（长文件会降低遵循率）")
    return problems


def main() -> int:
    check_only = "--check" in sys.argv
    version = VERSION_FILE.read_text(encoding="utf-8").strip() if VERSION_FILE.exists() else "0.0.0"
    core = load_core()

    drift, all_problems = [], []
    for tmpl_rel, out_rel in TARGETS:
        text = render(tmpl_rel, core, version)
        problems = lint(out_rel, text)
        all_problems += [f"  ✖ {p}" for p in problems]
        out = ROOT / out_rel
        if check_only:
            if not out.exists() or out.read_text(encoding="utf-8") != text:
                drift.append(out_rel)
        else:
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(text, encoding="utf-8")
            size = len(text.encode("utf-8"))
            print(f"  ✓ {out_rel:42s} {len(text.splitlines()):4d} 行 / {size:6d} 字节")

    if all_problems:
        print("\n平台限制校验：")
        print("\n".join(all_problems))

    if check_only:
        if drift:
            print("\n✖ 生成物与 core/ 不一致（漂移），请本地跑 `python3 scripts/build.py` 后提交：")
            for d in drift:
                print(f"  - {d}")
            return 1
        print("\n✓ --check 通过：所有平台文件与 core/ 完全同步")
        return 0 if not all_problems else 1

    print(f"\n完成：{len(TARGETS)} 个平台文件已生成（版本 {version}）")
    return 0 if not all_problems else 1


if __name__ == "__main__":
    raise SystemExit(main())
