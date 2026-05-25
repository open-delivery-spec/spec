# End-to-End Example: ODS L1 + AI Disclosure

This example shows the production-ready adoption path: branch naming, commit message validation, PR description validation, and explicit AI disclosure.

## Scenario

A developer uses an AI assistant to add OAuth 2.0 login to a backend service. ODS makes the delivery metadata visible and machine-checkable before merge.

## Step 1 - Branch Naming

```bash
git checkout -b feature/add-oauth-login
ods validate branch feature/add-oauth-login
# conformant - all requirements satisfied
```

## Step 2 - Commit Message

```text
feat(auth): add OAuth 2.0 login flow

Implemented authorization code flow with PKCE.

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module, token exchange, provider configs
AI-review: pending
Ticket: PROJ-1234
```

```bash
ods validate commit --file commit-msg.txt
# conformant - all requirements satisfied
```

## Step 3 - PR Description

```markdown
## Summary
Add OAuth 2.0 login flow with Google, GitHub, and Microsoft providers.

## Type
- [x] Feature

## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Provider abstraction, token exchange, session management
- Human Review: Verified OAuth spec compliance, PKCE handling, and redirect URI validation

## Changes
- Added OAuth provider abstraction layer
- Implemented provider configs
- Added PKCE support
- Added refresh token handling

## Testing
- [x] Unit tests added
- [x] Integration tests added
- [x] Manual testing performed

## Checklist
- [x] Branch naming follows ODS
- [x] Commits follow ODS
- [x] AI-generated code has been reviewed by a human
- [x] No secrets included
- [x] Documentation updated
```

```bash
ods validate pr --file PR_BODY.md
# conformant - all requirements satisfied
```

## Step 4 - GitHub Action

Copy the workflow files into your repository:

- [`.github/workflows/ods-l1.yml`](.github/workflows/ods-l1.yml) — Validates branch name and PR description on every PR
- [`.github/workflows/ods-commit-message.yml`](.github/workflows/ods-commit-message.yml) — Validates commit messages on push

```bash
cp .github/workflows/ods-l1.yml ../your-repo/.github/workflows/
cp .github/workflows/ods-commit-message.yml ../your-repo/.github/workflows/
```

Both workflows use `open-delivery-spec/validate-action@v1` and the Go-based ODS CLI under the hood.

## Optional `.ods/` Artifact

The draft release-governance modules use `.ods/` for evidence records. For L1, teams may optionally store PR metadata for demos or audits. See the full [`.ods/` Convention](../../docs/ods-artifacts.md) for details.

Example directory structure:

```text
.ods/
  pr-42/
    pr-description.md
    ai-disclosure.json
```

Example `ai-disclosure.json`:

```json
{
  "pr_number": 42,
  "ai_assisted": true,
  "ai_tool": "GitHub Copilot",
  "ai_scope": "auth module, token exchange, provider configs",
  "human_review": "Verified OAuth spec compliance, PKCE handling, and redirect URI validation"
}
```

This file is illustrative. The production M1 gate is still the CLI and GitHub Action validation of branch, commit, and PR metadata.
