# 05 — CI Failure

**Version:** 1.0.0-draft  
**Status:** Draft  
**Schema:** [`schemas/ci-failure.json`](../schemas/ci-failure.json)

## Overview

CI failures happen. But *why*? AI-generated code increases failure frequency, and developers need structured explanations to act quickly. ODS defines a machine-parseable CI failure report that tools can generate and humans can understand.

## Specification

### CI Failure Report

```json
{
  "pipeline_id": "build-12345",
  "repository": "org/backend-service",
  "branch": "feature/ai-add-oauth",
  "commit": "a1b2c3d4",
  "trigger": "push",
  "timestamp": "2026-01-15T14:30:00Z",
  "status": "failed",
  "duration_seconds": 342,
  "stages": {
    "lint": {
      "status": "passed",
      "duration_seconds": 45
    },
    "test": {
      "status": "failed",
      "duration_seconds": 180,
      "failures": [
        {
          "test_name": "TestOAuthFlow",
          "test_file": "auth/oauth_test.go",
          "failure_type": "assertion_error",
          "message": "Expected status 200, got 401",
          "ai_related": true,
          "ai_explanation": "AI-generated test assumed token was valid by default without setting up mock",
          "suggested_fix": "Add token setup to test fixture: setupValidToken()",
          "stack_trace": "auth/oauth_test.go:42 TestOAuthFlow ..."
        }
      ]
    },
    "security_scan": {
      "status": "passed",
      "duration_seconds": 90
    }
  },
  "ai_summary": {
    "ai_contributed_stages": ["test"],
    "likely_ai_caused": true,
    "confidence": "high",
    "explanation": "2/3 failing tests were AI-generated. OAuth test assumed valid token state without setup. Search test used hallucinated API signature."
  },
  "fix_suggestions": [
    {
      "priority": 1,
      "file": "auth/oauth_test.go",
      "action": "Add missing token fixture setup before test assertions",
      "auto_fix_available": false
    },
    {
      "priority": 2,
      "file": "search/query_test.go",
      "action": "Replace hallucinated buildQuery() with actual buildSearchQuery()",
      "auto_fix_available": true
    }
  ]
}
```

### Failure Classification

| Failure Type | Description | Typical AI Root Cause |
|---|---|---|
| `assertion_error` | Test assertion failed | AI assumed incorrect state/behavior |
| `compilation_error` | Code doesn't compile | AI used non-existent APIs or imports |
| `type_error` | Type mismatch | AI used wrong types or signatures |
| `lint_error` | Style/convention violation | AI didn't follow project conventions |
| `security_violation` | Security scan found issue | AI introduced vulnerability or exposed secret |
| `timeout` | Test or build exceeded time limit | AI introduced infinite loop or deadlock |
| `dependency_error` | Missing or incompatible dependency | AI used wrong version or hallucinated package |
| `configuration_error` | Misconfiguration | AI modified config incorrectly |
| `integration_error` | Integration test failure | AI broke service contract |
| `unknown` | Unclassified failure | N/A |

### AI Failure Explanation

When AI contributed to the failing code, the report MUST include:

```json
{
  "ai_failure_detail": {
    "ai_contributed": true,
    "failure_category": "hallucinated_api",
    "human_readable": "The AI used a function refreshTokenV2() that does not exist in this codebase.",
    "evidence": {
      "file": "auth/token.go",
      "line": 42,
      "hallucinated_symbol": "refreshTokenV2",
      "closest_valid_symbol": "refreshToken",
      "levenshtein_distance": 2
    }
  }
}
```

### Hallucination Detection

ODS CI tools should detect common AI hallucinations:

1. **Non-existent functions** — Symbol not found in codebase
2. **Wrong import paths** — Package not available at specified version
3. **Incorrect defaults** — Configuration values that don't match any environment
4. **Fake URLs** — URLs flagged by domain verification
5. **Deprecated APIs** — Using APIs marked deprecated in current dependency version

## JSON Schema

The [ci-failure.json schema](../schemas/ci-failure.json) defines the complete failure report structure with validation for:
- Required fields: `pipeline_id`, `status`, `timestamp`
- Stage status values
- Failure type enum
- AI attribution structure

## Tooling

### CLI
```bash
# Parse a CI failure log
ods ci parse --file ci-output.log --format json

# Explain a failure in human terms
ods ci explain --pipeline build-12345

# Suggest fixes for AI-caused failures
ods ci fix-suggestions --pipeline build-12345
```

### GitHub Action
GitHub Action enforcement for CI failure records is planned. For now, use the CLI while this module is Draft.

## Relationship to Other Specs

- [04 — AI Change Review](04-ai-change-review.md): CI failures inform AI review severity
- [06 — Release Readiness](06-release-readiness.md): CI must pass (or have approved waivers) for release
- [09 — Production Release Evidence](09-prod-release-evidence.md): CI results are part of deployment evidence
