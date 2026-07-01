#!/usr/bin/env python3
"""Tiny offline pre-renderer for Helm templates.

Why this exists
---------------
A Helm template is NOT valid YAML on its own: it is YAML *with* Go ``text/template``
actions (``{{ ... }}``) interleaved. The authoritative way to turn a chart into
plain manifests is ``helm template ./chart/webapp``. When the ``helm`` binary is
unavailable (e.g. this lab environment), we still want a *structural* gate that
catches gross YAML mistakes — a key with no value, broken indentation that the
template author introduced, a list item under a mapping, etc.

This module does a deliberately small, conservative transform so the remaining
text parses as YAML:

  1. Whole-line control actions (``{{- if ... }}``, ``{{ end }}``, ``{{- range }}``,
     ``{{- with }}``, ``{{- define }}``, ``{{ else }}``, comments ``{{/* */}}``)
     are dropped — they contribute no rendered YAML node.
  2. A line that is *only* a block include (``{{- include "x" . | nindent N }}``
     or ``{{- toYaml . | nindent N }}``) is dropped: at render time it expands to
     a nested block, and dropping it cannot create invalid YAML for the lines
     that remain (the parent key is handled below).
  3. A line of the form ``key: {{ ... }}`` (scalar value from a template
     expression) has the expression replaced with the placeholder string
     ``__TPL__`` so the mapping stays valid.
  4. A line of the form ``key:`` immediately followed only by dropped block
     includes would leave an empty mapping value; we substitute ``{}`` so the
     key still has a value. (Empty mapping is valid YAML and structurally
     faithful — the block would have filled it.)
  5. Inline ``{{ ... }}`` fragments embedded in a larger scalar (e.g.
     ``name: "{{ ... }}-test"``) are replaced in place with ``x`` so the quoted
     scalar remains a string.

This is a LINTER AID, not a renderer. It will accept some things ``helm`` would
reject and vice-versa. The real gates (``helm lint``, ``helm template``,
``kubeconform``) are documented in the module README and run where helm exists.

Exit code: 0 if every template's stripped form is well-formed YAML, 1 otherwise.
"""
from __future__ import annotations

import glob
import os
import re
import sys

import yaml

# A line that, after stripping, contains only one or more template actions and
# nothing else (control flow / block includes). These produce no standalone
# YAML node when rendered, so we drop them.
_ACTION = re.compile(r"\{\{-?.*?-?\}\}")
_KEY_THEN_TEMPLATE = re.compile(r"^(\s*[-\w./\"]+:\s*)\{\{-?.*?-?\}\}\s*$")
_BARE_KEY = re.compile(r"^(\s*)([\w./\-]+):\s*$")


def _is_only_actions(stripped: str) -> bool:
    """True if the line is nothing but template actions / template comments."""
    if not stripped:
        return False
    # Remove every {{...}} action; if nothing meaningful remains, it was control.
    residue = _ACTION.sub("", stripped).strip()
    return residue == "" and "{{" in stripped


def prerender(text: str) -> str:
    out: list[str] = []
    lines = text.splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()

        # Drop template comments and pure control / block-include lines.
        if _is_only_actions(stripped):
            # If the *next* non-blank line is more-indented it was a block under
            # this action; nothing to do. We simply drop the action line.
            continue

        # key: {{ ... }}  ->  key: __TPL__   (scalar value from a template)
        m = _KEY_THEN_TEMPLATE.match(line)
        if m:
            out.append(f"{m.group(1)}__TPL__")
            continue

        # Replace any remaining inline {{...}} fragments with a placeholder so a
        # surrounding quoted/scalar value stays valid.
        if "{{" in line:
            line = _ACTION.sub("x", line)

        out.append(line)

    rendered = "\n".join(out)

    # Pass 2: a bare ``key:`` whose only child lines were dropped block-includes
    # would now be an empty mapping value followed by a dedent — give it ``{}``.
    fixed: list[str] = []
    rlines = rendered.splitlines()
    for idx, line in enumerate(rlines):
        m = _BARE_KEY.match(line)
        if m:
            indent = len(m.group(1))
            # Find the next non-blank line.
            nxt = None
            for j in range(idx + 1, len(rlines)):
                if rlines[j].strip():
                    nxt = rlines[j]
                    break
            nxt_indent = (len(nxt) - len(nxt.lstrip())) if nxt is not None else -1
            if nxt is None or nxt_indent <= indent:
                # No child content survived -> empty mapping placeholder.
                fixed.append(f"{m.group(1)}{m.group(2)}: {{}}")
                continue
        fixed.append(line)

    return "\n".join(fixed) + "\n"


def check_file(path: str) -> bool:
    with open(path, "r", encoding="utf-8") as fh:
        raw = fh.read()
    rendered = prerender(raw)
    try:
        docs = list(yaml.safe_load_all(rendered))
    except yaml.YAMLError as exc:  # pragma: no cover - exercised in tests
        print(f"[FAIL] {path}: {exc}")
        return False
    # A template can render to nothing (fully gated off). That is fine.
    print(f"[ OK ] {path}: {len(docs)} doc(s) after prerender")
    return True


def main(argv: list[str]) -> int:
    if len(argv) > 1:
        targets = argv[1:]
    else:
        here = os.path.dirname(os.path.abspath(__file__))
        chart = os.path.join(here, os.pardir, "solution", "chart", "webapp", "templates")
        targets = sorted(glob.glob(os.path.join(chart, "**", "*.yaml"), recursive=True))

    ok = True
    for path in targets:
        ok = check_file(path) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
