# Get Started

Start with the smallest production-ready loop: **ODS L1 + AI Disclosure**. This takes ~5 minutes and runs in CI.

> [!TIP]
> Want to see what an ODS-compliant PR looks like? Copy the [PR Template](../examples/ods-pr-template.md) into `.github/PULL_REQUEST_TEMPLATE.md`.

---

## Path A: Structured Delivery _(ODS L1)_

**For**: Individual maintainers, open source projects, any team that wants cleaner delivery metadata.

**Goal**: Make branches, commits, and PRs machine-readable.

### 1. Install the CLI

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@main
```

### 2. Add to your CI

```yaml
name: ODS L1
on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "true"
```

### 3. Add commit-message validation where the message is available

```yaml
name: ODS Commit Message
on: [push]

jobs:
  validate-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: commit-message
          commit_message: ${{ github.event.head_commit.message }}
          strict: "true"
```

### 4. Check your first change

```bash
ods validate branch feature/add-oauth
ods validate commit --stdin <<< "feat(auth): add OAuth login"
```

**You're L1 compliant** when these checks pass on every PR.

---

## Path B: AI Disclosure

**For**: Teams using GitHub Copilot, Cursor, or other AI coding tools.

**Goal**: Record AI involvement in the L1 artifacts before adopting draft review workflows.

### 1. Complete Path A first

AI disclosure builds on L1 checks.

### 2. Add AI disclosure to commit messages

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

**You're AI-disclosure ready** when every AI-assisted change says what AI touched and what a human reviewed.

---

## Path C: Experimental Evidence Modules

**For**: Release managers, compliance teams exploring the direction (not production-ready).

**Goal**: Explore the draft release-governance schemas before enforcing them.

> See [`.ods/` Convention](ods-artifacts) for the artifact directory layout and naming conventions.

### 1. Complete Paths A and B first

### 2. Validate draft evidence files directly

```bash
ods validate release --file .ods/releases/v1.4.0/release-readiness.json
ods validate rollback --file .ods/releases/v1.4.0/rollback-plan.json
ods validate evidence --file .ods/releases/v1.4.0/evidence-bundle.json
```

These modules are not yet recommended as production Action gates.

---

## Quick Reference

| If you want... | Start with |
|----------------|-----------|
| Clean branch/commit/PR conventions | [Path A](#path-a-structured-delivery-ods-l1) |
| AI disclosure and review | [Path B](#path-b-ai-disclosure) |
| Release audit trails | [Path C](#path-c-draft-evidence-modules) |
| The simplest possible check | `ods validate branch feature/my-feature` |

> [!TIP]
> Not sure where to start? [Path A](#path-a-structured-delivery-ods-l1) takes 5 minutes.
