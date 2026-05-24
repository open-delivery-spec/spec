# 04 — AI Change Review

**Version:** 1.0.0-draft  
**Status:** Draft  
**Schema:** [`schemas/ai-change-review.json`](../schemas/ai-change-review.json)

## Overview

Reviewing AI-generated code is fundamentally different from reviewing human code. You're not just checking for bugs — you're verifying that the AI understood the intent, didn't hallucinate, and didn't introduce subtle security issues. ODS defines a structured review protocol and machine-parseable review record.

## Specification

### Review Levels

| Level | When Required | Description |
|-------|--------------|-------------|
| **L1 — Quick Scan** | AI-assisted < 20% of diff | Same as normal human review |
| **L2 — Enhanced Review** | AI-assisted 20-80% of diff | Additional checklist required |
| **L3 — Full Audit** | AI-assisted > 80% of diff | Mandatory second reviewer, full audit trail |

### L2 — Enhanced Review Checklist

When AI generates 20-80% of the PR diff, the reviewer MUST verify:

```markdown
## AI Code Review Checklist (L2)

### Correctness
- [ ] Code compiles and passes all tests
- [ ] Edge cases are handled (null, empty, extreme values)
- [ ] Error handling is appropriate (not just try-catch-pass)

### Security
- [ ] No hardcoded secrets, tokens, or API keys
- [ ] Input validation exists for all external inputs
- [ ] SQL/NoSQL injection vectors are addressed
- [ ] Authentication/authorization logic is correct

### AI-Specific
- [ ] No hallucinated APIs, libraries, or functions
- [ ] No hallucinated configuration values or URLs
- [ ] Deprecated methods or APIs are not used
- [ ] AI didn't remove existing functionality ("regression by deletion")

### Quality
- [ ] Code follows project conventions and style
- [ ] Naming is clear and consistent
- [ ] Comments explain WHY, not WHAT
- [ ] No obvious performance issues (N+1 queries, O(n²) loops)

### Scope
- [ ] AI only changed what was requested (no scope creep)
- [ ] No unrelated files were modified
```

### L3 — Full Audit Checklist

When AI generates > 80% of the PR diff, ALL L2 items PLUS:

```markdown
## AI Code Review Checklist (L3 Additional)

### Architecture
- [ ] Design fits existing architecture patterns
- [ ] No circular dependencies introduced
- [ ] Appropriate abstraction level (not over/under-engineered)

### Testing
- [ ] Test coverage meets project threshold
- [ ] Tests actually test business logic (not just mocks)
- [ ] AI didn't generate circular tests or tautological assertions

### Documentation
- [ ] API docs or inline docs are accurate (not hallucinated)
- [ ] README or runbook updates are correct

### Compliance
- [ ] License compatibility verified for AI-suggested dependencies
- [ ] Data handling complies with privacy/regulatory requirements
- [ ] Audit log entries are generated where required

### Second Review
- [ ] Independent reviewer has approved
- [ ] Reviewer understands the change (not rubber-stamping)
```

### Review Record (JSON)

Every AI change review produces a machine-parseable record:

```json
{
  "pr_number": 42,
  "review_level": "L3",
  "ai_contribution_percentage": 85,
  "reviewer": "jane-doe",
  "second_reviewer": "john-smith",
  "timestamp": "2026-01-15T14:30:00Z",
  "outcome": "approved_with_changes",
  "checklist_results": {
    "correctness": { "passed": true, "issues": 1 },
    "security": { "passed": true, "issues": 0 },
    "ai_specific": { "passed": false, "issues": 2 },
    "quality": { "passed": true, "issues": 1 }
  },
  "issues_found": [
    {
      "category": "ai_specific",
      "severity": "high",
      "file": "src/auth/token.go",
      "line": 42,
      "description": "Hallucinated function call: refreshTokenV2() does not exist",
      "resolution": "Human reimplemented token refresh"
    },
    {
      "category": "ai_specific",
      "severity": "medium",
      "file": "src/config/defaults.json",
      "line": 15,
      "description": "Hallucinated default URL: https://api.staging.fake",
      "resolution": "Corrected to actual staging URL"
    }
  ],
  "human_modifications": [
    "Reimplemented token refresh logic (auth/token.go)",
    "Corrected staging URLs (config/defaults.json)",
    "Added input validation (auth/validate.go)"
  ]
}
```

### AI Contribution Detection

To determine the review level, ODS tools calculate AI contribution percentage from:

1. `AI-assisted: true` footers in commit messages
2. `AI Scope` declarations in PR descriptions
3. Diff analysis: lines attributed to AI vs human
4. Git blame metadata (when available)

```
AI% = AI-attributed changed lines / Total changed lines × 100
```

## JSON Schema

The [ai-change-review.json schema](../schemas/ai-change-review.json) defines:
- Review record structure
- Required fields per level
- Issue format
- Outcome values: `approved`, `approved_with_changes`, `changes_requested`, `blocked`

## Tooling

### CLI
```bash
# Generate review record from PR
ods review generate --pr 42

# Validate a review record
ods review validate --file review-42.json

# Calculate AI contribution
ods review ai-percentage --pr 42
```

## Relationship to Other Specs

- [03 — PR Description](03-pr-description.md): PR body provides AI disclosure needed for review level
- [02 — Commit Message](02-commit-message.md): `AI-review` status updated after review
- [06 — Release Readiness](06-release-readiness.md): AI review records are required evidence
