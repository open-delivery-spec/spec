# Examples: CI Failure Report

## AI-caused test failure

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
    "lint": { "status": "passed", "duration_seconds": 45 },
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
          "suggested_fix": "Add token setup to test fixture: setupValidToken()"
        }
      ]
    },
    "security_scan": { "status": "passed", "duration_seconds": 90 }
  },
  "ai_summary": {
    "ai_contributed_stages": ["test"],
    "likely_ai_caused": true,
    "confidence": "high",
    "explanation": "Test failure is AI-generated. Test assumed valid token state without setup."
  },
  "fix_suggestions": [
    {
      "priority": 1,
      "file": "auth/oauth_test.go",
      "action": "Add missing token fixture setup before test assertions",
      "auto_fix_available": false
    }
  ]
}
```

## CLI Usage

```bash
# Parse CI log
ods ci parse --file ci-output.log --pipeline build-12345

# Explain failure
ods ci explain build-12345

# Get fix suggestions
ods ci fix-suggestions build-12345
```
