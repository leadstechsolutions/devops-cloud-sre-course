#!/usr/bin/env python3
"""Lightweight syntax sanity check for the k6 script (no node in this env).

k6 scripts are JavaScript; the real gate is `k6 run` (or at least `node --check`),
neither of which is available in the lab build environment. As a *lighter local
check* we verify the file is bracket-balanced after stripping comments and string
literals, and that the key k6 constructs are present. This is NOT a full parse; it
catches the common copy/paste truncation and unbalanced-brace breakage.

Template literals are handled: backtick strings are skipped, but `${...}`
substitution expressions inside them ARE scanned, because they contain real code
whose brackets must balance.

Exit 0 if balanced and the expected constructs are present; non-zero otherwise.
Run: python3 tests/check_k6_balance.py solution/load/k6-smoke.js
"""
from __future__ import annotations

import sys


def _scan(src: str) -> list[str]:
    """Return the final bracket stack after a comment/string-aware scan.

    Raises ValueError on a mismatched closer.
    """
    pairs = {")": "(", "]": "[", "}": "{"}
    opens = set("([{")
    stack: list[str] = []
    i, n = 0, len(src)
    # Track template-literal nesting so a '}' that closes a ${...} expr is matched
    # against the synthetic '{' we push for the '${'.
    while i < n:
        c = src[i]
        two = src[i : i + 2]
        if two == "//":  # line comment
            i = src.find("\n", i)
            if i == -1:
                break
            continue
        if two == "/*":  # block comment
            end = src.find("*/", i + 2)
            i = n if end == -1 else end + 2
            continue
        if c in ("'", '"'):  # ordinary string literal
            q = c
            i += 1
            while i < n and src[i] != q:
                i += 2 if src[i] == "\\" else 1
            i += 1
            continue
        if c == "`":  # template literal: skip text, but scan ${...} expressions
            i += 1
            while i < n and src[i] != "`":
                if src[i] == "\\":
                    i += 2
                    continue
                if src[i : i + 2] == "${":
                    stack.append("{")  # the '$' '{' opener
                    i += 2
                    # scan the embedded expression until its matching '}'
                    depth = 1
                    while i < n and depth > 0:
                        ch = src[i]
                        if ch in opens:
                            stack.append(ch)
                            depth += 1 if ch == "{" else 0
                        elif ch in pairs:
                            if not stack or stack.pop() != pairs[ch]:
                                raise ValueError(f"mismatched '{ch}' at index {i}")
                            if ch == "}":
                                depth -= 1
                        i += 1
                    continue
                i += 1
            i += 1
            continue
        if c in opens:
            stack.append(c)
        elif c in pairs:
            if not stack or stack.pop() != pairs[c]:
                raise ValueError(f"mismatched '{c}' at index {i}")
        i += 1
    return stack


def check(path: str) -> int:
    src = open(path, encoding="utf-8").read()
    try:
        stack = _scan(src)
    except ValueError as exc:
        print(f"FAIL {path}: {exc}")
        return 1
    if stack:
        print(f"FAIL {path}: unclosed brackets remain: {stack}")
        return 1
    required = ["import http", "export const options", "thresholds",
                "http_req_duration", "export default function"]
    missing = [tok for tok in required if tok not in src]
    if missing:
        print(f"FAIL {path}: missing expected k6 constructs: {missing}")
        return 1
    print(f"PASS {path}: brackets balanced; k6 constructs present "
          f"(import/options/thresholds/default export).")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) != 1:
        print("usage: check_k6_balance.py <path-to-k6-script.js>", file=sys.stderr)
        return 2
    return check(argv[0])


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
