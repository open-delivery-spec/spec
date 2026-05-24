# Examples: AI Change Review

## L2 Enhanced Review Record

```json
{
  "pr_number": 42,
  "review_level": "L2",
  "ai_contribution_percentage": 65,
  "reviewer": "jane-doe",
  "timestamp": "2026-01-15T14:30:00Z",
  "outcome": "approved_with_changes",
  "checklist_results": {
    "correctness": { "passed": true, "issues": 0 },
    "security": { "passed": true, "issues": 0 },
    "ai_specific": { "passed": false, "issues": 1 },
    "quality": { "passed": true, "issues": 0 }
  },
  "issues_found": [
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
    "Corrected staging URLs (config/defaults.json)",
    "Added input validation (auth/validate.go)"
  ]
}
```

## L3 Full Audit Record

```json
{
  "pr_number": 45,
  "review_level": "L3",
  "ai_contribution_percentage": 92,
  "reviewer": "jane-doe",
  "second_reviewer": "john-smith",
  "timestamp": "2026-01-15T16:00:00Z",
  "outcome": "approved",
  "checklist_results": {
    "correctness": { "passed": true, "issues": 0 },
    "security": { "passed": true, "issues": 0 },
    "ai_specific": { "passed": true, "issues": 0 },
    "quality": { "passed": true, "issues": 0 }
  },
  "issues_found": [],
  "human_modifications": [
    "Verified all AI-generated API calls are real",
    "Added integration tests for edge cases"
  ]
}
```

## CLI Usage

```bash
# Generate review template
ods review generate --pr 42

# Validate review record
ods review validate --pr 42 --file review-42.json

# Calculate AI contribution
ods review ai-percentage --pr 42
```
