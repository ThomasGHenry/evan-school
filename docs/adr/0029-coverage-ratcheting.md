---
status: accepted
date: 2026-07-07
tags: [tooling, quality]
implementation: scripts/ci/ratchet-coverage.sh
---

# 0029. Coverage Ratcheting via coverage_floor.json

## Context

Coverage percentages tend to drift down as features are added. Hard coverage thresholds
("must be above 80%") are gamed or impossible to meet on new projects. The ratcheting
pattern (from diane-v01) avoids both: the floor only ever rises, auto-committing when
coverage improves, and failing CI only when coverage drops below the current floor.

## Decision

`scripts/ci/ratchet-coverage.sh` implements a three-exit protocol:
- Exit 0: coverage at or above floor, no change
- Exit 1: coverage dropped below floor — CI fails
- Exit 2: coverage improved — CI auto-commits updated `coverage_floor.json`

`coverage_floor.json` ships as `{}` (all floors at 0). Instances populate it as tests
are written. The `coverage-gate` CI job runs after `test`, downloads the coverage LCOV
artifact, and calls the ratchet script. If no LCOV artifact exists, the job passes
(template has no meaningful coverage yet).

## Consequences

- Floor never decreases automatically (only via deliberate `coverage_floor.json` edit)
- Instances must configure Vitest LCOV output and upload as `coverage` artifact
- Exit code 2 must not be treated as failure by CI callers
