---
title: Scenario: Enterprise Service
nav_order: 12
---

# Scenario: Enterprise Internal Service

**Use case:** A platform team owns 3 internal services. Their whole org uses GitHub Copilot, and internal audit requires evidence that AI-generated changes were quality-checked and human-reviewed before reaching production.

## Profile

- Team: 8 engineers, 3 services
- Repo: Private on GitHub Enterprise
- AI tools: Organization-wide GitHub Copilot
- Regulation: Internal audit requires evidence of quality control for all production changes
- Goal: Enforce the ODS AI quality gate before merge, with reports archived for audit

## Configuration

### `.github/workflows/ods.yml`

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
          fetch-depth: 0
      - uses: open-delivery-spec/validate-action@v1
        with:
          comment: "true"
          artifact-retention-days: "90"
```

### `.ods/policy.rego`

Enterprise policy — block critical issues, untested AI code, and large debt increases:

```rego
package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage < 0.4
    msg := "AI code below the 40% coverage bar"
}

deny[msg] {
    input.technical_debt_delta > 5.0
    some issue in input.issues
    issue.severity == "high"
    msg := sprintf("Technical-debt delta %.1f with high-severity issues", [input.technical_debt_delta * 1.0])
}
```

### Branch protection

- Require the `ODS AI Quality Gate` status check before merge
- Require at least 1 approving review
- Require conversation resolution

## Rollout plan

### Week 1-2: Observe

- Add the workflow with no `.ods/policy.rego` (permissive default — only critical issues block)
- Share the [adoption guide](../adoption-guide.md) in team Slack
- Review the ODS report on each PR; note common findings

### Week 3-4: Tune

- Add `.ods/policy.rego` with `warn` rules first
- Team demo: walk through the PR comment, job summary, and downloadable artifact
- Adjust thresholds to the services' real coverage and debt levels

### Week 5+: Enforce

- Promote the key `warn` rules to `deny`
- Enable branch protection requiring the ODS check
- Archive compliance artifacts for audit (90-day retention)

## What the team sees

### Passing PR

```
## ODS Compliance Report — PASS

AI detected: yes (Copilot, confidence 0.84)
Technical-debt delta: +1.1
Issues: 0 critical, 1 medium

Repository: acme-corp/user-service
Ref: feature/PROJ-423-oauth-migration

Policy: PASS
```

### Blocked PR

```
## ODS Compliance Report — BLOCK

AI detected: yes (confidence 0.88)
Test coverage: 0.22

Policy: BLOCK — AI code below the 40% coverage bar
```

## Audit trail

For each release window, the compliance team archives:

1. **Workflow artifact** — the ODS report (HTML, JSON, SVG, Markdown), retained 90 days
2. **PR comment** — a permanent record of the gate result at merge time
3. **Policy file** — `.ods/policy.rego` in version control documents the enforced quality bar

These satisfy internal audit requirements: every AI-assisted change has a recorded quality assessment, a documented enforcement policy, and a human approval on the PR.

## Multi-repo adoption

For all 3 services, scaffold the same setup:

```bash
# In each service repo:
ods init
# Then commit a shared .ods/policy.rego from your engineering-standards repo
```

Keep a canonical `.ods/policy.rego` in a shared standards repo and copy it into each service so the quality bar stays consistent.

## Next steps after adoption

1. Map the ODS report fields to your internal audit control framework
2. Track technical-debt delta trends across releases as a quality KPI
3. See [ODS Levels](../levels.md) for the L1 → L3 enforcement progression
