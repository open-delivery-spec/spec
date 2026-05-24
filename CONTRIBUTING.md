# Contributing to Open Delivery Spec

Thank you for your interest in contributing! ODS is an open specification for AI-era delivery governance, and we welcome contributions from everyone.

## How to Contribute

### Proposing Changes

1. **Open an Issue** — Describe the problem, use case, and proposed solution. For new modules, explain what delivery artifact needs standardization and why.
2. **Discuss** — The community and maintainers will provide feedback.
3. **Submit a PR** — Once there's rough consensus, implement the change.

### PR Requirements

- [ ] Changes follow the [ODS PR Description spec](spec/03-pr-description.md)
- [ ] If the change adds or modifies a spec module, the corresponding JSON Schema is updated
- [ ] Examples are provided for new functionality
- [ ] Breaking changes are called out explicitly
- [ ] CHANGELOG.md is updated

### Spec Module Template

When proposing a new module, follow this structure:

```markdown
# XX — Module Name

**Version:** 1.0.0
**Schema:** `schemas/module-name.json`

## Overview
[1-2 paragraphs explaining the problem this module solves]

## Specification
[Detailed spec with tables, examples, rules]

## JSON Schema Validation
[What the schema enforces]

## Tooling
[CLI and CI integration examples]

## Relationship to Other Specs
[Cross-references]
```

## Design Principles

When contributing, keep these principles in mind:

1. **Machine-first, human-readable.** Every spec must have a JSON Schema. Every schema must have docs.
2. **AI-native.** Include AI attribution metadata. Design for AI agents as first-class participants.
3. **Composable.** Each module must work independently.
4. **Tool-agnostic.** Don't assume a specific CI/CD, AI tool, or VCS.
5. **Audit-ready.** Every artifact should carry evidence for compliance.

## Development

### Validating Schemas

```bash
# Validate all schemas against JSON Schema Draft 2020-12
find schemas/ -name "*.json" -exec ajv validate -s meta-schema.json -d {} \;

# Validate example against a schema
ajv validate -s schemas/branch-naming.json -d examples/branch-naming-example.json
```

### Previewing Documentation

```bash
# Use any Markdown previewer
# The spec is pure Markdown with JSON examples
```

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/).

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
