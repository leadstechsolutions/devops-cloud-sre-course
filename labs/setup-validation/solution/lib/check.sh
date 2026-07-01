# shellcheck shell=bash
# lib/check.sh — shared helpers for the setup-validation toolchain checker.
#
# This file is meant to be *sourced*, not executed. It does NOT set
# `set -euo pipefail` itself; each entrypoint owns its own shell options.
#
# Provided functions:
#   normalize_version <raw>      strip a leading 'v' and any build/pre-release
#                                suffix, echo a clean MAJOR[.MINOR[.PATCH]] string
#   version_ge <have> <want>     true (exit 0) iff have >= want, numeric per-field
#   extract_version <raw>        pull the first dotted version token out of noisy
#                                CLI output (e.g. "git version 2.34.1" -> 2.34.1)
#   detect_version <cmd> <args>  run a tool's version command, echo the cleaned
#                                version, or echo nothing + return 1 if absent
#   check_tool ...               PASS/FAIL one tool against a minimum (see below)
#
# Diagnostic output goes to STDERR so STDOUT stays clean for the report.

# Guard against double-sourcing.
if [[ -n "${_CHECK_SH_SOURCED:-}" ]]; then
  # SC2317: reachable on a second source — that is the guard's entire purpose.
  # shellcheck disable=SC2317
  return 0 2>/dev/null || true
fi
_CHECK_SH_SOURCED=1

# ---------------------------------------------------------------------------
# Colour / status markers. Honour NO_COLOR and non-tty output.
# ---------------------------------------------------------------------------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_RED=''; C_YELLOW=''; C_RESET=''
fi

# Counters consumed by the entrypoint scripts.
CHECK_PASS=0
CHECK_FAIL=0
CHECK_WARN=0

# ---------------------------------------------------------------------------
# normalize_version RAW
# Echo a clean numeric version: leading 'v' removed, any '-'/'+'/whitespace
# suffix dropped, only the dotted numeric head kept. Non-numeric -> "".
#   v1.6.0          -> 1.6.0
#   3.16.3+gcfd0749 -> 3.16.3
#   1.14.1-beta2    -> 1.14.1
# ---------------------------------------------------------------------------
normalize_version() {
  local raw="$1"
  raw="${raw#[vV]}"                       # drop a single leading v/V
  raw="${raw%%[-+ ]*}"                    # cut at first '-', '+' or space
  # Keep only a leading run of digits-and-dots; reject anything else.
  if [[ "$raw" =~ ^([0-9]+(\.[0-9]+)*) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf ''
  fi
}

# ---------------------------------------------------------------------------
# version_ge HAVE WANT
# Return 0 iff HAVE >= WANT, comparing field by field NUMERICALLY (not as
# strings, so 3.10 > 3.9). Missing trailing fields are treated as 0, so
# "3.10" >= "3.10.0" and "2" >= "2.0".
# ---------------------------------------------------------------------------
version_ge() {
  local have want
  have="$(normalize_version "$1")"
  want="$(normalize_version "$2")"

  # An unparseable HAVE can never satisfy a constraint.
  [[ -z "$have" ]] && return 1
  # An empty WANT means "any version is fine".
  [[ -z "$want" ]] && return 0

  local -a h w
  IFS='.' read -r -a h <<<"$have"
  IFS='.' read -r -a w <<<"$want"

  local n=${#h[@]}
  (( ${#w[@]} > n )) && n=${#w[@]}

  local i hv wv
  for (( i = 0; i < n; i++ )); do
    hv=${h[i]:-0}
    wv=${w[i]:-0}
    # Force base-10 so values like "08" never trip octal parsing.
    hv=$((10#$hv))
    wv=$((10#$wv))
    if (( hv > wv )); then return 0; fi
    if (( hv < wv )); then return 1; fi
  done
  return 0   # all fields equal -> have == want -> >=
}

# ---------------------------------------------------------------------------
# extract_version RAW...
# Echo the first token that looks like a dotted version (X or X.Y or X.Y.Z),
# optionally prefixed with 'v'. Used to pull a version out of noisy output:
#   "git version 2.34.1"                       -> 2.34.1
#   "aws-cli/2.32.11 Python/3.13.9 ..."        -> 2.32.11
#   "Docker version 29.1.2, build 890dcca"     -> 29.1.2
# Returns 1 (and echoes nothing) if no version-looking token is present.
# ---------------------------------------------------------------------------
extract_version() {
  local raw="$*"
  # Grab the first vN.N.N / N.N.N / N.N token. -P would be nicer but is not
  # portable to macOS grep, so use a POSIX ERE and trim a leading 'v' after.
  local tok
  tok="$(printf '%s\n' "$raw" \
    | grep -oE 'v?[0-9]+(\.[0-9]+){1,3}' \
    | head -n1)"
  if [[ -z "$tok" ]]; then
    # Fall back to a bare integer (e.g. a tool that only prints "2").
    tok="$(printf '%s\n' "$raw" | grep -oE 'v?[0-9]+' | head -n1)"
  fi
  [[ -z "$tok" ]] && return 1
  normalize_version "$tok"
}

# ---------------------------------------------------------------------------
# detect_version CMD [VERSION-ARGS...]
# Run "CMD VERSION-ARGS" (default args: --version), capture stdout+stderr,
# echo the extracted version. Returns:
#   0 + version on success
#   1 + nothing  if CMD is not on PATH or no version could be parsed
# Never lets a failing tool kill the caller (always returns, never exits).
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# check_tool NAME CMD MIN REQUIRED HINT [VERSION-ARGS...]
# The workhorse. Detects CMD's version, compares to MIN, prints a status line,
# and updates the CHECK_PASS/CHECK_FAIL/CHECK_WARN counters.
#
#   NAME      human label, e.g. "terraform"
#   CMD       executable to look for, e.g. "terraform"
#   MIN       minimum acceptable version, e.g. "1.6" ("" = any version)
#   REQUIRED  "required" or "optional"
#   HINT      one-line remediation shown on FAIL/missing
#   rest      optional version args (default --version)
#
# Returns 0 if the tool satisfies its constraint (PASS), 1 otherwise. A missing
# OPTIONAL tool is a WARN (returns 0 — it does not fail the suite); a missing or
# too-old REQUIRED tool is a FAIL (returns 1).
# ---------------------------------------------------------------------------
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

  # Not found on PATH (or version unparseable).
  if [[ "$required" == "optional" ]]; then
    CHECK_WARN=$((CHECK_WARN + 1))
    printf '%s[WARN]%s %-11s %-10s (optional)\n' \
      "$C_YELLOW" "$C_RESET" "$name" "missing"
    printf '       hint: %s\n' "$hint"
    return 0
  fi

  CHECK_FAIL=$((CHECK_FAIL + 1))
  printf '%s[FAIL]%s %-11s %-10s (need >= %s) -- not installed\n' \
    "$C_RED" "$C_RESET" "$name" "missing" "${min:-any}"
  printf '       hint: %s\n' "$hint"
  return 1
}
