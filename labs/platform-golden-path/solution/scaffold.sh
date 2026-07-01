#!/usr/bin/env bash
#
# scaffold.sh — the golden-path generator.
#
# Copies template/ to a new service directory and substitutes the placeholder
# __SERVICE_NAME__ with the name you pass. The output is a complete, working
# service: app + tests + multi-stage Dockerfile + Helm chart + k8s manifests +
# GitHub Actions CI + README.
#
# Usage:
#   ./scaffold.sh <service-name> [output-dir]
#
#   <service-name>  DNS-1123 label: lowercase alphanumeric and '-', must start
#                   and end alphanumeric, <= 53 chars (leaves room for a release
#                   prefix in Helm fullnames).
#   [output-dir]    Where to create the service. Default: ./<service-name>
#
# Examples:
#   ./scaffold.sh orders
#   ./scaffold.sh payments-api ../generated/payments-api
#
# Exit codes: 0 ok; 1 usage/validation error; 2 output already exists.
set -euo pipefail

PLACEHOLDER="__SERVICE_NAME__"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${TEMPLATE_DIR:-$HERE/template}"

err() { printf 'scaffold: %s\n' "$*" >&2; }

usage() {
  sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# --- argument parsing -------------------------------------------------------
if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

SERVICE_NAME="$1"
OUT_DIR="${2:-./$SERVICE_NAME}"

# --- validation: must be a valid DNS-1123 label ------------------------------
# Kubernetes object names, Helm chart names, and image repo path segments all
# require this. Rejecting bad names here is the whole point of a paved road.
if [[ ! "$SERVICE_NAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
  err "invalid service name '$SERVICE_NAME'"
  err "must be a DNS-1123 label: lowercase [a-z0-9-], start/end alphanumeric"
  exit 1
fi
if [[ ${#SERVICE_NAME} -gt 53 ]]; then
  err "service name too long (${#SERVICE_NAME} > 53 chars)"
  exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  err "template directory not found: $TEMPLATE_DIR"
  exit 1
fi

if [[ -e "$OUT_DIR" ]]; then
  err "output path already exists: $OUT_DIR (refusing to overwrite)"
  exit 2
fi

# --- copy the template ------------------------------------------------------
# cp -R preserves the tree including dotfiles (.github, .dockerignore, .gitignore).
mkdir -p "$(dirname "$OUT_DIR")"
cp -R "$TEMPLATE_DIR" "$OUT_DIR"

# --- substitute the placeholder ---------------------------------------------
# 1) File CONTENTS: rewrite every text file in place. We escape nothing because
#    the validated name contains only [a-z0-9-], all safe in sed replacement.
# 2) File/DIR NAMES: the template happens to use the placeholder only in
#    contents, not in paths, but we rename anything that contains it anyway so
#    the generator stays correct if the template grows placeholder-named files.

# Rewrite contents. -print0/-d '' is null-safe for any path.
find "$OUT_DIR" -type f -print0 | while IFS= read -r -d '' f; do
  # Skip binary files defensively (none in this template, but be safe).
  if grep -Iq . "$f"; then
    sed -i "s/${PLACEHOLDER}/${SERVICE_NAME}/g" "$f"
  fi
done

# Rename any path components containing the placeholder (deepest first).
find "$OUT_DIR" -depth -name "*${PLACEHOLDER}*" -print0 | while IFS= read -r -d '' p; do
  newp="${p//${PLACEHOLDER}/${SERVICE_NAME}}"
  mv "$p" "$newp"
done

# --- post-conditions: the output must contain NO leftover placeholders ------
if grep -rIl "$PLACEHOLDER" "$OUT_DIR" >/dev/null 2>&1; then
  err "internal error: placeholder still present after substitution:"
  grep -rIl "$PLACEHOLDER" "$OUT_DIR" >&2 || true
  exit 1
fi

chmod -R u+rw "$OUT_DIR"

cat <<EOF
Generated service '$SERVICE_NAME' at: $OUT_DIR

Next steps:
  cd $OUT_DIR
  python -m unittest discover -s tests -p 'test_*.py' -v
  docker build -t $SERVICE_NAME:dev .
  helm lint chart && helm template $SERVICE_NAME chart | head
EOF
