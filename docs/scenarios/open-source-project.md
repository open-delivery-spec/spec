# Scenario: Open-Source Project

**Use case:** A maintainer of an open-source library wants cleaner PR reviews without adding overhead for casual contributors.

## Profile

- Team: 1-3 maintainers, 5-50 contributors
- Repo: Public on GitHub
- AI tools: Some contributors use Copilot, but it's not tracked
- Regulation: None
- Goal: Make PRs easier to review, not enforce compliance

## Configuration

### `.ods.yaml`

```yaml
profile: oss

policy:
  branch:
    allowed_types:
      - feature
      - bugfix
      - hotfix
      - docs
      - chore

  commit:
    require_scope: false

  pr:
    required_sections:
      - "## Summary"
      - "## Changes"
      - "## Testing"

  ai_disclosure:
    required: false

  severity:
    branch_type: warning
    branch_format: warning
    pr_sections: warning
    commit_type: warning
```

### `.github/workflows/ods-l1.yml`

```yaml
name: ODS L1
on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "false"
```

### `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Summary
<!-- Brief description of what this PR does -->

## Changes
-
-

## Testing
- [ ] Tests pass locally
- [ ] New tests added (if applicable)

## Checklist
- [ ] I have read the contributing guide
- [ ] My changes don't break existing functionality
```

## Why this approach

| Principle | Implementation |
|-----------|----------------|
| **Low barrier** | No AI disclosure, no required scopes, no ticket references |
| **Warnings only** | `strict: "false"` — CI shows issues but never blocks first-time contributors |
| **Minimal template** | Only 3 sections. Contributors fill it in 30 seconds |
| **Upgrade path** | If the project grows, switch `profile` from `oss` to `enterprise` and tighten rules |

## What the maintainer sees

**Before ODS:**

```
Title: fix bug
Branch: patch-1
PR body: (empty)

Maintainer questions:
  - "What bug?"
  - "How was it tested?"
  - "Is this safe to merge?"
```

**After ODS:**

```
Title: fix(parser): handle empty input in JSON parser
Branch: bugfix/empty-json-input
PR body:
  ## Summary
  The JSON parser panics when given an empty string input.

  ## Changes
  - Added nil check before parsing
  - Added test for empty input edge case

  ## Testing
  - [x] Tests pass locally
  - [x] New tests added

Maintainer: Merges immediately.
```

## Badge

```markdown
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](https://github.com/open-delivery-spec/spec)
```

## Next steps after adoption

1. If the project grows to 5+ regular contributors, switch to `profile: enterprise`
2. If contributors start using AI tools, enable `ai_disclosure.required: true` as a warning first
3. Add `ods-commit-message.yml` workflow for commit message validation on push
