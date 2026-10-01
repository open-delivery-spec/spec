#!/usr/bin/env bash
# Checks and tests every Rego policy in this repository with OPA 1.x:
#
#   1. every .rego file compiles in strict mode, both as OPA 1.x reads it and
#      as the ODS CLI does (OPA's v0-compatible mode, which reads a module in
#      OPA 1.0 syntax only when it imports rego.v1);
#   2. every template under examples/ passes the unit tests next to it
#      (<name>_test.rego); the script reports how much of each template the
#      tests cover, and fails below MIN_COVERAGE percent (default 0: report
#      only);
#   3. every conformance scenario's policy, evaluated on its input.json,
#      yields its expected.json (spec/conformance/conformance_test.rego).
#
# The policies share one package (ods.policy), so each is checked and tested
# on its own. scripts/check-example-policies.sh tests the templates through
# the reference CLI instead.
#
# Usage: scripts/test-policies.sh        (opa on PATH, or OPA=/path/to/opa;
#                                         MIN_COVERAGE=100 to gate on coverage)
set -euo pipefail
cd "$(dirname "$0")/.."
OPA=${OPA:-opa}
MIN_COVERAGE=${MIN_COVERAGE:-0}
fail=0

below_min() { awk -v got="$1" -v min="$MIN_COVERAGE" 'BEGIN { exit !(got < min) }'; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# ── 1. Every file compiles, as OPA 1.x and the ODS CLI read it ───────────
files=0
while IFS= read -r f; do
  files=$((files + 1))
  if ! "$OPA" check --strict "$f" >"$tmp/out" 2>&1 ||
     ! "$OPA" check --strict --v0-compatible "$f" >>"$tmp/out" 2>&1; then
    echo "FAIL $f does not compile (write OPA 1.0 syntax and import rego.v1)"
    sed 's/^/     /' "$tmp/out"
    fail=1
  fi
done < <(find . -name '*.rego' -not -path './.git/*' | sort)
echo "ok   $files policy files checked in strict mode"

# ── 2. The templates pass their unit tests; report their coverage ────────
for policy in examples/*.rego examples/walkthrough/.ods/policy.rego; do
  case $policy in *_test.rego) continue ;; esac
  tests=${policy%.rego}_test.rego
  if [ ! -f "$tests" ]; then
    if below_min 0; then
      echo "FAIL $policy has no unit tests ($tests), below MIN_COVERAGE=${MIN_COVERAGE}%"
      fail=1
    else
      echo "note $policy has no unit tests ($tests)"
    fi
    continue
  fi
  if ! "$OPA" test "$policy" "$tests" >"$tmp/out" 2>&1; then
    echo "FAIL $tests"
    sed 's/^/     /' "$tmp/out"
    fail=1
    continue
  fi
  passed=$(tail -n 1 "$tmp/out")
  "$OPA" test --coverage "$policy" "$tests" >"$tmp/coverage.json"
  pct=$(jq -r --arg p "$policy" '(.files[$p].coverage // 0) * 10 | round / 10' "$tmp/coverage.json")
  missed=""
  if [ "$pct" != 100 ]; then
    lines=$(jq -r --arg p "$policy" '[.files[$p].not_covered[]?.start.row] | unique | map(tostring) | join(", ")' "$tmp/coverage.json")
    missed="; line(s) never evaluated: $lines"
  fi
  if below_min "$pct"; then
    echo "FAIL $policy: its tests cover ${pct}% of it, below MIN_COVERAGE=${MIN_COVERAGE}%$missed"
    fail=1
  else
    echo "ok   $policy · $passed, ${pct}% of its lines covered$missed"
  fi
done

# ── 3. Every conformance scenario's policy yields its expected output ────
for dir in spec/conformance/*/; do
  dir=${dir%/}
  [ -f "$dir/input.json" ] || continue
  if "$OPA" test spec/conformance/conformance_test.rego "$dir/policy.rego" \
       "conformance.input:$dir/input.json" \
       "conformance.expected:$dir/expected.json" >"$tmp/out" 2>&1; then
    echo "ok   $(basename "$dir") yields its expected.json"
  else
    echo "FAIL $(basename "$dir") does not yield its expected.json"
    sed 's/^/     /' "$tmp/out"
    fail=1
  fi
done

if [ "$fail" != 0 ]; then
  echo "Policy checks failed."
  exit 1
fi
echo "All policies compile and pass their tests."
