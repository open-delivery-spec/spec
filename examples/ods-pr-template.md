# ODS PR Template

Copy this into `.github/PULL_REQUEST_TEMPLATE.md` or your PR description. A structured PR body — especially the AI Disclosure section — is one of the signals the ODS `detect` stage reads to flag AI-assisted changes.

```markdown
## Summary
<!-- Brief description of what this PR does and why. 1-3 sentences. -->

## Type
<!-- Check one -->
- [ ] Feature
- [ ] Bugfix
- [ ] Hotfix
- [ ] Refactor
- [ ] Documentation
- [ ] Chore

## AI Disclosure
<!-- Required if AI assisted in generating any part of this PR. Remove if not applicable. -->
- [ ] This PR contains AI-generated code
- **AI Tool:** <!-- e.g. GitHub Copilot, Cursor, Claude -->
- **AI Scope:** <!-- What part did AI generate? e.g. "auth module, token exchange, tests" -->
- **Human Review:** <!-- What did the human verify? e.g. "Verified OAuth spec compliance, PKCE handling, redirect URI validation" -->

## Changes
<!-- Bullet list of key changes. Each line should describe one coherent change. -->
-
-

## Testing
<!-- Check all that apply. Add details. -->
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Risk Assessment
<!-- Required for hotfixes and high-risk changes. Optional otherwise. -->
- **Deployment risk:** <!-- Low / Medium / High -->
- **Rollback plan:** <!-- e.g. "Feature flag: ods-oauth-v2" or "Revert commit" -->
- **Breaking change:** <!-- Yes / No -->

## Checklist
- [ ] AI involvement disclosed above (or `Co-Authored-By` trailer present on commits)
- [ ] AI-generated code has been reviewed by a human
- [ ] Tests cover AI-generated logic
- [ ] No secrets or credentials included
- [ ] Documentation updated (if applicable)
```

## Why This Template

| Without this template | With this template |
|---|---|
| "fix stuff" | `fix(auth): handle expired OAuth state parameter` |
| Empty PR body | Summary, Changes, Testing, AI Disclosure |
| Reviewer asks: "What does this do? Was it tested? Did AI write this?" | Reviewer has answers before opening the PR |
| `detect` has no PR-body signal to read | `detect` reads the AI Disclosure section as a detection source |
| No audit trail for AI involvement | Machine-readable AI disclosure per PR |

## Usage

### GitHub
```bash
cp examples/ods-pr-template.md .github/PULL_REQUEST_TEMPLATE.md
```

`ods init` also scaffolds this template automatically.

## Related

- [ODS README](../README.md) — project overview
- [Get Started](../docs/get-started.md) — adoption guide
- [`.ods/` Convention](../docs/ods-artifacts.md) — policy and configuration
