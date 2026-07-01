#!/usr/bin/env python3
"""Generate <variant>/k8s/30-prometheus-config.yaml from the source-of-truth files.

The Prometheus config and rule files live ONCE under <variant>/prometheus/ so that
`promtool check config` / `check rules` / `test rules` validate the exact bytes
that ship. The in-cluster ConfigMap is DERIVED from them here, with one change:
the `rule_files` paths are rewritten from the repo-relative `rules/...` (which
promtool resolves from the prometheus/ dir) to the absolute in-cluster mount path
`/etc/prometheus/rules/...` (where the ConfigMap dir is mounted in the pod).

This keeps a single source of truth and makes drift detectable: validate.sh
re-runs this generator and `git diff --exit-code`s the result, so an edit to a
rule file that is not reflected in the ConfigMap fails the gate.

Usage:
  python3 scripts/gen-configmap.py [--variant solution|starter] [--check]
    (default variant: solution; --check prints to stdout instead of writing)
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

HEADER_TMPL = """\
# GENERATED FILE -- do not edit by hand.
# Source of truth: {variant}/prometheus/{{prometheus.yml,rules/*.yml}}
# Regenerate with: python3 scripts/gen-configmap.py --variant {variant}
#
# This ConfigMap carries the Prometheus server config and both rule files. It is
# mounted into the prometheus Deployment two ways (see 40-prometheus.yaml):
#   * prometheus.yml via subPath at /etc/prometheus/prometheus.yml
#   * the whole map as a dir at /etc/prometheus/rules (so each rule file appears
#     at /etc/prometheus/rules/<name>.yml, matching the rewritten rule_files).
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: lab-obs
  labels:
    app: prometheus
    app.kubernetes.io/part-of: observability-stack
data:
"""


def indent(text: str, spaces: int) -> str:
    pad = " " * spaces
    # Preserve blank lines without trailing whitespace.
    return "\n".join((pad + line) if line else "" for line in text.splitlines())


def render(variant: str) -> str:
    prom_dir = ROOT / variant / "prometheus"
    prom_yml = (prom_dir / "prometheus.yml").read_text()
    # Rewrite the rule_files paths to the absolute in-cluster mount location.
    prom_yml = prom_yml.replace(
        "  - rules/recording.rules.yml", "  - /etc/prometheus/rules/recording.rules.yml"
    ).replace(
        "  - rules/alerting.rules.yml", "  - /etc/prometheus/rules/alerting.rules.yml"
    )
    rec = (prom_dir / "rules" / "recording.rules.yml").read_text()
    alert = (prom_dir / "rules" / "alerting.rules.yml").read_text()

    parts = [HEADER_TMPL.format(variant=variant)]
    for name, body in (
        ("prometheus.yml", prom_yml),
        ("recording.rules.yml", rec),
        ("alerting.rules.yml", alert),
    ):
        parts.append(f"  {name}: |\n")
        parts.append(indent(body, 4))
        parts.append("\n")
    rendered = "".join(parts)
    return rendered.rstrip("\n") + "\n"


def main() -> int:
    variant = "solution"
    if "--variant" in sys.argv:
        variant = sys.argv[sys.argv.index("--variant") + 1]
    if variant not in ("solution", "starter"):
        print(f"unknown variant: {variant}", file=sys.stderr)
        return 2

    rendered = render(variant)
    out = ROOT / variant / "k8s" / "30-prometheus-config.yaml"

    if "--check" in sys.argv:
        sys.stdout.write(rendered)
        return 0

    out.write_text(rendered)
    print(f"wrote {out.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
