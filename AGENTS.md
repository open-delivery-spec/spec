# Agent Development Rules — open-delivery-spec/spec

This file instructs AI coding agents (Claude Code, Copilot Workspace, etc.) on how to work in this repository.

## About This Repo

This is the ODS specification repository. It contains:

- `schemas/` — JSON Schema definitions for the ODS data model
- `spec/` — the human-readable specification and conformance tests
- `docs/` — guides, ecosystem docs, and quickstarts
- `_dogfooding/` — example workflows that use ODS on external repos

## Branching Rules

- **NEVER push directly to `main`.** All changes enter via pull request only.
- **Always start from the latest `main`.** Before creating any branch:

  ```bash
  git fetch origin
  git checkout main
  git pull origin main
  git checkout -b <branch-name>
  ```

  Never branch from a stale local `main` or from another feature branch.

- **Branch names must follow Conventional Branch naming.** Allowed prefixes:

  | Prefix | Use for |
  |--------|---------|
  | `feat/` | New features or spec additions |
  | `fix/` | Corrections to existing spec or schemas |
  | `docs/` | Documentation only |
  | `chore/` | Maintenance, versioning |
  | `ci/` | CI/CD changes |
  | `refactor/` | Restructuring without behavioral change |
  | `test/` | Conformance tests only |

  AI-agent branches are also accepted: `claude/`, `copilot/`, `github-actions/`

  Branch names must be lowercase. The description part must not contain `/`.

## Commit Message Rules

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/). This is enforced in CI by `commit-check`.

```
type(scope): description
```

- **type**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`
- **scope**: optional, lowercase, no slashes (e.g., `schemas`, `conformance`, `docs`)
- **description**: imperative mood, no capital first letter, no trailing period
- **subject line**: maximum 80 characters

Examples:
```
feat: add policy-input JSON schema v1
fix(schemas): correct test_coverage sentinel description to -1.0
docs: add ecosystem integrations page
test(conformance): add block-ai-no-tests scenario
```

## Schema Changes

When modifying schemas under `schemas/`:

- Bump the schema version directory if the change is breaking (e.g., `v1/` → `v2/`)
- Non-breaking additions (new optional fields) may stay in the same version
- Update `docs/schemas.md` to reflect the change
- Add or update a conformance scenario in `spec/conformance/` if the change affects policy evaluation

## Conformance Tests

Tests live in `spec/conformance/`. Each scenario is a directory containing:

- `input.json` — the `EvalInput` document
- `expected.json` — `{ "allowed": true/false, "denials": [...], "warnings": [...] }`
- `README.md` — one-paragraph description of what the scenario tests

All scenarios must pass against the reference CLI implementation before merging.

## PR Workflow

- Ensure your branch is rebased on the latest `main` before opening a PR (`git rebase origin/main`)
- Do not open PRs without explicit user instruction
- All PRs target `main`
- CI runs `commit-check` (branch + message) and the ODS validate-action quality gate
