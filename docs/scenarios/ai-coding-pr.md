# Scenario: AI-Heavy Coding Team

**Use case:** A startup team of 4 engineers uses AI coding tools (Cursor, Copilot, Claude) for 60-80% of their code. They ship fast but are losing track of what AI wrote and who reviewed it. They want to keep the speed but add guardrails.

## Profile

- Team: 4 engineers
- Repo: Private on GitHub
- AI tools: Cursor (primary), GitHub Copilot (secondary), Claude (architecture discussions)
- AI usage: 60-80% of code is AI-generated or AI-assisted
- Goal: Track AI involvement per PR, ensure human review of AI code, keep CI fast

## The problem they faced

> "We shipped a new payment integration in 2 days. It passed CI, passed tests, went to production. Two weeks later we found a race condition in the token refresh logic — AI had hallucinated a non-existent API method. No one had reviewed that specific function because the PR was 800 lines and looked fine at a glance."

**Root cause:** No structured way to know *where* AI contributed, so reviewers couldn't apply targeted scrutiny.

## Configuration

### `.ods.yaml`

```yaml
profile: enterprise

policy:
  branch:
    allowed_types:
      - feature
      - bugfix
      - hotfix
      - chore
      - exp

  commit:
    require_scope: true

  pr:
    required_sections:
      - "## Summary"
      - "## Type"
      - "## AI Disclosure"
      - "## Changes"
      - "## Testing"
      - "## Checklist"

  ai_disclosure:
    required: true
    strict_tool_name: true
    require_human_review: true
    ai_branch_naming: warning

  severity:
    branch_type: error
    branch_format: error
    pr_sections: error
    pr_ai_disclosure: error
    pr_ai_tool: error
    commit_type: error
    commit_scope: warning
    commit_ai: error
```

### Agent instructions

Add to `.cursorrules`, `.claude.md`, or `.github/copilot-instructions.md`:

```markdown
## ODS Compliance

When creating branches, commits, or PR descriptions, follow Open Delivery Spec L1:

### Branch naming
- Use `<type>/<description>` format
- Types: feature, bugfix, hotfix, chore, exp
- Example: `feature/add-oauth-login`

### Commit messages
- Use Conventional Commits: `<type>(<scope>): <description>`
- If this commit contains AI-generated code, add trailers:
  ```
  AI-assisted: true
  AI-tool: Cursor
  AI-scope: <what the AI generated>
  AI-review: pending
  ```

### PR descriptions
- Always include these sections:
  - ## Summary
  - ## Type
  - ## AI Disclosure (REQUIRED if any AI tool was used)
  - ## Changes
  - ## Testing
  - ## Checklist
- Be specific in AI Disclosure about what was AI-generated and what you personally verified
```

### `.github/workflows/ods-l1.yml`

```yaml
name: ODS L1
on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  issues: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "true"
```

## Before / After

### Before ODS — a typical AI-assisted PR

```
Title: add payment integration
Branch: payment-integration
Commit: add payment stuff

PR body:
  Added the new payment provider integration.
  Works on my machine.

Reviewer (looking at 800-line diff):
  - "Which parts are generated vs hand-written?"
  - "Did you verify the token refresh logic?"
  - "Have you tested the webhook handler?"
```

**Result:** Reviewer skims the diff, approves. Race condition ships to production.

### After ODS — same change, structured

