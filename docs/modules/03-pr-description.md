---
title: "03 — PR Description"
layout: default
nav_order: 4
parent: Modules
---

# 03 — PR Description

Structured PR body template with mandatory AI disclosure, risk assessment, and verification checklist.

## Required Sections

1. **Summary** — One sentence describing the PR
2. **Type** — Feature, Bugfix, Hotfix, Refactor, Documentation, Chore
3. **AI Disclosure** — Must declare AI involvement
4. **Changes** — List of changes
5. **Testing** — Test evidence
6. **Risk Assessment** — Deployment risk and rollback
7. **Checklist** — ODS compliance verification

## AI Disclosure

When AI contributed to the PR:

```markdown
## AI Disclosure
- [x] This PR contains AI-generated code
- **AI Tool:** GitHub Copilot + Claude
- **AI Scope:** Provider configuration, token exchange
- **Human Review:** Verified OAuth spec compliance, added PKCE
```

## CLI Usage

```bash
# Validate
ods validate pr --file PR_BODY.md

# Generate template
ods generate pr --ai-tool "GitHub Copilot"
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/03-pr-description.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/pr-description.json)
