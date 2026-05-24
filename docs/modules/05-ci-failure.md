---
title: "05 — CI Failure"
layout: default
nav_order: 6
parent: Modules
---

# 05 — CI Failure

Machine-parseable CI failure reports with AI hallucination detection.

## Failure Types

| Type | AI Root Cause |
|------|--------------|
| `assertion_error` | AI assumed incorrect state |
| `compilation_error` | AI used non-existent APIs |
| `type_error` | Wrong types/signatures |
| `lint_error` | Project convention violations |
| `security_violation` | AI introduced vulnerability |
| `timeout` | Infinite loop or deadlock |

## AI Failure Explanation

```json
{
  "ai_failure_detail": {
    "ai_contributed": true,
    "failure_category": "hallucinated_api",
    "human_readable": "AI used refreshTokenV2() which does not exist.",
    "evidence": {
      "hallucinated_symbol": "refreshTokenV2",
      "closest_valid_symbol": "refreshToken",
      "levenshtein_distance": 2
    }
  }
}
```

## CLI Usage

```bash
# Parse CI log
ods ci parse --file ci-output.log

# Explain failure
ods ci explain build-12345

# Get fix suggestions
ods ci fix-suggestions build-12345
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/05-ci-failure.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/ci-failure.json)
