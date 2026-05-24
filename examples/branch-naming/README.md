# ODS Branch Naming Examples

## Valid Examples

### Feature branch (human)
```
feature/add-oauth-login
```
```json
{
  "type": "feature",
  "description": "add-oauth-login",
  "ticket": "PROJ-1234",
  "ai_generated": false,
  "base_branch": "main"
}
```

### Feature branch (AI-generated)
```
feature/ai-add-payment-gateway
```
```json
{
  "type": "feature",
  "description": "ai-add-payment-gateway",
  "ticket": "PAY-567",
  "ai_generated": true,
  "ai_tool": "GitHub Copilot",
  "base_branch": "main"
}
```

### Bugfix branch
```
bugfix/fix-null-pointer-exception
```

### Hotfix branch
```
hotfix/critical-security-patch
```

### Release branch
```
release/v1.4.0
```

## Invalid Examples

| Branch | Error |
|--------|-------|
| `Feature/Add-Login` | Uppercase type and description |
| `feature/new--login` | Consecutive hyphens |
| `feature/-new-login` | Leading hyphen |
| `fix/header bug` | Space in description |
| `fix/header_bug` | Underscore |
| `unknown/some-task` | Unknown type prefix |

## CLI Usage

```bash
# Validate
ods validate branch feature/add-oauth-login
# ✅ conformant

ods validate branch Feature/Add-Login
# ❌ non-conformant — invalid branch type 'Feature', description must be lowercase
```
