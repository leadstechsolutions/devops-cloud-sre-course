#!/usr/bin/env bash
# Validation runner for the career-prep module (Week 25, non-code).
#
# This lab ships documents, not runnable code, so the gates are PRESENCE +
# STRUCTURE + SUBSTANCE checks (per 07-templates/00-artifact-standard.md §4,
# which exempts non-technical classes from runnable code but still requires
# concrete, substantive artifacts on disk — not stubs):
#
#   Gate 1: every required file exists.
#   Gate 2: every required file exceeds a minimum word count (substance, not stub).
#   Gate 3: each of the 5 system-design prompts has BOTH a model-answer.md and a
#           scoring-rubric.md, each above its word floor.
#   Gate 4: starter/ ships the three required worksheets, each above its floor.
#   Gate 5: the bullet-shaped artifacts contain the expected structure markers
#           (so a file can't pass on word count alone by being filler).
#
# Contract: one line per check; exits non-zero if ANY gate fails. Tool-guarded
# (uses only coreutils + bash + wc; no external validators required).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE" || exit 2

fail=0
pass=0

# words <file> -> prints the word count (0 if missing)
words() {
  if [[ -f "$1" ]]; then wc -w < "$1" | tr -d ' '; else echo 0; fi
}

# check_file <path> <min_words>
# Asserts the file exists AND has at least <min_words> words.
check_file() {
  local path="$1" min="$2" w
  if [[ ! -f "$path" ]]; then
    printf '  [FAIL] missing: %s\n' "$path"
    fail=$((fail + 1))
    return
  fi
  w="$(words "$path")"
  if (( w >= min )); then
    printf '  [PASS] %-58s %5s words (>= %s)\n' "$path" "$w" "$min"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %-58s %5s words (< %s) -- looks like a stub\n' "$path" "$w" "$min"
    fail=$((fail + 1))
  fi
}

# check_contains <path> <label> <pattern...>
# Asserts the file exists and matches the grep -E pattern (structure marker).
check_contains() {
  local path="$1" label="$2" pattern="$3"
  if [[ -f "$path" ]] && grep -Eiq "$pattern" "$path"; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s (missing pattern: %s)\n' "$label" "$pattern"
    fail=$((fail + 1))
  fi
}

echo "== validating career-prep =="

# ---------------------------------------------------------------------------
# Gate 1+2: top-level required solution documents (presence + substance)
# Word floors are deliberately high enough that a stub cannot pass.
# ---------------------------------------------------------------------------
echo "-- core solution documents --"
check_file "README.md"                              250
check_file "solution/resume-rubric.md"              700
check_file "solution/impact-bullets.md"             700
check_file "solution/star-bank.md"                 1200
check_file "solution/take-home-brief.md"            500
check_file "solution/take-home-solution-outline.md" 500
check_file "solution/mock-interview-protocol.md"    600
check_file "solution/negotiation.md"                700
check_file "solution/portfolio-checklist.md"        600

# ---------------------------------------------------------------------------
# Gate 3: each of the 5 system-design prompts ships model-answer + rubric.
# ---------------------------------------------------------------------------
echo "-- system-design prompts (model-answer + scoring-rubric each) --"
for prompt in url-shortener rate-limiter multi-region-web-app \
              observability-pipeline cicd-platform; do
  check_file "solution/system-design/$prompt/model-answer.md"  600
  check_file "solution/system-design/$prompt/scoring-rubric.md" 200
done

# ---------------------------------------------------------------------------
# Gate 4: starter worksheets (intentionally incomplete, but substantive scaffolds).
# ---------------------------------------------------------------------------
echo "-- starter worksheets --"
check_file "starter/resume-template.md"  200
check_file "starter/star-worksheet.md"   200
check_file "starter/design-worksheet.md" 250

# ---------------------------------------------------------------------------
# Gate 5: structure markers -- guard against "substance by word count alone".
# These assert the KEY frameworks are actually present, not just lots of prose.
# ---------------------------------------------------------------------------
echo "-- structure / framework markers --"
check_contains "solution/impact-bullets.md" \
  "impact-bullets: X-Y-Z formula present"            "X-Y-Z|X.Y.Z"
check_contains "solution/impact-bullets.md" \
  "impact-bullets: has >=10 before/after examples"   "Before:.*After:|### 10\.|^### 10"
check_contains "solution/star-bank.md" \
  "star-bank: STAR letters defined"                  "Situation.*Task.*Action.*Result|S . Situation"
check_contains "solution/star-bank.md" \
  "star-bank: includes a failure story"              "failure"
check_contains "solution/resume-rubric.md" \
  "resume-rubric: covers ATS + LLM + human readers"  "ATS"
check_contains "solution/resume-rubric.md" \
  "resume-rubric: covers the LLM screener"           "LLM"
check_contains "solution/portfolio-checklist.md" \
  "portfolio-checklist: maps to the capstone"        "capstone"
check_contains "solution/portfolio-checklist.md" \
  "portfolio-checklist: maps to course labs"         "labs/"
check_contains "starter/star-worksheet.md" \
  "starter star-worksheet: has TODO gaps"            "TODO"
check_contains "starter/design-worksheet.md" \
  "starter design-worksheet: has TODO gaps"          "TODO"

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
