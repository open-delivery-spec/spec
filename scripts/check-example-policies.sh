#!/usr/bin/env bash
# Checks the example policies under examples/ with the reference CLI:
#
#   1. every example policy evaluates on every conformance input (it must at
#      least compile and yield a verdict), and
#   2. the open-source templates behave as their documentation says on the
#      scenarios they are written for.
#
# Usage: scripts/check-example-policies.sh        (ods on PATH, or ODS=/path/to/ods)
set -euo pipefail
cd "$(dirname "$0")/.."
ODS=${ODS:-ods}
fail=0

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# ── 1. Every policy, every scenario ──────────────────────────────────────
for policy in examples/*.rego; do
  for dir in spec/conformance/*/; do
    input="$dir/input.json"
    [ -f "$input" ] || continue
    # A denial exits non-zero and still prints a verdict on stdout; a parse
    # or eval error prints no verdict at all.
    out=$("$ODS" check --input "$input" --policy "$policy" --json 2>"$tmp/stderr" || true)
    if ! jq -e 'has("allowed")' <<<"$out" >/dev/null 2>&1; then
      echo "FAIL $policy on $(basename "$dir"): no verdict"
      cat "$tmp/stderr"
      fail=1
      continue
    fi
    # A message containing "%!" is a sprintf verb that did not match its
    # value (OPA hands integral numbers to Go as int64, so %.0f breaks on
    # them). Adopters copy these messages; they must render.
    if jq -r '((.denials // []) + (.warnings // []))[]' <<<"$out" | grep -q '%!'; then
      echo "FAIL $policy on $(basename "$dir"): a message did not render"
      jq -r '((.denials // []) + (.warnings // []))[]' <<<"$out" | grep '%!'
      fail=1
    fi
  done
  echo "ok   $policy evaluates on every conformance scenario"
done

# ── 2. Documented behaviour of the open-source templates ─────────────────
# expect <policy> <scenario> <allowed> <review_tier|-> <warning substring|-|*>
#   review_tier "-" : do not care
#   warning "-"     : no warning expected;  "*" : do not care
expect() {
  local policy=$1 scenario=$2 allowed=$3 tier=$4 warn=$5
  local out got_allowed got_tier got_warns ok=1
  out=$("$ODS" check --input "spec/conformance/$scenario/input.json" --policy "examples/$policy" --json 2>/dev/null || true)
  got_allowed=$(jq -r '.allowed' <<<"$out")
  got_tier=$(jq -r '.review_tier // "standard"' <<<"$out")
  got_warns=$(jq -r '(.warnings // []) | join(" | ")' <<<"$out")
  [ "$got_allowed" = "$allowed" ] || ok=0
  [ "$tier" = "-" ] || [ "$got_tier" = "$tier" ] || ok=0
  case "$warn" in
    "*") ;;
    "-") [ -z "$got_warns" ] || ok=0 ;;
    *)   [[ "$got_warns" == *"$warn"* ]] || ok=0 ;;
  esac
  if [ "$ok" = 1 ]; then
    echo "ok   $policy · $scenario → allowed=$got_allowed tier=$got_tier"
  else
    echo "FAIL $policy · $scenario: want allowed=$allowed tier=$tier warning~'$warn'; got allowed=$got_allowed tier=$got_tier warnings='$got_warns'"
    fail=1
  fi
}

D=ods-policy-oss-disclosure.rego
expect $D warn-ai-undisclosed         true  elevated "not disclosed"
expect $D evidence-inferred-elevated  true  elevated "not disclosed"
expect $D pass-ai-disclosed           true  standard -
expect $D evidence-attested-auto      true  standard -
expect $D warn-ai-no-tests            true  elevated "no test was added"
expect $D pass-tested-change          true  auto     -
expect $D pass-ai-covered-patch       true  auto     -
expect $D warn-ai-low-patch-coverage  true  elevated "covered by tests"
expect $D pass-human-code             true  standard -
expect $D warn-detect-inconclusive    true  standard -
expect $D block-critical-issue        false -        "*"

N=ods-policy-oss-no-ai.rego
expect $N pass-ai-disclosed           false -        "*"
expect $N pass-tested-change          false -        "*"
expect $N warn-ai-undisclosed         true  elevated "suspected"
expect $N pass-human-code             true  standard -
expect $N block-critical-issue        false -        "*"

# ── 3. The STRICT blocks of the disclosure template still compile ────────
# They ship commented out; uncomment every `# deny[msg] {` … `# }` block
# and check they deny what the comments say.
awk '
  /^# deny\[msg\] \{$/ { s = 1 }
  s { sub(/^# ?/, "") }
  { print }
  s && /^\}$/ { s = 0 }
' examples/ods-policy-oss-disclosure.rego > "$tmp/strict.rego"
if [ "$(grep -c '^deny\[msg\] {' "$tmp/strict.rego")" != 3 ]; then
  echo "FAIL could not uncomment the STRICT blocks of ods-policy-oss-disclosure.rego"
  fail=1
fi
strict() { # <scenario> <allowed>
  local out got
  out=$("$ODS" check --input "spec/conformance/$1/input.json" --policy "$tmp/strict.rego" --json 2>"$tmp/stderr" || true)
  got=$(jq -r '.allowed' <<<"$out" 2>/dev/null || echo "?")
  if [ "$got" = "$2" ]; then
    echo "ok   ods-policy-oss-disclosure.rego (STRICT) · $1 → allowed=$got"
  else
    echo "FAIL ods-policy-oss-disclosure.rego (STRICT) · $1: want allowed=$2, got allowed=$got"
    cat "$tmp/stderr"
    fail=1
  fi
}
strict warn-ai-no-tests     false   # attested AI source without tests
strict warn-ai-undisclosed  true    # suspicion at 0.6 stays below the 0.8 deny threshold
strict pass-tested-change   true
strict pass-human-code      true

[ "$fail" = 0 ] && echo "All example policies behave as documented." || { echo "Example policy checks failed."; exit 1; }