```
Title: feat(payments): add Stripe payment provider integration

Branch: feature/stripe-payment-provider

Commit:
  feat(payments): add Stripe provider with webhook handling

  AI-assisted: true
  AI-tool: Cursor
  AI-scope: Stripe API client, webhook signature verification, token refresh
  AI-review: pending

PR body:
  ## Summary
  Adds Stripe as a new payment provider. Integrates checkout sessions,
  webhook handling, and automatic token refresh.

  ## AI Disclosure
  - [x] This PR contains AI-generated code
  - AI Tool: Cursor (primary), GitHub Copilot (test generation)
  - AI Scope:
    - Stripe API client class (generate)
    - Webhook signature verification (generate)
    - Token refresh logic (generate)
    - Test cases for webhook handler (Copilot)
  - Human Review:
    - Verified Stripe API documentation for all endpoint signatures
    - Validated webhook signature against Stripe's recommended approach
    - Manually tested webhook with Stripe CLI
    - Reviewed token refresh for race conditions
    - Rewrote error handling for API timeouts

  ## Changes
  - Added Stripe API client with automatic retry and timeout
  - Added webhook endpoint with signature verification
  - Added token refresh on 401 responses
  - Added unit tests for all new modules
  - Added integration tests with Stripe test mode

  ## Testing
  - [x] Unit tests pass (coverage: 94%)
  - [x] Integration tests pass with Stripe test keys
  - [x] Manual testing with Stripe CLI webhook forwarding
  - [x] Tested token expiry and refresh cycle
  - [x] Tested network timeout and retry behavior

  ## Checklist
  - [x] Branch naming follows ODS
  - [x] Commits include AI attribution
  - [x] All AI-generated code has been reviewed by a human
  - [x] No secrets or credentials in code
  - [x] Stripe test keys only (no production keys)

Reviewer:
  - Immediately sees what AI generated → focuses scrutiny there
  - Reads human review notes → trusts that Stripe docs were checked
  - Sees testing details → confident about edge cases
  - Approves with 0 clarification questions
```

**Result:** Reviewer spends time on the AI-generated token refresh logic, catches the hallucinated API method before merge. The PR takes 15 minutes to review instead of 5 — but the bug doesn't reach production.

## What changes for the team

### Daily workflow

1. **Engineer starts a feature** → creates branch `feature/stripe-integration`
2. **AI generates most of the code** → engineer reviews AI output, adjusts, commits with AI trailers
3. **Engineer opens PR** → PR template prefills. Engineer fills AI Disclosure with specifics
4. **CI runs ODS L1** → validates branch name, PR sections, AI disclosure completeness
5. **ODS bot comments** → compliance report with pass/fail for each check
6. **Reviewer reads AI Disclosure first** → focuses on AI-generated areas
7. **PR merges** → AI disclosure is permanently recorded in the PR

### Reviewer behavior change

| Before | After |
|--------|-------|
| Read entire diff top to bottom | Read AI Disclosure first, then review AI-generated code more carefully |
| Trust that engineer tested everything | See specific testing claims, ask follow-ups on gaps |
| Assume all code is hand-written | Know exactly what AI contributed |

### Metrics to track

- **Review time per PR** — may increase initially (more thorough), stabilizes as reviewers learn to focus
- **Bugs found in review vs. production** — should shift toward review
- **AI disclosure completeness** — % of AI-assisted PRs with complete AI Disclosure sections
- **Reviewer questions per PR** — should decrease as PRs contain more context

## Badge

```markdown
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](https://github.com/open-delivery-spec/spec)
```

## Lessons learned

1. **AI Disclosure is the highest-value section.** It changes reviewer behavior immediately.
2. **Agent instructions matter.** Adding ODS conventions to `.cursorrules` means the AI generates compliant branches and commit messages by default.
3. **Don't skip commit trailers.** `AI-assisted: true` in commits means even squashed PRs carry AI attribution into the main branch.
4. **Start with strict.** AI-heavy teams benefit from enforcement from day 1. The team already has the discipline to use AI tools; adding structured metadata is a smaller lift than for teams new to both.

## Next steps after adoption

1. When the team grows, add `.ods.yaml` to the shared engineering standards repo
2. Explore [Module 04 (AI Change Review)](../spec/04-ai-change-review.md) for structured review records of AI-generated code
3. If shipping to regulated customers, explore [Module 09 (Production Evidence)](../spec/09-prod-release-evidence.md) for deployment audit trails
