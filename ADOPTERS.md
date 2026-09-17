# Adopters

Projects running ODS on every pull request.

## External Repositories

| Project | Description | What runs | Since |
|---------|-------------|-----------|-------|
| [devops-maturity/devops-maturity](https://github.com/devops-maturity/devops-maturity) | DevOps maturity model and assessment | validate-action@v1 on every PR | July 2026 |
| [conventional-branch/conventional-branch](https://github.com/conventional-branch/conventional-branch) | Conventional branch naming specification | validate-action@v1 on every PR | July 2026 |
| [shenxianpeng/blog](https://github.com/shenxianpeng/blog) | Maintainer's blog (Hugo) | validate-action@v1 on every PR | July 2026 |

## Open Delivery Spec (dogfooding)

Every repository in the organization runs `validate-action@v1` on its own
pull requests with the [open-source disclosure policy](docs/oss-ai-policy.md),
the same `examples/ods-policy-oss-disclosure.rego` adopters copy, with review
routing on. The AI Disclosure pull-request template and the CONTRIBUTING AI
clause are set once, as organization defaults in
[`open-delivery-spec/.github`](https://github.com/open-delivery-spec/.github).

| Project | What runs | Policy | Since |
|---|---|---|---|
| [open-delivery-spec/spec](https://github.com/open-delivery-spec/spec) | validate-action@v1 on every PR | OSS disclosure; CI keeps `.ods/policy.rego` identical to the template | June 2026 |
| [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) | validate-action@v1 on every PR, built from the PR head, with a diff-scoped mutation report | OSS disclosure | June 2026 |
| [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) | validate-action@v1 on every PR | OSS disclosure | June 2026 |
| [open-delivery-spec/.github](https://github.com/open-delivery-spec/.github) | validate-action@v1 on every PR; `org-ai-report` weekly for the organization | OSS disclosure | September 2026 |

## Pending External Adoption

Workflow files for the following repositories are ready in [`_dogfooding/`](_dogfooding/) and pending PR submission; [`_dogfooding/pull-request-body.md`](_dogfooding/pull-request-body.md) is the description to open them with:

| Project | Description | Workflow template |
|---------|-------------|-------------------|
| [cpp-linter/cpp-linter-action](https://github.com/cpp-linter/cpp-linter-action) | C++ linting GitHub Action (used by Microsoft, NASA, Apache projects) | `_dogfooding/cpp-linter-action-ods-validate.yml` |
| [commit-check/commit-check](https://github.com/commit-check/commit-check) | Commit message and branch naming validator | `_dogfooding/commit-check-ods-validate.yml` |

## Community

*Using ODS? Open a PR to add your project here.*
