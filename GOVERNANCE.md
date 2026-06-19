# Governance

This document describes how Open Delivery Spec is governed and how decisions are made.

---

## Current State

ODS is **maintainer-led** as of May 2026. The project was initiated by [@sxp](https://github.com/sxp) and is open to community contributions under the [Apache 2.0 License](LICENSE).

The maintainer has decision-making authority over:

- Specification changes (schema additions, modifications, deprecations)
- Module maturity levels (Candidate → Stable → Deprecated)
- Repository structure and tooling direction
- Release versioning

---

## Path to Community Governance

ODS will evolve toward community governance as contributors and adopters grow.

| Phase | Trigger | Governance Model |
|-------|---------|------------------|
| **Phase 1** (current) | Project initiated | Maintainer-led |
| **Phase 2** | 3+ recurring external contributors | Lightweight steering group with maintainer as chair |
| **Phase 3** | 5+ external adopters, multiple orgs represented | Community steering committee with formal charter |

---

## Decision Making

### Specification Changes

1. **Open an issue** describing the proposed change
2. **Discuss** in the issue thread (minimum 7 days for non-trivial changes)
3. **Maintainer decision** or community consensus (Phase 2+)
4. **PR merged** with schema update, spec doc update, and changelog entry

### Module Maturity

| Stage | Criteria | Decision |
|-------|----------|----------|
| **Candidate** | Stable specification, at least one reference implementation | Maintainer + community input |
| **Stable** | Widely adopted, backward-compatible changes only, formal test suite | Community steering group |
| **Deprecated** | Superseded or out of scope | Maintainer |

---

## Contribution

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contribution process.

Key principles:

- **Open discussion**: Proposals start as GitHub issues
- **Spec-first**: Implementation follows specification
- **Backward compatibility**: Stable modules don't break existing users
- **Reference implementation**: Changes must include CLI/action updates when applicable

---

## Community Channels

| Channel | Purpose |
|---------|--------|
| [GitHub Issues](https://github.com/open-delivery-spec/spec/issues) | Bug reports, feature proposals, spec discussions |
| [GitHub Discussions](https://github.com/orgs/open-delivery-spec/discussions) | General Q&A, adoption stories, ecosystem ideas |

---

## Code of Conduct

ODS follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

---

## License

All repositories under `github.com/open-delivery-spec` are [Apache 2.0](LICENSE) licensed. Contributions are made under the same license.

---

*This document was last updated June 2026.*
