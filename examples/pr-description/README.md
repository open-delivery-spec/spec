# Examples: PR Description

## AI-generated feature PR

```markdown
## Summary
Add OAuth 2.0 login flow supporting Google, GitHub, and Microsoft providers.

## Type
- [x] Feature
- [ ] Bugfix
- [ ] Hotfix
- [ ] Refactor
- [ ] Documentation
- [ ] Chore

## AI Disclosure
- [x] This PR contains AI-generated code
- **AI Tool:** GitHub Copilot + Claude
- **AI Scope:** Provider configuration, token exchange, session management
- **Human Review:** Verified OAuth spec compliance, added PKCE, fixed redirect URI validation

## Related Issues
Closes #42

## Changes
- Added OAuth provider abstraction layer
- Implemented Google, GitHub, Microsoft provider configs
- Added PKCE support for all flows
- Created session management with refresh token rotation

## Testing
- [x] Unit tests added/updated
- [x] Integration tests added/updated
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
- [x] No secrets, tokens, or credentials are included
- [x] Documentation has been updated
```

## Human-only PR

```markdown
## Summary
Fix header overflow on mobile devices

## Type
- [ ] Feature
- [x] Bugfix
- [ ] Hotfix
- [ ] Refactor
- [ ] Documentation
- [ ] Chore

## AI Disclosure
- [ ] This PR contains AI-generated code

## Related Issues
Fixes #156

## Changes
- Updated header CSS to use flexbox
- Added mobile breakpoint at 768px

## Testing
- [x] Manual testing performed on iPhone 14, Pixel 7

## Risk Assessment
- **Deployment risk:** Low
- **Breaking change:** No

## Checklist
- [x] Branch naming follows ODS
- [x] Commits follow ODS
- [x] No secrets, tokens, or credentials are included
```
