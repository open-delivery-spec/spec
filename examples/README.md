# ODS Examples

Copy-paste resources for integrating Open Delivery Spec into your project.

## Policy Examples

Save one of these as `.ods/policy.rego` in your repository.
The ODS CLI evaluates this file using OPA (Open Policy Agent).

| File | Use case |
|------|----------|
| [`ods-policy-oss.rego`](ods-policy-oss.rego) | Open-source project — permissive, blocks only critical issues |
| [`ods-policy-enterprise.rego`](ods-policy-enterprise.rego) | Enterprise service — strict gates for production code |

The CLI ships with a built-in default policy (`ods check` with no `.ods/policy.rego`).
These examples show how to customize it.

## PR Template

[`ods-pr-template.md`](ods-pr-template.md) — A copy-paste PR template with structured AI disclosure.
Save as `.github/pull_request_template.md` in your repository.

## Quick Start

```bash
# Install ODS CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Initialize your repo (creates the CI workflow + .ods/policy.rego)
ods init

# Copy a policy example
mkdir -p .ods
cp examples/ods-policy-enterprise.rego .ods/policy.rego

# Run the pipeline locally
ods detect && ods analyze && ods score && ods check
```

For CI integration, see the [Adoption Guide](../docs/adoption-guide.md).
