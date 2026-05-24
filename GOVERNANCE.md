# Governance

Open Delivery Spec is an open standard developed in the open. This document describes how decisions are made, who has authority, and how the specification evolves.

## Roles

| Role | Responsibilities |
|------|-----------------|
| **Maintainers** | Approve RFCs, merge PRs, cut releases. Small group of trusted contributors. |
| **Contributors** | Anyone who opens issues, proposes changes, or submits PRs. |
| **Community** | Users who adopt ODS, give feedback, and spread the word. |

Current maintainers are listed in [CODEOWNERS](../.github/CODEOWNERS).

## Decision Making

### Day-to-day changes

- Documentation fixes, example updates, minor schema clarifications → PR + one maintainer approval.
- New optional fields, new enum values → PR + discussion + one maintainer approval.

### Significant changes

- New required fields, new modules, schema restructuring → requires an RFC.
- Breaking changes to Candidate or Stable modules → requires an RFC and a migration plan.

### RFC Process

1. **Proposal** — Open a GitHub Issue using the appropriate template ([schema change](.github/ISSUE_TEMPLATE/schema-change.md) or [module proposal](.github/ISSUE_TEMPLATE/module-proposal.md)).
2. **Discussion** — Community and maintainers discuss. Minimum 7-day comment period.
3. **Decision** — Maintainers reach consensus (lazy consensus: no objection within 3 days after discussion).
4. **Implementation** — PR with spec changes, schema updates, and examples.
5. **Release** — Included in the next versioned spec release.

### Lazy Consensus

For non-controversial changes, if no maintainer objects within 3 business days after the final proposal is posted, the change is considered approved. Explicit approval is always preferred but not always required.

## Module Status Transitions

| From → To | Requirements |
|-----------|-------------|
| Draft → Candidate | Schema implemented in CLI. At least one real-world use case validated. |
| Candidate → Stable | No breaking changes for 3 months. At least 2 external adopters. |
| Any → Deprecated | Announcement with migration path. 6-month deprecation window before removal. |

See [SPEC_VERSIONING.md](SPEC_VERSIONING.md) for version numbering rules.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

## License

All specification content is licensed under [Apache License 2.0](LICENSE). Contributions are accepted under the same license.
