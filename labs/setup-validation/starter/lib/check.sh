# shellcheck shell=bash
# lib/check.sh — shared helpers for the setup-validation toolchain checker.
#
#   *** STARTER — you implement version_ge() (the one TODO below). ***
#
# This file is meant to be *sourced*, not executed. It does NOT set
# `set -euo pipefail` itself; each entrypoint owns its own shell options.
#
# Everything except version_ge() is provided for you. Implement version_ge so
# that the tests in tests/run-tests.sh pass and `../setup-check.sh` works. The
# golden rule: compare versions NUMERICALLY, field by field — a string compare
# makes "3.9" look greater than "3.10", which is the classic bug.

# Guard against double-sourcing.
if [[ -n "${_CHECK_SH_SOURCED:-}" ]]; then
  # shellcheck disable=SC2317
  return 0 2>/dev/null || true
fi
_CHECK_SH_SOURCED=1

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_RED=''; C_YELLOW=''; C_RESET=''
fi

CHECK_PASS=0
CHECK_FAIL=0
CHECK_WARN=0

# normalize_version RAW -> clean numeric "MAJOR[.MINOR[.PATCH]]" (provided).
normalize_version() {
  local raw="$1"
  raw="${raw#[vV]}"
  raw="${raw%%[-+ ]*}"
  if [[ "$raw" =~ ^([0-9]+(\.[0-9]+)*) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf ''
  fi
}

# ---------------------------------------------------------------------------
# version_ge HAVE WANT
# Return 0 (true) iff HAVE >= WANT, comparing each dotted field NUMERICALLY.
# Missing trailing fields count as 0 ("3.10" >= "3.10.0", "2" >= "2.0").
# An unparseable HAVE returns 1; an empty WANT means "any version" -> 0.
#
# TODO(student): implement this.
#   1. Run HAVE and WANT through normalize_version.
#   2. Return 1 if HAVE normalizes to empty; return 0 if WANT is empty.
#   3. Split both on '.' into arrays (IFS='.' read -r -a ...).
#   4. Walk fields 0..max-1, defaulting missing fields to 0, and compare with
#      arithmetic ((...)). Force base-10 with 10#$field so "08" is not octal.
#      Return 0 on the first field where HAVE > WANT, 1 where HAVE < WANT.
#   5. If all fields are equal, HAVE == WANT, so return 0.
#
# DO NOT use `[[ "$have" > "$want" ]]` — that is a STRING compare and will rank
# "3.9" above "3.10". That is exactly the bug this lab exists to teach.
# ---------------------------------------------------------------------------
version_ge() {
  local have want
  have="$(normalize_version "$1")"
  want="$(normalize_version "$2")"

  # TODO(student): replace the line below with a correct numeric comparison.
  : "REPLACE ME"
  return 1
}

# extract_version RAW... -> first dotted version token, 'v' stripped (provided).
extract_version() {
  local raw="$*"
  local tok
  tok="$(printf '%s\n' "$raw" \
    | grep -oE 'v?[0-9]+(\.[0-9]+){1,3}' \
    | head -n1)"
  if [[ -z "$tok" ]]; then
    tok="$(printf '%s\n' "$raw" | grep -oE 'v?[0-9]+' | head -n1)"
  fi
  [[ -z "$tok" ]] && return 1
  normalize_version "$tok"
}

# detect_version CMD [ARGS...] -> cleaned version, or return 1 if absent (provided).
detect_version() {
  local cmd="$1"; shift
  if ! command -v "$cmd" >/dev/null 2>&1; then
    return 1
  fi
  local args=("$@")
  (( ${#args[@]} == 0 )) && args=(--version)
  local out
  out="$("$cmd" "${args[@]}" 2>&1)" || true
  local ver
  ver="$(extract_version "$out")" || return 1
  [[ -z "$ver" ]] && return 1
  printf '%s' "$ver"
}

# check_tool NAME CMD MIN REQUIRED HINT [ARGS...] (provided).
check_tool() {
  local name="$1" cmd="$2" min="$3" required="$4" hint="$5"; shift 5
  local ver

  if ver="$(detect_version "$cmd" "$@")"; then
    if version_ge "$ver" "$min"; then
      CHECK_PASS=$((CHECK_PASS + 1))
      printf '%s[PASS]%s %-11s %-10s (need >= %s)\n' \
        "$C_GREEN" "$C_RESET" "$name" "$ver" "${min:-any}"
      return 0
    else
      CHECK_FAIL=$((CHECK_FAIL + 1))
      printf '%s[FAIL]%s %-11s %-10s (need >= %s) -- too old\n' \
        "$C_RED" "$C_RESET" "$name" "$ver" "${min:-any}"
      printf '       hint: %s\n' "$hint"
      return 1
    fi
  fi

  if [[ "$required" == "optional" ]]; then
    CHECK_WARN=$((CHECK_WARN + 1))
    printf '%s[WARN]%s %-11s %-10s (optional)\n' \
      "$C_YELLOW" "$C_RESET" "$name" "missing"
    printf '       hint: %s\n' "$hint"
    return 0
  else
    CHECK_FAIL=$((CHECK_FAIL + 1))
    printf '%s[FAIL]%s %-11s %-10s (need >= %s) -- not installed\n' \
      "$C_RED" "$C_RESET" "$name" "missing" "${min:-any}"
    printf '       hint: %s\n' "$hint"
    return 1
  fi
}
