# Contributing to Open Delivery Spec

Thank you for your interest in contributing! ODS is an open specification for **governance and visibility of AI-assisted code**: attributing it from the signals tools volunteer, surfacing findings, routing review attention, and enforcing policy as code in CI. We welcome contributions from everyone. How decisions are made is in [GOVERNANCE.md](GOVERNANCE.md).

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

### AI-Assisted Contributions

AI assistance is welcome here on three conditions. This repository runs the
[open-source disclosure policy](docs/oss-ai-policy.md) it publishes, as
[`.ods/policy.rego`](.ods/policy.rego), so CI checks what it can see of them
on every pull request and posts the result as a comment.

1. **Disclose it.** Keep the `Co-Authored-By` trailer your tool adds (Claude
   Code, Copilot and Cursor add one on their own), add an
   `Assisted-by: <tool>` trailer, or tick the AI Disclosure box in the pull
   request template. A change that looks AI-assisted but says nothing gets a
   nudge in the comment and a maintainer's look; it is never blocked on
   suspicion.
2. **Test it.** AI-authored code comes with tests. Source added without a
   test is flagged.
3. **Own it.** You have read and understood what you submit and can answer
   questions about it in review. Changes to CI, dependencies or
   security-sensitive paths get extra eyes.

The trailers survive a squash merge only when the merge message includes the
commit details, not just the title; see the guide's
[rollout notes](docs/oss-ai-policy.md#set-it-up).

## Design Principles

When contributing, keep these principles in mind:

1. **Machine-first, human-readable.** Every pipeline stage emits structured JSON; every output has human docs.
2. **AI-native.** ODS exists to govern AI-assisted code. Design checks around how AI tools actually work, and read what they volunteer before inferring anything.
3. **Honest about scope.** ODS attributes, routes and gates; it is a signal producer, not a quality oracle, and it does not prove correctness or authorship.
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
