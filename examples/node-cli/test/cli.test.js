import test from "node:test";
import assert from "node:assert/strict";
import { parseArgs, greet } from "../src/cli.js";

test("无参数时回落到 help", () => {
  assert.equal(parseArgs(["node", "cli.js"]).command, "help");
});

test("greet 缺名字时给中性输出", () => {
  assert.equal(greet(""), "Hello, stranger");
});
