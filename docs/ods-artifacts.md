---
title: ODS Artifacts
nav_order: 4
parent: Home
---

# `.ods/` Artifact Directory Convention

ODS supports two complementary operating modes: **lightweight CLI/GitHub Action validation** for the production-ready L1 checks, and **file-based evidence artifacts** for draft (and future stable) release-governance modules.

When teams adopt evidence-based delivery governance, structured records are stored under a `.ods/` directory at the repository root.

## Directory Layout

```
repository-root/
├── .ods/
│   ├── releases/
│   │   └── v1.4.0/
│   │       ├── release-readiness.json    # Module 06
│   │       ├── rollback-plan.json        # Module 08
│   │       └── evidence-bundle.json      # Module 09
│   ├── reviews/
│   │   └── pr-42/
│   │       └── ai-review.json            # Module 04
│   ├── approvals/
│   │   └── ods-approval.json             # Module 07
│   └── failures/
│       └── build-12345/
│           └── ci-failure.json           # Module 05
├── .ods.yaml                             # Optional CLI configuration
└── ...
```

## File Naming Conventions

| Artifact | Path Pattern | Module |
|----------|-------------|--------|
| Branch metadata | `.ods/releases/<version>/branch-meta.json` | 01 |
| PR description metadata | `.ods/releases/<version>/pr-description.json` | 03 |
| AI review record | `.ods/reviews/pr-<number>/ai-review.json` | 04 |
| CI failure report | `.ods/failures/<pipeline-id>/ci-failure.json` | 05 |
| Release readiness | `.ods/releases/<version>/release-readiness.json` | 06 |
| Approval policy | `.ods/approvals/ods-approval.json` | 07 |
| Rollback plan | `.ods/releases/<version>/rollback-plan.json` | 08 |
| Evidence bundle | `.ods/releases/<version>/evidence-bundle.json` | 09 |

## Modes of Operation

### L1: Lightweight Validation (Production)

For the current stable surface (Modules 01–03), **no `.ods/` directory is required**. The CLI and GitHub Action validate branch names, commit messages, and PR descriptions directly from CI context:

```yaml
# .github/workflows/ods-l1.yml — No .ods/ directory needed
- uses: open-delivery-spec/validate-action@v1
  with:
    check: all
    branch_name: ${{ github.head_ref }}
    pr_body: ${{ github.event.pull_request.body }}
    strict: "true"
```

### L2+: Evidence Artifacts (Draft → Future Stable)

As modules 04–09 mature beyond Draft, teams store structured JSON records in `.ods/`. These artifacts are:

- **Schema-validated** — Every `.json` file conforms to the module's JSON Schema
- **Immutable by convention** — Evidence bundles carry a content hash and `immutable: true`
- **CI-checked** — Optional CI steps can validate `.ods/` artifacts against schemas
- **Audit-trail ready** — Each artifact is timestamped and attributable

## `.ods.yaml` Configuration

An optional configuration file at the repository root controls CLI behavior:

```yaml
# .ods.yaml
schemas:
  spec_version: "1.0.0"
  schema_base_url: "https://open-delivery-spec.dev/schemas"

policies:
  approval: ".ods/approvals/ods-approval.json"

ci:
  provider: github-actions

artifacts:
  root: ".ods"        # Override default artifact directory
  releases: "releases"
  reviews: "reviews"
```

## Adding `.ods/` to `.gitignore`

Evidence artifacts are designed to be committed for audit trails. However, if your workflow generates temporary or environment-specific artifacts, add those to `.gitignore`:

```gitignore
# ODS temporary artifacts
.ods/tmp/
.ods/cache/
```

## Validating Artifacts with the CLI

```bash
# Validate a release readiness report
ods validate release --file .ods/releases/v1.4.0/release-readiness.json

# Validate a rollback plan
ods validate rollback --file .ods/releases/v1.4.0/rollback-plan.json

# Validate an evidence bundle
ods validate evidence --file .ods/releases/v1.4.0/evidence-bundle.json

# Validate an AI review record
ods review validate --file .ods/reviews/pr-42/ai-review.json

# Validate an approval policy
ods validate approval-policy --file .ods/approvals/ods-approval.json

# Validate a CI failure record
ods ci parse --file .ods/failures/build-12345/ci-failure.json
```

## Relationship to Other Standards

| Standard | Scope | Overlap |
|----------|-------|---------|
| SLSA | Build provenance | ODS `.ods/` stores delivery evidence; SLSA stores build attestations |
| in-toto | Supply chain metadata | Compatible; ODS artifacts could be wrapped as in-toto attestations |
| SPDX | SBOM | ODS does not replace SBOM; the evidence bundle can reference an SBOM URL |

---

> [!NOTE]
> The `.ods/` directory convention is **stable for L1** (optional artifact storage for demos and audits).  
> Paths for modules 04-09 reflect the **draft schema design** and may evolve before those modules reach Candidate status.  
> See [ROADMAP.md](../ROADMAP.md) for module maturity timelines.
