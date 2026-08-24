# ADR Process

Architecture Decision Records (ADRs) document significant technical decisions.

## When to Write an ADR

Write an ADR when:
- Adopting a new technology or framework
- Making a structural architectural change
- Establishing a pattern that will be followed across the codebase
- Deciding between multiple reasonable alternatives

## ADR Format

See `0000-template.md` for the format specification.

## Numbering

ADRs use 4-digit sequential numbers: `0001-kebab-slug.md`.
Not date-based. Never reuse a number.

## Validation

Run `bash scripts/ci/validate-adrs.sh docs/adr` to validate all ADRs.
This runs automatically in CI and as a pre-commit hook.
