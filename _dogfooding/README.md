# ODS Dogfooding — External Workflow Files

This directory contains GitHub Actions workflow files for use in **external repositories** — open-source projects that are not part of the `open-delivery-spec` organization.

## Purpose

These workflows demonstrate how any project can adopt ODS validation on their pull requests. Each file is designed to be submitted as a PR to the target repository by a human maintainer.

## Available Workflows

| File | Target Repository | Default Branch |
|---|---|---|
| [commit-check-ods-validate.yml](commit-check-ods-validate.yml) | [commit-check/commit-check](https://github.com/commit-check/commit-check) | `main` |
| [cpp-linter-action-ods-validate.yml](cpp-linter-action-ods-validate.yml) | [cpp-linter/cpp-linter-action](https://github.com/cpp-linter/cpp-linter-action) | `main` |

## How to Submit

1. Fork the target repository
2. Copy the workflow file to `.github/workflows/ods-validate.yml` in the target repo
3. Optionally adjust the `on:` trigger branches to match the repo's default branch
4. Commit and open a pull request

## What Each Workflow Does

Each workflow runs on every pull request to the default branch and performs:

1. **Conventional branch & commit checks** — runs the [`commit-check`](https://github.com/commit-check/commit-check) CLI (`commit-check>=2.9.0`) to validate branch names (Conventional Branch) and commit messages (Conventional Commits). Using the dedicated tool — instead of hand-rolled `grep` — keeps the rules configurable and, from 2.9.0 on, recognizes AI-tool branch prefixes (`claude/`, `copilot/`, `cursor/`). The workflow checks out the PR head commit by SHA (`github.event.pull_request.head.sha`) so the checks see the real PR commits rather than the synthetic merge commit; unlike `github.head_ref`, which names a branch that exists only in the contributor's fork, the SHA also resolves for pull requests from forks. commit-check reads the branch name from `GITHUB_HEAD_REF` when HEAD is detached.
2. **ODS AI code quality gate** — detects AI-generated code, analyzes quality, scores technical debt, and enforces policy (using `validate-action@v1`)

## Note

These workflows are not deployed automatically. A maintainer submits each one as a pull request to the target repository; once it lands, the template is removed here and the repository is listed in [ADOPTERS.md](../ADOPTERS.md).
