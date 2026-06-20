---
title: Before & After
nav_order: 3
parent: Home
---

# ODS L1 + AI Disclosure: Before & After

ODS does not claim to make code correct. It claims to make delivery metadata structured, machine-readable, and reviewable — so reviewers spend less time asking clarifying questions and more time reviewing the actual change.

## Before ODS

A typical AI-assisted PR without structured metadata:

```
Title: fix stuff

Branch: fix-bug

PR body:
(empty)

Commits:
- fix
- wip
- update
```

**Reviewer experience:**
1. Opens PR. Reads title "fix stuff." No idea what it fixes.
2. Scrolls through diff — 200 lines changed, no context.
3. Asks: "What does this fix? Which part is AI-generated? Was this tested?"
4. Waits for reply. Context-switches to another task.
5. Receives reply. Returns to PR. Finally starts actual code review.

**Time to first meaningful review: hours to days.**
**Clarification questions per PR: 3-5.**

## After ODS L1 + AI Disclosure

The same change, with structured metadata:

```
Title: fix(auth): handle expired OAuth state parameter

Branch: bugfix/expired-oauth-state

PR body:

## Summary
Fixes race condition where OAuth state parameter expires before
the callback arrives. Users saw 400 errors during login with slow
connections.

## Type
- [x] Bugfix

## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Token refresh logic, state validation
- Human Review: Verified OAuth spec compliance, PKCE flow,
  redirect URI handling

## Changes
- Added state expiry check in callback handler (auth/callback.go)
- Added token refresh fallback (auth/token.go)
- Added expiry tolerance config (config/oauth.yaml)

## Testing
- [x] Unit tests for state expiry (auth/callback_test.go)
- [x] Integration test for full OAuth flow (integration/oauth_test.go)
- [x] Manual testing with slow connection simulation

## Risk Assessment
- Deployment risk: Medium (auth path change)
- Rollback plan: Feature flag `ods-oauth-state-fix`
- Breaking change: No

## Checklist
- [x] Branch naming follows ODS
- [x] Commits follow ODS
- [x] AI-generated code reviewed by human
- [x] No secrets included
```

**Reviewer experience:**
1. Reads title: knows it's a bugfix in auth module for OAuth state expiry.
2. Reads Summary: understands the race condition in one sentence.
3. Reads AI Disclosure: knows Copilot wrote the token refresh and state validation. Focuses review there first.
4. Reads Changes: sees 3 files, knows what each one does.
5. Reads Testing: confirms tests exist for the exact failure mode.
6. Starts code review with full context. Zero clarification questions.

**Time to first meaningful review: minutes.**
**Clarification questions per PR: 0.**

## What ODS Proves — And What It Doesn't

| ODS Proves | ODS Does Not Prove |
|---|---|
| PR has structured Summary, Changes, Testing | The code has no bugs |
| AI involvement is explicitly disclosed | AI didn't hallucinate |
| A human reviewed the AI-generated portions | The review was thorough |
| CI validated the PR metadata | Architecture is sound |
| Risk assessment and rollback plan exist | The plan will work |

## Design Philosophy

> ODS does not prove the code is correct. It proves the delivery process contains the minimum structured evidence needed for humans and machines to review the change responsibly.

This is the same philosophy behind checklists in surgery and aviation: the checklist doesn't perform the surgery or fly the plane. It ensures the team has the information they need before they start.

## Try It

1. Copy the [PR Template](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-pr-template.md) into `.github/PULL_REQUEST_TEMPLATE.md`
2. Add the [ODS L1 GitHub Action](https://github.com/open-delivery-spec/validate-action) to your CI
3. Compare your next 5 PRs to the previous 5

See [Get Started](get-started.md) for the full adoption guide.
