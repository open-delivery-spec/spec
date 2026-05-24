# Examples: Commit Messages

## AI-generated feature commit

```
feat(auth): add OAuth 2.0 login flow

Implemented OAuth 2.0 authorization code flow with PKCE.
Supports Google, GitHub, and Microsoft providers.

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module, token refresh logic
AI-review: pending
AI-confidence: high
Ticket: PROJ-1234
```

## AI-assisted bugfix

```
fix(parser): handle empty input gracefully

Previously, empty input caused a null pointer exception.
Added guard clause at the top of parse().

AI-assisted: true
AI-tool: Claude
AI-scope: null check suggestion
AI-review: passed
Ticket: BUG-891
```

## Pure human commit

```
chore(deps): bump lodash from 4.17.20 to 4.17.21

AI-assisted: false
```

## Breaking change

```
feat!: remove legacy auth endpoint

BREAKING CHANGE: The /v1/auth endpoint has been removed.
Users must migrate to /v2/auth. See MIGRATION.md for details.

AI-assisted: false
```

## CLI Usage

```bash
# Validate from file
ods validate commit --file commit.txt

# Validate from git
git log -1 --format=%B | ods validate commit --stdin

# Generate a template
ods generate commit --type feat --scope auth --ai-tool "GitHub Copilot"
```
