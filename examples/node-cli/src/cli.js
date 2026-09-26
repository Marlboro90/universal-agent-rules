#!/usr/bin/env node
// 按 core/20 代码风格：命名自解释、函数短小、提前返回、错误说清为什么
export function parseArgs(argv) {
  const args = argv.slice(2);
  if (args.length === 0) return { command: "help" };
  return { command: args[0], rest: args.slice(1) };
}

export function greet(name) {
  if (!name) return "Hello, stranger";
  return `Hello, ${name}`;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const { command, rest } = parseArgs(process.argv);
  if (command === "--selftest") {
    console.log(greet("world"));
    process.exit(0);
  }
  if (command === "help" || command === undefined) {
    console.log("用法: node src/cli.js <command> [args]");
    process.exit(0);
  }
  console.error(`未知命令: ${command}（可用: help / --selftest）`);
  process.exit(1);
}
