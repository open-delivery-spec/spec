---
title: Get Started
nav_order: 2
---

# Get Started

Start with the smallest production-ready loop: the ODS check on every pull request. It takes about five minutes and runs in CI.

> [!TIP]
> Want to see what an ODS-compliant PR looks like? Copy the [PR Template](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-pr-template.md) into `.github/PULL_REQUEST_TEMPLATE.md`.

---

## Path A: The check on every PR

**For**: Individual maintainers, open source projects, any team that wants to see AI-assisted changes and hold them to a policy in CI.

**Goal**: Attribute AI-assisted code, surface quality findings, score technical debt, and enforce policy — on every PR.

### 1. Install the CLI

**With Go (recommended):**

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@latest
```

**Pre-compiled binary:**

Each [release](https://github.com/open-delivery-spec/cli/releases) ships archives
named `ods_<version>_<os>_<arch>.tar.gz` for `darwin` and `linux` on `amd64` and
`arm64`, and `ods_<version>_windows_amd64.zip`. Set `VERSION` to the release you
want (without the leading `v`) and pick your platform:

```bash
VERSION=0.7.9

# macOS (Apple Silicon)
curl -L "https://github.com/open-delivery-spec/cli/releases/download/v${VERSION}/ods_${VERSION}_darwin_arm64.tar.gz" | tar xz
sudo mv ods /usr/local/bin/

# macOS (Intel)
curl -L "https://github.com/open-delivery-spec/cli/releases/download/v${VERSION}/ods_${VERSION}_darwin_amd64.tar.gz" | tar xz
sudo mv ods /usr/local/bin/

# Linux (amd64; use linux_arm64 on ARM)
curl -L "https://github.com/open-delivery-spec/cli/releases/download/v${VERSION}/ods_${VERSION}_linux_amd64.tar.gz" | tar xz
sudo mv ods /usr/local/bin/
```

### 2. Add to your CI

```yaml
name: ODS AI Quality Gate
on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0  # required for git diff against base
      - uses: open-delivery-spec/validate-action@v1
```

The Action automatically:
1. **Detects** AI-assisted code (`Co-Authored-By` trailers, PR disclosure, branch names, diff heuristics)
2. **Analyzes** code quality (built-in AI heuristics plus imported SARIF findings)
3. **Scores** technical debt impact (quality-driven, weighted by AI risk)
4. **Enforces** policy (OPA Rego — optional, place at `.ods/policy.rego`)

### 3. Run the pipeline locally

```bash
ods detect    # Is there AI code? (reads Co-Authored-By, PR body, branch, diff)
ods analyze   # What quality issues exist?
ods score     # How much technical debt does this add?
ods check     # Does the OPA policy allow this change?
```

**You're ready** when `ods check` passes and the validate-action reports `PASS` on every PR.

### Optional: Bring your own scanner (SARIF)

ODS can ingest SARIF v2.1.0 output from tools like semgrep or CodeQL and include their findings in the policy input's `issues[]` array. This lets a single Rego policy block on both ODS-native findings and external scanner findings.

Each command runs the pipeline itself and reads only the SARIF file you pass it, so give the file to the command whose result you want: `ods check --sarif` for the gate, `ods score --sarif` for the score, `ods analyze --sarif` for the findings list. Running `ods analyze --sarif` first does not carry the findings into a later `ods check`.

```bash
semgrep --config=auto --sarif > semgrep.sarif
ods check --sarif semgrep.sarif     # the gate sees the semgrep findings

# Or in CI:
- name: Semgrep
  run: semgrep --config=auto --sarif > semgrep.sarif
- name: ODS check
  run: ods check --sarif semgrep.sarif
```

The [walkthrough](https://github.com/open-delivery-spec/spec/tree/main/examples/walkthrough) shows the whole loop. With the Action, set `semgrep: true` or `sarif: path/to/your.sarif`; it passes the file to every stage.

### Optional: Real test coverage

ODS automatically detects coverage reports in the working directory and reads the coverage from them. Supported formats:

| Format | File(s) |
|--------|---------|
| Go | `coverage.out`, `cover.out` |
| LCOV | `lcov.info`, `coverage/lcov.info` |
| Cobertura | `coverage.xml`, `coverage/cobertura-coverage.xml` |
| NYC/Istanbul | `coverage-summary.json`, `coverage/coverage-summary.json` |

Generate coverage before running `ods score`:

```bash
# Go
go test ./... -coverprofile=coverage.out
ods score  # auto-detects coverage.out

# Jest (NYC)
npx jest --coverage
ods score  # auto-detects coverage/coverage-summary.json
```

When no coverage file is found, ODS sets `test_coverage = -1` ("not measured") and skips the coverage penalty; it never estimates coverage. Your Rego policies **must guard** coverage rules with `input.test_coverage >= 0` to avoid false positives on projects without coverage tooling.

---

## Path B: AI Disclosure

**For**: Teams using GitHub Copilot, Cursor, Claude Code, or other AI coding tools.

**Goal**: Make AI involvement explicit and machine-detectable.

### 1. Complete Path A first

AI disclosure builds on the quality gate checks.

### 2. Use `Co-Authored-By` trailers (automatic with most tools)

Claude Code, GitHub Copilot, and Cursor automatically add `Co-Authored-By` trailers to commits. ODS detects these without any configuration:

```text
feat(auth): add OAuth login

