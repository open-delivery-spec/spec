# Adopters

Projects running ODS on every pull request.

## Open Delivery Spec (dogfooding)

The ODS org runs `validate-action@v1` on all its own repositories.

| Project | What runs | Since |
|---|---|---|
| [open-delivery-spec/spec](https://github.com/open-delivery-spec/spec) | validate-action@v1 on every PR | June 2026 |
| [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) | validate-action@v1 on every PR | June 2026 |
| [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) | validate-action@v1 on every PR | June 2026 |

## Pending External Adoption

Workflow files for the following repositories are ready in [`_dogfooding/`](_dogfooding/) and pending PR submission:

| Project | Description | Workflow template |
|---------|-------------|-------------------|
| [cpp-linter/cpp-linter-action](https://github.com/cpp-linter/cpp-linter-action) | C++ linting GitHub Action (used by Microsoft, NASA, Apache projects) | `_dogfooding/cpp-linter-action-ods-validate.yml` |
| [commit-check/commit-check](https://github.com/commit-check/commit-check) | Commit message and branch naming validator | `_dogfooding/commit-check-ods-validate.yml` |
| [conventional-branch/conventional-branch](https://github.com/conventional-branch/conventional-branch) | Conventional branch naming enforcer | `_dogfooding/conventional-branch-ods-validate.yml` |

## Community

*Using ODS? Open a PR to add your project here.*
