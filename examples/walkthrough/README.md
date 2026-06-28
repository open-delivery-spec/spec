# End-to-End Walkthrough: catching an AI-introduced vulnerability

This is a complete, reproducible example of ODS doing the thing it exists for:
an AI-assisted change introduces a real security bug, a dedicated analyzer
(Semgrep) finds it, and the ODS policy gate **blocks the merge** — then passes
once the bug is fixed.

Every command output below is real (captured from the tools, not hand-written).

## The setup

```
examples/walkthrough/
├── app/runner.py        # the code under review (vulnerable)
├── semgrep-rules.yml    # a local Semgrep rule (so this reproduces offline)
└── .ods/policy.rego     # gate: block any high/critical issue
```

`app/runner.py` is the **AI-assisted change** — it passes untrusted input
straight to a shell:

```python
def run_user_command(user_input):
    # Untrusted input flows into a shell — command injection risk.
    return subprocess.run(user_input, shell=True, capture_output=True)
```

The policy blocks high/critical findings — including ones imported from an
external analyzer via `--sarif`:

```rego
package ods.policy
default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "high"
    msg := sprintf("%s: %s (%s:%d)", [issue.severity, issue.rule, issue.file, issue.line])
}
# (same for "critical")
```

## Prerequisites

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@latest
pip install semgrep
```

## Step 1 — run Semgrep, produce SARIF

```console
$ semgrep --config semgrep-rules.yml --sarif --output semgrep.sarif
Ran 1 rule on 1 file: 1 finding.
```

(In a real repo, `--config auto` uses Semgrep's public registry and catches the
same class of issue; the local rule here just keeps the example offline.)

## Step 2 — analyze: ODS ingests the finding

```console
$ ods analyze --sarif semgrep.sarif
⚠️  1 issue(s) found: 1 high
   Density: 0.0 issues/KLOC
   Top issues:
     🟠 [python-subprocess-shell-true] app/runner.py:11 — subprocess called with shell=True on untrusted input — command injection risk.
```

The Semgrep finding is carried through with its **own rule id and severity**
(`error` → `high`).

## Step 3 — score: it raises technical debt

```console
$ ods score --sarif semgrep.sarif
⚠️  Technical Debt Score
   Tech Debt Delta: +1.5 | AI Ratio: 0% | Defects: 0.0/KLOC | Critical: 1 | Coverage: N/A | Duplication: 0%
   Verdict: neutral (Moderate risk — review recommended, ensure adequate tests)
```

The high-severity finding counts as a critical issue in the score.

## Step 4 — check: the policy blocks the merge

```console
$ ods check --sarif semgrep.sarif --policy .ods/policy.rego
❌  Policy check failed
   Policy: .ods/policy.rego
   Denials:
     ❌ high: python-subprocess-shell-true (app/runner.py:11)
$ echo $?
1
```

`ods check` exits non-zero — in CI this fails the job and blocks the PR.

## Step 5 — fix it, and the gate passes

Pass an argument list instead of a shell string:

```diff
-def run_user_command(user_input):
-    # Untrusted input flows into a shell — command injection risk.
-    return subprocess.run(user_input, shell=True, capture_output=True)
+def run_user_command(args):
+    # args is a list; no shell, so user input cannot inject commands.
+    return subprocess.run(args, shell=False, capture_output=True)
```

```console
$ semgrep --config semgrep-rules.yml --sarif --output semgrep.sarif
Ran 1 rule on 1 file: 0 findings.

$ ods check --sarif semgrep.sarif --policy .ods/policy.rego
✅  Policy check passed
   Policy: .ods/policy.rego
$ echo $?
0
```

The vulnerability is gone, the finding disappears, and the merge is unblocked.

## The same thing in CI (one step)

The [validate-action](https://github.com/open-delivery-spec/validate-action)
does all of this on every PR — install Semgrep, run it, and gate on the result:

```yaml
- uses: actions/checkout@v7
  with:
    fetch-depth: 0
- uses: open-delivery-spec/validate-action@v1
  with:
    semgrep: true          # or: sarif: path/to/your.sarif
    policy: .ods/policy.rego
```

## Why this matters

ODS doesn't try to out-analyze Semgrep/CodeQL — it **governs** them: it ingests
their authoritative, multi-language findings, attributes AI involvement from
`Co-Authored-By` trailers, scores the debt, and enforces one Rego policy across
all of it. The built-in heuristics are only hints; the real teeth come from the
scanners you already trust.
