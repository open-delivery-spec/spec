# 04 — AI Change Review

**Version:** 1.0.0-draft
**Status:** Experimental
**Schema:** [`schemas/ai-change-review.json`](../schemas/ai-change-review.json)

> [!WARNING]
> This module is **experimental**. The schema and review protocol are direction-setting. The recommended adoption path today is ODS L1 + AI Disclosure (modules 01-03). See [ROADMAP.md](../ROADMAP.md).

## Overview

Reviewing AI-generated code is fundamentally different from reviewing human code. You're not just checking for bugs — you're verifying that the AI understood the intent, didn't hallucinate, and didn't introduce subtle security issues. ODS defines a structured review protocol and machine-parseable review record.

## Specification

### AI Assistance Levels (Qualitative)

Instead of computing an unreliable AI contribution percentage, ODS uses qualitative assistance levels:

| Level | Meaning | Typical scenario |
|-------|---------|-----------------|
| `none` | No AI involvement | Traditional human-authored PR |
| `assisted` | AI suggested snippets, human drove the change | Copilot completions, inline suggestions |
| `generated` | AI generated substantial portions, human reviewed and edited | Claude/Cursor wrote functions or modules |
| `agentic` | AI agent drove the change autonomously, human reviewed | AI agent opened PR end-to-end |

### Review Levels

The review level is determined by the assistance level, not by a computed percentage:

| Review Level | When Required | AI Assistance Level | Description |
|-------------|--------------|-------------------|-------------|
| **L1 — Standard Review** | `none` or `assisted` | Human led the change | Same as normal human code review |
| **L2 — Enhanced Review** | `generated` | AI generated substantial portions | Additional AI-specific checklist required |
| **L3 — Full Audit** | `agentic` | AI drove the change autonomously | Mandatory second reviewer, full audit trail |

### AI Scope

The `ai_scope` field tells reviewers *where* to focus:

| Scope | Description |
|-------|-------------|
| `docs` | Documentation, README, comments |
| `tests` | Test code only |
| `implementation` | Application/business logic |
| `refactor` | Restructuring without behavior change |
| `security-sensitive` | Auth, crypto, permissions, data handling |
| `release` | CI/CD, deployment, infrastructure config |

### Risk Level

```json
{
  "risk_level": "low"  // low | medium | high
}
```

Factors: AI assistance level, scope sensitivity, change size, module criticality.

### Review Record (JSON)

```json
{
  "pr_number": 42,
  "ai_assistance_level": "generated",
  "ai_scope": "implementation",
  "risk_level": "medium",
  "review_level": "L2",
  "reviewer": "jane-doe",
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
    }
  ],
  "human_modifications": [
    "Reimplemented token refresh logic (auth/token.go)",
    "Added input validation (auth/validate.go)"
  ]
}
```

### L2 — Enhanced Review Checklist

When AI assistance level is `generated` or higher, the reviewer uses this checklist:

```markdown
## AI Code Review Checklist (L2)

### Correctness
- [ ] Code compiles and passes all tests
- [ ] Edge cases are handled (null, empty, extreme values)
- [ ] Error handling is appropriate

### Security
- [ ] No hardcoded secrets, tokens, or API keys
- [ ] Input validation exists for all external inputs
- [ ] Authentication/authorization logic is correct

### AI-Specific
- [ ] No hallucinated APIs, libraries, or functions
- [ ] No hallucinated configuration values or URLs
- [ ] Deprecated methods or APIs are not used
- [ ] AI didn't remove existing functionality ("regression by deletion")

### Quality
- [ ] Code follows project conventions
- [ ] Naming is clear and consistent
- [ ] No obvious performance issues

### Scope
- [ ] AI only changed what was requested (no scope creep)
- [ ] No unrelated files modified
```

### L3 — Full Audit Checklist

When AI assistance level is `agentic`, ALL L2 items PLUS:

```markdown
## AI Code Review Checklist (L3 Additional)

### Architecture
- [ ] Design fits existing architecture patterns
- [ ] No circular dependencies
- [ ] Appropriate abstraction level

### Testing
- [ ] Test coverage meets project threshold
- [ ] Tests test business logic (not just mocks)
- [ ] AI didn't generate circular tests or tautological assertions

### Compliance
- [ ] License compatibility verified for AI-suggested dependencies
- [ ] Data handling complies with privacy/regulatory requirements

### Second Review
- [ ] Independent reviewer has approved
- [ ] Reviewer understands the change (not rubber-stamping)
```

## Why Not AI Percentage?

AI contribution percentage (`AI% = AI-attributed lines / Total lines × 100`) is tempting but unreliable:

1. AI writes code, humans edit it — attribution is fuzzy
2. Human-written code may be AI-refactored
3. AI suggestions may be manually typed
4. Line count ≠ risk (one security-sensitive line matters more than 100 docs lines)
5. Most AI tools don't provide reliable line-level attribution

ODS uses **qualitative assistance levels** (`none | assisted | generated | agentic`) and **scope** (`docs | tests | implementation | refactor | security-sensitive | release`) instead. The `ai_contribution_percentage` field remains in the schema as an **optional signal**, not a compliance requirement.

## JSON Schema

The [ai-change-review.json schema](../schemas/ai-change-review.json) defines the review record structure. Key fields:

- `ai_assistance_level`: `none` | `assisted` | `generated` | `agentic`
- `ai_scope`: `docs` | `tests` | `implementation` | `refactor` | `security-sensitive` | `release`
- `risk_level`: `low` | `medium` | `high`
- `review_level`: `L1` | `L2` | `L3`
- `outcome`: `approved` | `approved_with_changes` | `changes_requested` | `blocked`

## Relationship to Other Specs

- [03 — PR Description](03-pr-description.md): AI disclosure in PR body informs the review level
- [02 — Commit Message](02-commit-message.md): `AI-review` status updated after review
- [06 — Release Readiness](06-release-readiness.md): AI review records are required release evidence (experimental)