Co-Authored-By: Claude <noreply@anthropic.com>
```

For tools that don't emit `Co-Authored-By` automatically, add it manually, use the Linux kernel's `Assisted-by: AGENT:MODEL` trailer, or use the ODS supplemental trailer fields:

```text
feat(auth): add OAuth login

AI-assisted: true
AI-tool: GitHub Copilot
```

The detector reads `AI-assisted: true` (or `AI-generated: true`), `AI-tool:` and `AI-scope:`. Other `AI-*` lines from the retired commit-message module, such as `AI-review:` and `AI-confidence:`, are ignored.

### 3. Add AI disclosure to PR descriptions

```markdown
## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Auth module implementation
- Human Review: Verified OAuth flow and redirect validation
```

**You're AI-disclosure ready** when every AI-assisted change records what AI touched and what a human reviewed.

---

## Path C: Customize Enforcement Policy

**For**: Teams that want a hard gate tuned to their own quality bar.

**Goal**: Decide exactly which PRs block, using OPA Rego.

### 1. Complete Path A first

The policy runs as the `check` stage of the pipeline.

### 2. Add `.ods/policy.rego`

```rego
package ods.policy

default allow := true

# Block critical issues unconditionally
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Block high-confidence AI code with low test coverage
# NOTE: guard with >= 0 — value of -1 means "not measured", skip the check
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage >= 0
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}
```

See [Writing Policies (Rego)](policy-authoring.md) for the patterns and the [Policy Input Schema](schemas.md) for every field the policy can read.

### 3. Require the check in branch protection

Once `ods check` blocks the changes you care about, make the ODS workflow a required status check so violations can't merge.

---

## Rolling it out to a team

Nothing here needs a flag day. The Action reports before it enforces:

1. **Observe (week 1).** The workflow runs, the report appears on every PR, and
   branch protection does not require it yet. Note the findings that recur.
2. **Require the check (week 2).** Make the ODS workflow a required status
   check. With no `.ods/policy.rego`, only the built-in default applies.
3. **Add your policy (week 3+).** Commit `.ods/policy.rego` with the rules
   your team agreed on, starting from an [example](https://github.com/open-delivery-spec/spec/tree/main/examples).
   Prefer `warn` for a week, then turn the rules you trust into `deny`.

A message that has worked for teams adopting it:

> We're adopting [Open Delivery Spec](https://github.com/open-delivery-spec/spec)
> to make AI-assisted changes visible and easier to review. CI now runs the ODS
> check on every PR and posts a short report. This week is observe-only; next
> week the check becomes required. Questions? See the
> [Get Started](https://open-delivery-spec.github.io/spec/get-started.html) page.

---

## Troubleshooting

**The PR comment is too noisy.** Turn it off and keep the job summary and artifact:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    comment: "false"
```

**The comment does not appear on PRs from forks.** GitHub gives `pull_request`
workflows from a fork a read-only token, so the comment and review-routing
labels cannot be posted there. The check still runs and still fails on `BLOCK`;
the report is in the job summary and the `ods-report` artifact. Check out the
PR head by SHA (`github.event.pull_request.head.sha`) or keep the default merge
ref; a checkout of `github.head_ref` fails on fork PRs. To post the comment on
fork PRs anyway, use the `workflow_run` recipe in
[Permissions and Fork Pull Requests](https://github.com/open-delivery-spec/validate-action#permissions-and-fork-pull-requests).

**The diff covers the wrong range.** The Action diffs against `origin/main` by
default, not the PR's base branch. To diff against the PR base whatever branch
it targets, pass its commit:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    diff-base: ${{ github.event.pull_request.base.sha }}
```

Any other ref works too, e.g. `diff-base: origin/develop`.

**I want a specific CLI version.** Pin it with `cli-ref: v0.7.9` (any tag,
branch or commit of the CLI repository).

**I want to pass the PR body explicitly.** `pr-body: ${{ github.event.pull_request.body }}`;
the Action reads it from the event by default.

---

## Quick Reference

| If you want... | Start with |
|----------------|----------|
| The ODS check in CI | [Path A](#path-a-the-check-on-every-pr) |
| AI disclosure and attribution | [Path B](#path-b-ai-disclosure) |
| A hard gate tuned to your policy | [Path C](#path-c-customize-enforcement-policy) |
| The simplest possible setup | Add `open-delivery-spec/validate-action@v1` to your PR workflow |

> [!TIP]
> Not sure where to start? [Path A](#path-a-the-check-on-every-pr) takes five minutes.
