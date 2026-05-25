# Get Started

Choose your adoption path based on what you need most.

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
# .github/workflows/ods.yml
name: ODS L1
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: open-delivery-spec/validate-action@v1
        with:
          check: branch-naming
          branch_name: ${{ github.head_ref }}

      - uses: open-delivery-spec/validate-action@v1
        with:
          check: pr-description
          pr_body: ${{ github.event.pull_request.body }}
```

### 3. Check your first PR

```bash
ods validate branch feature/add-oauth
ods validate commit --stdin <<< "feat(auth): add OAuth login"
```

**You're L1 compliant** when these checks pass on every PR.

---

## Path B: AI-Aware Delivery _(ODS L2)_

**For**: Teams using GitHub Copilot, Cursor, or other AI coding tools.

**Goal**: Record AI involvement and get structured CI failure reports.

### 1. Complete Path A first

L2 builds on L1 checks.

### 2. Add AI disclosure to commit messages

```text
feat(auth): add OAuth login

AI-assisted: true
AI-tool: GitHub Copilot
AI-review: pending
AI-confidence: high
```

### 3. Enable AI review validation

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    check: ai-review
    pr_number: ${{ github.event.pull_request.number }}
```

**You're L2 compliant** when every AI-generated change is disclosed and reviewed.

---

## Path C: Evidence-Based Delivery _(ODS L3)_

**For**: Release managers, compliance teams, anyone who needs audit trails.

**Goal**: Every release produces verifiable evidence of readiness and rollback capability.

### 1. Complete Paths A and B first

### 2. Generate a release readiness report

```bash
ods release check --version v1.4.0
```

### 3. Add rollback plan validation

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    check: rollback-plan
    rollback_plan: "./.ods/releases/v1.4.0/rollback-plan.json"
```

### 4. Generate production evidence

```bash
ods evidence verify ".ods/releases/v1.4.0/evidence-bundle.json"
```

**You're L3 compliant** when every release has evidence of readiness, rollback, and deployment.

---

## Quick Reference

| If you want... | Start with |
|----------------|-----------|
| Clean branch/commit/PR conventions | [Path A](#path-a-structured-delivery-ods-l1) |
| AI disclosure and review | [Path B](#path-b-ai-aware-delivery-ods-l2) |
| Release audit trails | [Path C](#path-c-evidence-based-delivery-ods-l3) |
| The simplest possible check | `ods validate branch feature/my-feature` |

> [!TIP]
> Not sure where to start? [Path A](#path-a-structured-delivery-ods-l1) takes 5 minutes.
