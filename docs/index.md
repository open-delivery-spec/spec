---
title: Home
layout: home
nav_order: 1
---

# Open Delivery Spec

**Zero-config governance and visibility for AI-assisted code, on every pull request.**

Claude Code, GitHub Copilot and Cursor already stamp `Co-Authored-By` trailers on
the commits they help write. ODS reads those signals in CI to attribute
AI-assisted code, show how much of your delivery it is, route review attention
to the changes that need it, and enforce your policy as code. It governs the AI
you can see: it is a signal producer, not a quality oracle, and it never claims
that code is correct.

> **Start here**: [Get Started](get-started.md), five minutes to a report on every PR  
> **Write the policy**: [Writing Policies (Rego)](policy-authoring.md) and the [contract it reads](schemas.md)  
> **Maintainers with an AI clause in CONTRIBUTING**: [Open-Source AI Policy](oss-ai-policy.md), disclose it, test it, own it  
> **How much of the organization's delivery is AI-assisted**: [Organization-wide View](org-view.md)  
> **Where the policy lives**: [`.ods/` Convention](ods-artifacts.md)  
> **Why, and where it fits**: [Threats and Failure Modes](threats-and-failure-modes.md) · [Ecosystem](ecosystem.md) · [ODS and SLSA](comparison/slsa.md)  
> **Worked example**: [an AI-assisted change that Semgrep catches and the policy blocks](https://github.com/open-delivery-spec/spec/tree/main/examples/walkthrough)

## What runs on a pull request

```
detect  → which changes are AI-assisted, from the signals tools volunteer
analyze → what the built-in heuristics and your SARIF scanners found
score   → how much technical debt the change adds, driven by quality
check   → your Rego policy: PASS / WARN / BLOCK, plus a review tier
```

The result is a PR comment, a job summary and a machine-readable report. The
[GitHub Action](https://github.com/open-delivery-spec/validate-action) runs all
four stages with no configuration. Each stage, the detection signals with their
confidence, and the design principles are described in the
[project README](https://github.com/open-delivery-spec/spec#readme).

## Beyond one pull request

- `ods report` turns the same attribution into a per-repository dashboard over
  git history, and `ods report merge` combines repositories into one
  [organization-wide view](org-view.md).
- `ods attest` emits an AI-code evidence document (CycloneDX 1.6) for audit
  trails; the design is [proposal 001](proposals/001-ai-code-evidence.md).
- The contracts (`policy-input/v1`, `check-output/v1`, `review-verdict/v1` and
  the per-command outputs) are published as JSON Schemas so any pipeline can
  produce or consume them: [Schemas](schemas.md).

## Related

- [Positioning](https://github.com/open-delivery-spec/spec/blob/main/POSITIONING.md): ODS consumes AI review; it does not try to be an AI reviewer.
- [Roadmap](https://github.com/open-delivery-spec/spec/blob/main/ROADMAP.md) · [Contributing](https://github.com/open-delivery-spec/spec/blob/main/CONTRIBUTING.md)
