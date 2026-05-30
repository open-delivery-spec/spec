# Scenario: Enterprise Internal Service

**Use case:** A platform team owns 3 internal services. They want consistent delivery metadata across all repos, AI disclosure for Copilot-heavy development, and audit-ready PR records.

## Profile

- Team: 8 engineers, 3 services
- Repo: Private on GitHub Enterprise
- AI tools: Entire team uses GitHub Copilot (organization-wide)
- Regulation: Internal audit requires evidence of human review for all production changes
- Goal: Full ODS L1 + AI Disclosure enforced before merge, with compliance reports archived

## Configuration

### `.ods.yaml`

```yaml
profile: enterprise

policy:
  branch:
    allowed_types:
      - feature
      - bugfix
      - hotfix
      - release
      - chore
    require_ticket: true
    max_description_length: 80

  commit:
    require_scope: true
    max_subject_length: 72

  pr:
    required_sections:
      - "## Summary"
      - "## Type"
      - "## AI Disclosure"
      - "## Changes"
      - "## Testing"
      - "## Risk Assessment"
      - "## Checklist"
    min_changes: 1

  ai_disclosure:
    required: true
    strict_tool_name: true
    require_human_review: true
    ai_branch_naming: warning

  severity:
    branch_type: error
    branch_format: error
    pr_sections: error
    pr_ai_disclosure: error
    pr_ai_tool: error
    commit_type: error
    commit_scope: error
    commit_ai: error
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
  issues: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "true"
          artifact-retention-days: "90"
```

### `.github/workflows/ods-commit-message.yml`

```yaml
name: ODS Commit Message
on: [push]

jobs:
  ods-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: commit-message
          commit_message: ${{ github.event.head_commit.message }}
          strict: "true"
```

### `.github/PULL_REQUEST_TEMPLATE.md`

Full template from [ods-pr-template.md](../examples/ods-pr-template.md).

### Branch protection rules

- Require `ODS L1` status check to pass before merge
- Require at least 1 approving review
- Require conversation resolution

## Rollout plan

### Week 1-2: Template + Observe

- Add PR template and workflows
- `strict: "false"` — CI reports but doesn't block
- Share the [adoption guide](../adoption-guide.md) in team Slack

### Week 3-4: Warn

- Team demo: show the ODS PR comment, job summary, and artifact
- Review common failures from the first two weeks. Adjust `.ods.yaml` if needed
- `strict: "true"` on `ods-l1.yml` for branch and PR checks only

### Week 5+: Enforce

- `strict: "true"` on both workflows
- Enable branch protection requiring ODS check
- Archive compliance reports for audit (90-day retention)

## What the team sees

### Passing PR

The ODS bot posts a comment:

```
## ODS Compliance Report

Status: ✅ ODS L1 Compliant
Score: 100 / 100
Profile: L1 - AI-aware delivery metadata

Repository: acme-corp/user-service
Ref: feature/PROJ-423-oauth-migration
Commit: a1b2c3d4e5f6
Pull request: #423

| Check | Result | Notes |
|---|---|---|
| Branch naming | ✅ Pass | feature/PROJ-423-oauth-migration |
| Commit message | ✅ Pass | feat(auth): migrate OAuth to PKCE flow |
| PR description | ✅ Pass | - |
```

### Failing PR

```
## ODS Compliance Report

Status: ❌ ODS L1 Non-Compliant
Score: 33 / 100

| Check | Result | Notes |
|---|---|---|
| Branch naming | ✅ Pass | bugfix/fix-token-expiry |
| Commit message | ❌ Fail | fix stuff; missing scope |
| PR description | ❌ Fail | missing section: AI Disclosure; missing section: Risk Assessment |
```

## Audit trail

For each release, the compliance team downloads:

1. **Workflow artifact** — `ods-compliance-report.zip` containing HTML, JSON, SVG, Markdown
2. **PR comment** — permanent record of the ODS report at merge time
3. **AI disclosure records** — structured evidence of what AI generated and who reviewed it

These satisfy internal audit requirements:
- Traceability: which engineer reviewed which AI-generated change
- Human oversight: documented per PR
- Delivery governance: consistent metadata across all repos

## Badge

```markdown
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](https://open-delivery-spec.dev)
```

## Multi-repo adoption

For the platform team's 3 services, copy the same three files to each repo:

```bash
# In each service repo:
ods init github
# Then customize .ods.yaml if any service has specific conventions
```

Use a shared `.ods.yaml` template in your team's engineering standards repo and reference it from each service.

## Next steps after adoption

1. Integrate ODS report artifacts into your release checklist pipeline
2. Map ODS AI Disclosure fields to your internal audit control framework
3. When ready, explore [Module 06 (Release Readiness)](../spec/06-release-readiness.md) and [Module 09 (Production Evidence)](../spec/09-prod-release-evidence.md) for release-governance gates
