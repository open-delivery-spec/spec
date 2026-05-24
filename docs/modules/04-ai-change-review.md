---
title: "04 — AI Change Review"
layout: default
nav_order: 5
parent: Modules
---

# 04 — AI Change Review

Three-level review protocol for AI-generated code changes.

## Review Levels

| Level | AI % | Review Type | Requirements |
|-------|------|-------------|-------------|
| **L1 — Quick Scan** | < 20% | Standard review | Normal PR review |
| **L2 — Enhanced** | 20-80% | Additional checklist | Verify correctness, security, AI specifics |
| **L3 — Full Audit** | > 80% | Mandatory 2nd reviewer | L2 + architecture, testing, compliance |

## L2 Checklist

- ✅ Correctness: compiles, edge cases, error handling
- ✅ Security: no secrets, input validation
- ✅ AI-Specific: no hallucinated APIs, no regressions
- ✅ Quality: conventions, naming, performance

## L3 Additional

- Architecture fit, circular deps
- Test coverage and quality
- License and compliance

## AI Contribution Detection

```
AI% = AI-attributed lines / Total changed lines × 100
```

## CLI Usage

```bash
# Detect AI percentage
ods review ai-percentage --pr 42

# Generate review record
ods review generate --pr 42
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/04-ai-change-review.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/ai-change-review.json)
