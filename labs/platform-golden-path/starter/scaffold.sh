#!/usr/bin/env bash
#
# scaffold.sh — the golden-path generator (STARTER).
#
# Copies template/ to a new service directory and substitutes the placeholder
# __SERVICE_NAME__ with the name you pass.
#
# Usage:  ./scaffold.sh <service-name> [output-dir]
#
# YOUR JOB: complete the four TODOs below so the generator:
#   1. validates the service name as a DNS-1123 label,
#   2. refuses to overwrite an existing output dir,
#   3. substitutes __SERVICE_NAME__ in every text file's CONTENTS,
#   4. fails if any placeholder survives.
#
# Done when: `../solution/scaffold.sh demo /tmp/x` and your version produce the
# same tree, and `shellcheck scaffold.sh` is clean.
set -euo pipefail

# PLACEHOLDER is consumed by TODO 3/4 once you implement them. Until then it
# is (correctly) flagged unused; the directive below silences that one note.
# shellcheck disable=SC2034
PLACEHOLDER="__SERVICE_NAME__"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${TEMPLATE_DIR:-$HERE/template}"

err() { printf 'scaffold: %s\n' "$*" >&2; }

if [[ $# -lt 1 || $# -gt 2 ]]; then
  err "usage: ./scaffold.sh <service-name> [output-dir]"
  exit 1
fi

SERVICE_NAME="$1"
OUT_DIR="${2:-./$SERVICE_NAME}"

# TODO 1: reject SERVICE_NAME unless it is a DNS-1123 label (^[a-z0-9]([a-z0-9-]*[a-z0-9])?$)
#         and <= 53 chars. Print why and `exit 1` on failure.

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  err "template directory not found: $TEMPLATE_DIR"
  exit 1
fi

# TODO 2: if OUT_DIR already exists, refuse to overwrite (exit 2).

mkdir -p "$(dirname "$OUT_DIR")"
cp -R "$TEMPLATE_DIR" "$OUT_DIR"

# TODO 3: rewrite the placeholder in every TEXT file's contents under OUT_DIR.
#         Hint: find ... -type f -print0 | while read -d '' f; do ... sed -i ... ; done
#         Use `grep -Iq .` to skip binary files.

# TODO 4: if any placeholder survives, print the offending files and exit 1.

chmod -R u+rw "$OUT_DIR"
echo "Generated '$SERVICE_NAME' at: $OUT_DIR"
