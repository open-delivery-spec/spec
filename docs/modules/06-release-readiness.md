---
title: "06 — Release Readiness"
layout: default
nav_order: 7
parent: Modules
---

# 06 — Release Readiness

Evidence-based release gate system with scoring and AI-specific checks.

## Gates

| Gate | Required | Description |
|------|----------|-------------|
| `ci` | Yes | All CI pipeline stages passed |
| `tests` | Yes | Coverage ≥ threshold |
| `security_scan` | Yes | No critical/high vulns |
| `ai_review` | If AI > 20% | All AI PRs reviewed |
| `approvals` | Yes | Required approvals obtained |
| `rollback_plan` | Yes | Exists and tested |
| `breaking_changes` | Yes | Migration guide exists |
| `documentation` | No | Changelog, API docs current |

## Scoring

```
Score = Σ(passed_gates × weight) / Σ(weight) × 100
```

Ready when: all required gates pass AND score ≥ 80.

## CLI Usage

```bash
ods release check --version v1.4.0
ods generate release --version v1.4.0 --env production
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/06-release-readiness.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/release-readiness.json)
