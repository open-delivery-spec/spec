---
title: Get Started
nav_order: 2
---

# Get Started

Start with the smallest production-ready loop: **ODS AI Quality Gate**. This takes ~5 minutes and runs in CI.

> [!TIP]
> Want to see what an ODS-compliant PR looks like? Copy the [PR Template](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-pr-template.md) into `.github/PULL_REQUEST_TEMPLATE.md`.

---

## Path A: AI Quality Gate

**For**: Individual maintainers, open source projects, any team that wants automated AI code quality checks in CI.

**Goal**: Detect AI-generated code, analyze quality, score technical debt, and enforce policy — on every PR.

### 1. Install the CLI

**Binary install (recommended):**

Download a pre-compiled binary from the [releases page](https://github.com/open-delivery-spec/cli/releases/latest):

```bash
# macOS (Apple Silicon)
curl -L https://github.com/open-delivery-spec/cli/releases/latest/download/ods_latest_darwin_arm64.tar.gz | tar xz
sudo mv ods /usr/local/bin/

# macOS (Intel)
curl -L https://github.com/open-delivery-spec/cli/releases/latest/download/ods_latest_darwin_amd64.tar.gz | tar xz
sudo mv ods /usr/local/bin/

# Linux (amd64)
curl -L https://github.com/open-delivery-spec/cli/releases/latest/download/ods_latest_linux_amd64.tar.gz | tar xz
sudo mv ods /usr/local/bin/
```

**From source (Go required):**

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@latest
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
1. **Detects** AI code (`Co-Authored-By` trailers, PR disclosure, branch names, diff heuristics)
2. **Analyzes** code quality (5 rule categories for AI-specific defects)
3. **Scores** technical debt impact (5-dimension weighted model)
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

ODS can ingest SARIF v2.1.0 output from tools like semgrep or CodeQL and include their findings in the policy input's `issues[]` array. This lets a single Rego policy block on both ODS-native findings and external scanner findings:

```bash
# Run semgrep and pass its findings to ods analyze
semgrep --config=auto --sarif > semgrep.sarif
ods analyze --sarif semgrep.sarif --json

# Or in a CI step, before ods check:
- name: Semgrep
  run: semgrep --config=auto --sarif > semgrep.sarif
- name: ODS check
  run: ods analyze --sarif semgrep.sarif && ods score && ods check
```

### Optional: Real test coverage

ODS automatically detects coverage reports in the working directory and uses them instead of estimating from test file line counts. Supported formats:

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

When no coverage file is found, ODS sets `test_coverage = -1` ("not measured") and skips the coverage penalty. Your Rego policies **must guard** coverage rules with `input.test_coverage >= 0` to avoid false positives on projects without coverage tooling.

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

For tools that don't emit `Co-Authored-By` automatically, add it manually or use the ODS supplemental trailer fields:

```text
feat(auth): add OAuth login

AI-assisted: true
AI-tool: GitHub Copilot
AI-review: pending
AI-confidence: high
```

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

See the [`.ods/` Convention](ods-artifacts.md) for the full list of policy input fields.

### 3. Require the check in branch protection

Once `ods check` blocks the changes you care about, make the ODS workflow a required status check so violations can't merge.

---

## Quick Reference

| If you want... | Start with |
|----------------|----------|
| Automated AI quality checks in CI | [Path A](#path-a-ai-quality-gate) |
| AI disclosure and attribution | [Path B](#path-b-ai-disclosure) |
| A hard gate tuned to your policy | [Path C](#path-c-customize-enforcement-policy) |
| The simplest possible setup | Add `open-delivery-spec/validate-action@v1` to your PR workflow |

> [!TIP]
> Not sure where to start? [Path A](#path-a-ai-quality-gate) takes 5 minutes.
