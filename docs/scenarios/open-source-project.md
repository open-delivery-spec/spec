---
title: Scenario: Open-Source Project
nav_order: 11
---

# Scenario: Open-Source Project

**Use case:** A maintainer of an open-source library wants visibility into AI-generated contributions without adding friction for casual contributors.

## Profile

- Team: 1-3 maintainers, 5-50 contributors
- Repo: Public on GitHub
- AI tools: Some contributors use Copilot or Cursor, but it's untracked
- Regulation: None
- Goal: See which PRs contain AI code and surface quality issues — without blocking newcomers

## Configuration

### `.github/workflows/ods.yml`

Observe-only — the gate reports but never blocks:

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
```

With no `.ods/policy.rego`, the gate runs `detect → analyze → score` and posts a report, but only critical issues would ever block — so first-time contributors are never turned away by a red check.

### Optional: a gentle policy

If the project grows, add a minimal `.ods/policy.rego` that blocks only the truly dangerous:

```rego
package ods.policy

default allow := true

# Only block critical issues; everything else is informational
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}
```

## Why this approach

| Principle | Implementation |
|-----------|----------------|
| **Low barrier** | No required disclosure, no blocking on style or debt |
| **Visibility first** | The report shows AI involvement and quality findings as information |
| **Newcomer-friendly** | Without a policy, only critical issues block — casual PRs sail through |
| **Upgrade path** | Add `.ods/policy.rego` and require the check when the project is ready |

## What the maintainer sees

**Before ODS:**

```
Title: fix bug
PR body: (empty)

Maintainer: "What bug? Is any of this AI-generated? Is it tested?"
```

**After ODS:**

```
## ODS Compliance Report — PASS

AI detected: yes (confidence 0.79, source: diff heuristics)
Technical-debt delta: +0.4
Issues: 0 critical, 1 low (ai-over-commenting)

Policy: PASS (observe-only)
```

The maintainer immediately knows the change is AI-assisted, sees it's low-risk, and reviews the one flagged spot.

## Next steps after adoption

1. If contributions grow, add the minimal `.ods/policy.rego` above and require the check in branch protection
2. Add an ODS badge to the README to set contributor expectations:

   ```markdown
   [![ODS](https://img.shields.io/badge/ODS-AI%20Quality%20Gate-blue)](https://github.com/open-delivery-spec/spec)
   ```
3. See [ODS Levels](../levels.md) to plan the move from observe-only (L1) to enforcement (L3)
