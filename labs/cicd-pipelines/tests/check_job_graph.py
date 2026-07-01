#!/usr/bin/env python3
"""Validate GitHub Actions workflow job graphs.

For each workflow passed on the command line (or the solution defaults), this:
  1. Parses the YAML (so it doubles as a parse gate).
  2. Confirms every value in a job's `needs:` references a job that exists.
  3. Confirms the `needs` graph is acyclic (catches typo'd self/loop deps).

Exit code 0 only when every workflow passes all three checks. Used by
validate.sh and by tests/test_workflows.py.
"""
from __future__ import annotations

import sys
from pathlib import Path

import yaml

# Default targets relative to the module root (parent of tests/).
MODULE_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_WORKFLOWS = [
    MODULE_ROOT / "solution" / ".github" / "workflows" / "ci.yml",
    MODULE_ROOT / "solution" / ".github" / "workflows" / "cd.yml",
]


def _as_needs_list(raw) -> list[str]:
    """`needs:` may be a single string or a list. Normalize to a list."""
    if raw is None:
        return []
    if isinstance(raw, str):
        return [raw]
    if isinstance(raw, list):
        return [str(x) for x in raw]
    raise TypeError(f"unexpected needs value: {raw!r}")


def _has_cycle(graph: dict[str, list[str]]) -> list[str]:
    """Return a cycle path if the dependency graph has one, else []."""
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {node: WHITE for node in graph}
    stack: list[str] = []

    def visit(node: str) -> list[str]:
        color[node] = GRAY
        stack.append(node)
        for dep in graph.get(node, []):
            if dep not in color:
                continue  # missing dep reported separately
            if color[dep] == GRAY:
                idx = stack.index(dep)
                return stack[idx:] + [dep]
            if color[dep] == WHITE:
                cyc = visit(dep)
                if cyc:
                    return cyc
        stack.pop()
        color[node] = BLACK
        return []

    for node in graph:
        if color[node] == WHITE:
            cyc = visit(node)
            if cyc:
                return cyc
    return []


def check_workflow(path: Path) -> list[str]:
    """Return a list of human-readable errors for one workflow (empty == OK)."""
    errors: list[str] = []
    try:
        data = yaml.safe_load(path.read_text())
    except yaml.YAMLError as exc:  # parse gate
        return [f"YAML parse error: {exc}"]

    if not isinstance(data, dict) or "jobs" not in data:
        return [f"no 'jobs' mapping found in {path.name}"]

    jobs = data["jobs"]
    if not isinstance(jobs, dict):
        return [f"'jobs' is not a mapping in {path.name}"]

    job_names = set(jobs.keys())
    graph: dict[str, list[str]] = {}

    for name, spec in jobs.items():
        spec = spec or {}
        needs = _as_needs_list(spec.get("needs"))
        graph[name] = needs
        for dep in needs:
            if dep not in job_names:
                errors.append(
                    f"job '{name}' needs '{dep}', which is not a defined job "
                    f"(jobs: {sorted(job_names)})"
                )
            if dep == name:
                errors.append(f"job '{name}' needs itself")

    cycle = _has_cycle(graph)
    if cycle:
        errors.append("dependency cycle: " + " -> ".join(cycle))

    return errors


def main(argv: list[str]) -> int:
    targets = [Path(a) for a in argv[1:]] or DEFAULT_WORKFLOWS
    overall_ok = True
    for wf in targets:
        if not wf.exists():
            print(f"[FAIL] {wf}: file not found")
            overall_ok = False
            continue
        errs = check_workflow(wf)
        if errs:
            overall_ok = False
            for e in errs:
                print(f"[FAIL] {wf.name}: {e}")
        else:
            print(f"[PASS] {wf.name}: job graph valid (needs all resolve, acyclic)")
    return 0 if overall_ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
