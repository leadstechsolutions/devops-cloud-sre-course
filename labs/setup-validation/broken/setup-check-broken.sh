#!/usr/bin/env bash
#
# setup-check-broken.sh — TROUBLESHOOTING FIXTURE (intentionally buggy).
#
# This is a deliberately broken copy of the toolchain checker. It looks fine,
# parses fine, and even passes shellcheck — but its version comparison is WRONG.
#
# ── THE BUG ─────────────────────────────────────────────────────────────────
# version_ge() below compares versions as STRINGS with `[[ ... > ... ]]`, which
# does a lexicographic (dictionary) comparison, not a numeric one. Character by
# character, "3.9" is GREATER than "3.10" because the 4th character '9' sorts
# after '1'. So:
#
#   - python3 3.9   vs   min 3.10   ->  WRONGLY reported PASS  (3.9 is too old!)
#   - python3 3.10  vs   min 3.9    ->  WRONGLY reported FAIL  (3.10 is fine!)
#   - terraform 1.6 vs   min 1.10   ->  WRONGLY reported PASS
#
# The fix lives in solution/lib/check.sh: split on '.' and compare each field
# NUMERICALLY (10#$field) instead of comparing whole strings. See the lab
# README "Instructor answer key" section.
#
# tests/run-tests.sh asserts that THIS file gets the 3.9-vs-3.10 case wrong,
# so if someone "fixes" it here the test will fail and flag the silent repair.
#
set -uo pipefail

# --- BUGGY version compare: string/lexicographic, not numeric -----------------
version_ge() {
  local have="$1" want="$2"
  have="${have#[vV]}"; want="${want#[vV]}"
  # BUG: lexicographic string comparison. "3.9" > "3.10" is TRUE here, which is
  # the opposite of what semver requires. Should split on '.' and compare each
  # field as an integer.
  if [[ "$have" == "$want" ]]; then
    return 0
  elif [[ "$have" > "$want" ]]; then
    return 0
  else
    return 1
  fi
}

extract_version() {
  printf '%s\n' "$*" | grep -oE 'v?[0-9]+(\.[0-9]+){1,3}' | head -n1 | sed 's/^[vV]//'
}

check_tool() {
  local name="$1" cmd="$2" min="$3"
  local raw ver
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf '[FAIL] %-11s missing (need >= %s)\n' "$name" "$min"
    return 1
  fi
  raw="$("$cmd" --version 2>&1 || true)"
  ver="$(extract_version "$raw")"
  if version_ge "$ver" "$min"; then
    printf '[PASS] %-11s %-10s (need >= %s)\n' "$name" "$ver" "$min"
    return 0
  else
    printf '[FAIL] %-11s %-10s (need >= %s) -- too old\n' "$name" "$ver" "$min"
    return 1
  fi
}

echo "== toolchain check (BROKEN fixture) =="
fail=0
check_tool "git"       "git"       "2.30" || fail=1
check_tool "python3"   "python3"   "3.10" || fail=1
check_tool "terraform" "terraform" "1.6"  || fail=1
echo "== done (fail=$fail) =="
exit "$fail"
