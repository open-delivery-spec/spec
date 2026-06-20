---
title: "04 — AI Change Review"
layout: default
nav_order: 5
parent: Modules
---

# 04 — AI Change Review

> **Status:** Experimental — see [spec/04](https://github.com/open-delivery-spec/spec/blob/main/spec/04-ai-change-review.md) for the full specification.

Review protocol for AI-generated code changes, using qualitative assistance levels rather than unreliable contribution percentages.

## AI Assistance Levels

| Level | Meaning | Typical scenario |
|-------|---------|------------------|
| `none` | No AI involvement | Traditional human-authored PR |
| `assisted` | AI suggested snippets, human drove the change | Copilot completions |
| `generated` | AI generated substantial portions, human reviewed | Claude/Cursor wrote functions |
| `agentic` | AI agent drove the change autonomously | AI agent opened PR end-to-end |

## Review Levels

| Review Level | When Required | Description |
|-------------|--------------|-------------|
| **L1 — Standard Review** | `none` or `assisted` | Normal human code review |
| **L2 — Enhanced Review** | `generated` | Additional AI-specific checklist required |
| **L3 — Full Audit** | `agentic` | Mandatory second reviewer, full audit trail |

## Why Not AI Percentage?

`AI% = AI-attributed lines / Total changed lines × 100` is unreliable:
- AI writes code, humans edit it — attribution is fuzzy
- Line count ≠ risk (one security-sensitive line matters more than 100 docs lines)
- Most AI tools don’t provide reliable line-level attribution

ODS uses qualitative assistance levels and scope instead. See [spec/04](https://github.com/open-delivery-spec/spec/blob/main/spec/04-ai-change-review.md) for full details.

## L2 Checklist

- ✅ Correctness: compiles, edge cases, error handling
- ✅ Security: no secrets, input validation
- ✅ AI-Specific: no hallucinated APIs, no regressions
- ✅ Quality: conventions, naming, performance

## L3 Additional

- Architecture fit, circular deps
- Test coverage and quality
- License and compliance
- Independent reviewer required

## CLI Usage

```bash
# Detect AI code in the current change
ods detect

# Analyze AI code quality (quality issues, defect density)
ods analyze
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/04-ai-change-review.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/ai-change-review.json)
