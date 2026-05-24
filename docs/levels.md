# ODS Levels

ODS defines a progressive maturity model for delivery governance. Teams can adopt one level at a time, with each level building on the previous one.

## Level Summary

| Level | Name | Focus | Modules |
|-------|------|-------|---------|
| **ODS L1** | Structured Delivery | Make delivery artifacts machine-readable | 01, 02, 03 |
| **ODS L2** | AI-Aware Delivery | Record AI involvement in the delivery process | 04, 05 |
| **ODS L3** | Evidence-Based Delivery | Produce auditable evidence for releases | 06, 08, 09 |
| **ODS L4** | Governed Delivery _(planned)_ | Enforce delivery policy as code | 07 |

---

## ODS L1 — Structured Delivery

**The minimum adoption level.** Your branches, commits, and PR descriptions follow a machine-readable structure.

| Module | What it ensures |
|--------|----------------|
| 01 Branch Naming | Branches follow `<type>/<description>` format, enabling automated categorization |
| 02 Commit Message | Commits follow Conventional Commits with optional AI attribution |
| 03 PR Description | PRs include Summary, Type, AI Disclosure, Changes, Testing, Checklist |

**Outcome**: Every change has structured metadata that CI systems and AI agents can consume.

> Start here. L1 is the foundation.

---

## ODS L2 — AI-Aware Delivery

**For teams using AI coding tools.** You explicitly record when AI generated code, and you capture CI failures in a structured format.

| Module | What it ensures |
|--------|----------------|
| 04 AI Change Review | AI-generated changes have a review protocol (L1/L2/L3) |
| 05 CI Failure | CI failures produce machine-parseable reports with AI explanation |

**Outcome**: You can answer "was this change AI-generated?" and "why did CI fail?" programmatically.

---

## ODS L3 — Evidence-Based Delivery

**For teams that need audit trails.** Every release produces structured evidence of readiness, rollback capability, and deployment verification.

| Module | What it ensures |
|--------|----------------|
| 06 Release Readiness | Releases pass evidence-based gates with scoring |
| 08 Rollback Plan | Every release has a documented, verifiable rollback path |
| 09 Production Release Evidence | Deployments produce immutable, auditable evidence bundles |

**Outcome**: Production releases carry machine-verifiable evidence that gates were met.

---

## ODS L4 — Governed Delivery _(planned)_

**Future level.** Policy-as-code for approval workflows, multi-role sign-off, and automated compliance reporting.

| Module | What it ensures |
|--------|----------------|
| 07 Approval Workflow | Declarative, AI-aware approval policies |

---

## Using the Levels

You don't need to start at L3. Most teams start at L1:

```yaml
# .github/workflows/ods.yml
- uses: open-delivery-spec/github-action@v1
  with:
    check: branch-naming
    branch_name: ${{ github.head_ref }}
```

Then add more checks as your team's governance needs grow.

## Conformance Language

| Term | Meaning |
|------|---------|
| **ODS L1 Compliant** | All L1 checks pass on every PR / push |
| **ODS L2 Compliant** | L1 + L2 checks pass |
| **ODS L3 Compliant** | L1 + L2 + L3 checks pass |
