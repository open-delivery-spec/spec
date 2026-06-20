# ODS Dogfooding — External Workflow Files

This directory contains GitHub Actions workflow files for use in **external repositories** — open-source projects that are not part of the `open-delivery-spec` organization.

## Purpose

These workflows demonstrate how any project can adopt ODS validation on their pull requests. Each file is designed to be submitted as a PR to the target repository by a human maintainer.

## Available Workflows

| File | Target Repository | Default Branch |
|---|---|---|
| [commit-check-ods-validate.yml](commit-check-ods-validate.yml) | [commit-check/commit-check](https://github.com/commit-check/commit-check) | `main` |
| [cpp-linter-action-ods-validate.yml](cpp-linter-action-ods-validate.yml) | [cpp-linter/cpp-linter-action](https://github.com/cpp-linter/cpp-linter-action) | `main` |
| [conventional-branch-ods-validate.yml](conventional-branch-ods-validate.yml) | [conventional-branch/conventional-branch](https://github.com/conventional-branch/conventional-branch) | `main` |
| [blog-ods-validate.yml](blog-ods-validate.yml) | [shenxianpeng/shenxianpeng.github.io](https://github.com/shenxianpeng/shenxianpeng.github.io) | `master` |

## How to Submit

1. Fork the target repository
2. Copy the workflow file to `.github/workflows/ods-validate.yml` in the target repo
3. Optionally adjust the `on:` trigger branches to match the repo's default branch
4. Commit and open a pull request

## What Each Workflow Does

Each workflow runs on every pull request to the default branch and performs:

1. **Branch naming check** — validates against conventional branch prefixes (`feature/`, `bugfix/`, `hotfix/`, `release/`, `chore/`)
2. **Commit message check** — validates against Conventional Commits format (`feat:`, `fix:`, `docs:`, etc.)
3. **ODS AI code quality gate** — detects AI-generated code, analyzes quality, scores technical debt, and enforces policy (using `validate-action@v1`)

## Note

These workflows are not automatically deployed. They are templates for Xianpeng to submit as manual PRs to the target repositories.
