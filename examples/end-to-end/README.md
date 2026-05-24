# End-to-End Example: Branch → PR → Release Evidence

This example walks through a complete delivery lifecycle using Open Delivery Spec — from branch creation to production release evidence.

## Scenario

A developer (human + AI assistant) adds an OAuth 2.0 login flow to a backend service. AI generates most of the code. ODS ensures every artifact is standardized, verifiable, and auditable.

---

## Step 1 — Branch Naming

**Create the branch:**
```bash
git checkout -b feature/add-oauth-login
```

**Validate it:**
```bash
ods validate branch feature/add-oauth-login
# ✅ conformant — all requirements satisfied
```

**ODS metadata (optional `.ods/releases/v1.4.0/branch-meta.json`):**
```json
{
  "type": "feature",
  "description": "add-oauth-login",
  "ticket": "PROJ-1234",
  "ai_generated": true,
  "ai_tool": "GitHub Copilot",
  "base_branch": "main"
}
```

---

## Step 2 — Commit Message

**Write an AI-attributed commit:**
```
feat(auth): add OAuth 2.0 login flow

Implemented authorization code flow with PKCE.
Supports Google, GitHub, and Microsoft providers.

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module, token exchange, provider configs
AI-review: pending
Ticket: PROJ-1234
```

**Validate it:**
```bash
ods validate commit --file commit-msg.txt
# ✅ conformant — all requirements satisfied
```

---

## Step 3 — PR Description

**Open PR #42** with an ODS-compliant description:

```markdown
## Summary
Add OAuth 2.0 login flow with Google, GitHub, and Microsoft providers.

## Type
- [x] Feature

## AI Disclosure
- [x] This PR contains AI-generated code
- **AI Tool:** GitHub Copilot
- **AI Scope:** Provider abstraction, token exchange, session management
- **Human Review:** Verified OAuth spec compliance, added PKCE, fixed redirect URI validation

## Related Issues
Closes #42

## Changes
- Added OAuth provider abstraction layer
- Implemented Google, GitHub, Microsoft provider configs
- Added PKCE support
- Session management with refresh token rotation

## Testing
- [x] Unit tests added
- [x] Integration tests added
- [x] Manual testing performed
- **Test coverage before:** 72%
- **Test coverage after:** 78%

## Risk Assessment
- **Deployment risk:** Medium
- **Rollback plan:** Feature flag `oauth-v2` controls rollout
- **Breaking change:** No

## Checklist
- [x] Branch naming follows ODS
- [x] Commits follow ODS
- [x] AI-generated code has been reviewed by a human
- [x] No secrets included
- [x] Documentation updated
```

**Validate it:**
```bash
ods validate pr --file PR_BODY.md
# ✅ conformant
```

---

## Step 4 — GitHub Action (Automated Check)

**`.github/workflows/ods.yml`:**
```yaml
name: ODS Checks
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: open-delivery-spec/github-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          pr_number: ${{ github.event.pull_request.number }}
          strict: 'true'
```

**Action output:**
```
✅ branch-naming: conformant
✅ commit-message: conformant
⚠️  pr-description: conformant with warnings
   - AI contribution detected. L2 enhanced review recommended.

Result: conformant-with-warnings
Score: 95
```

---

## Step 5 — AI Change Review

Since AI contributed > 20% of the diff, a **Level 2 Enhanced Review** is triggered.

**Review record (`ai-review.json`):**
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
    "ai_specific": { "passed": true, "issues": 0 },
    "quality": { "passed": true, "issues": 1 },
    "scope": { "passed": true, "issues": 0 }
  },
  "issues_found": [],
  "human_modifications": [
    "Added input validation for redirect URIs",
    "Corrected token refresh timeout from 5min to 15min"
  ]
}
```

---

## Step 6 — Release Readiness

Before deploying v1.4.0, generate the release readiness report.

```bash
ods release readiness --version v1.4.0
```

**Output (`release-readiness.json`):**
```json
{
  "release_id": "v1.4.0",
  "repository": "org/backend-service",
  "target_environment": "production",
  "ready": true,
  "overall_score": 92,
  "gates": {
    "ci": { "status": "passed", "passed": true },
    "tests": { "status": "passed", "passed": true, "coverage_percentage": 78 },
    "security_scan": { "status": "passed", "passed": true, "critical": 0, "high": 0 },
    "ai_review": { "status": "passed", "passed": true, "all_reviewed": true },
    "approvals": { "status": "passed", "passed": true, "obtained": 2 },
    "rollback_plan": { "status": "passed", "passed": true, "tested": true }
  }
}
```

---

## Step 7 — Production Release Evidence

After deployment, bundle all evidence:

```bash
ods evidence generate --release v1.4.0 --env production
# Bundled: .ods/releases/v1.4.0/evidence-bundle.json
# Hash: sha256:abc123...
```

**What the evidence bundle contains:**

```
evidence-bundle.json
├── release_readiness (score: 92, all gates passed)
├── ci_pipeline (build-12345, passed)
├── test_results (342/342 passed, 78% coverage)
├── security_scan (0 critical, 0 high)
├── ai_reviews (8 PRs, all reviewed: 2×L3, 4×L2, 2×L1)
├── approvals (jane-doe [tech-lead], john-smith [security-reviewer])
├── rollback_plan (tested, 5 min estimated)
└── deployment_log (12 instances, health check passed)
```

**Verify the bundle:**
```bash
ods evidence verify --bundle .ods/releases/v1.4.0/evidence-bundle.json
# ✓ Bundle hash verified
# ✓ 7/7 evidence items present
# ✓ 0 discrepancies found
# ✓ Bundle is valid and immutable
```

---

## Summary — What ODS Gave Us

| Before ODS | After ODS |
|-----------|-----------|
| Branch: `oauth-stuff` | `feature/add-oauth-login` (validated) |
| Commit: "added oauth" | Structured with AI attribution |
| PR: Free-form text | Validated template with AI disclosure |
| Review: Gut feeling | L2 checklist with JSON record |
| Release: "Looks good" | Score-based readiness report (92/100) |
| Evidence: Scattered logs | Immutable evidence bundle with hash |

## Try It Yourself

```bash
# 1. Clone the reference implementation
git clone https://github.com/open-delivery-spec/cli

# 2. Build the CLI
cd cli && go build -o ods ./cmd/ods

# 3. Follow this example step by step
./ods validate branch feature/add-oauth-login
./ods validate commit --file /path/to/commit-msg.txt
./ods validate pr --file /path/to/PR_BODY.md
```
