# Contributing to Open Delivery Spec

Thank you for your interest in contributing! ODS is an open specification for the **AI code quality gate** — attributing AI-generated code, analyzing its quality, scoring its technical-debt impact, and enforcing policy in CI. We welcome contributions from everyone.

## How to Contribute

### Proposing Changes

1. **Open an Issue** — Describe the problem, use case, and proposed change. For a new check, explain what AI-code signal or defect it captures and why.
2. **Discuss** — The community and maintainers will provide feedback.
3. **Submit a PR** — Once there's rough consensus, implement the change.

### What You Can Contribute

ODS is the pipeline `detect → analyze → score → check`. Contributions usually fall into one of these:

| Contribution | Where it lands | Example |
|--------------|----------------|---------|
| **Detection signal** | `detect` | A new way to identify AI-generated code |
| **Analysis rule** | `analyze` | A new AI-specific defect pattern to flag |
| **Scoring dimension** | `score` | A new factor in the technical-debt score |
| **Rego policy example** | `examples/` | A reusable enforcement policy for a common need |
| **Documentation** | `docs/` | Clearer guides, scenarios, comparisons |

Each new check carries a maturity status (**Experimental → Candidate → Stable**); see [ROADMAP.md](ROADMAP.md) and [SPEC_VERSIONING.md](SPEC_VERSIONING.md).

### PR Requirements

- [ ] The change is described clearly, with a use case
- [ ] New checks state their maturity status and rationale
- [ ] Examples are provided for new functionality
- [ ] Breaking changes are called out explicitly
- [ ] [CHANGELOG.md](CHANGELOG.md) is updated

## Design Principles

When contributing, keep these principles in mind:

1. **Machine-first, human-readable.** Every pipeline stage emits structured JSON; every output has human docs.
2. **AI-native.** ODS exists to govern AI-generated code. Design checks around how AI actually writes code.
3. **Honest about scope.** ODS proves AI code was detected, vetted, and within policy — it does not prove correctness.
4. **Tool-agnostic.** Don't assume a specific CI/CD, AI tool, or VCS.
5. **Policy-driven.** Enforcement decisions belong in OPA Rego, not hardcoded in tooling.

## Development

The reference implementation lives in the [CLI repo](https://github.com/open-delivery-spec/cli). Detection signals, analysis rules, scoring dimensions, and the policy engine are implemented and tested there.

### Previewing Documentation

```bash
cd docs
bundle install
bundle exec jekyll serve
```

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/).

## License

> [!NOTE]
> By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
