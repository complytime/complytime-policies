# Feature specification: Policy OCI — Quay E2E, supply chain handoff, and promote/verify

**Feature ID:** `002-policy-oci-quay-e2e-supply-chain`  
**Created:** 2026-04-23  
**Status:** Draft  
**Relates to:** [001-policy-oci-publish](../001-policy-oci-publish/spec.md) (thin caller and FR-001–FR-008 **unchanged** by this feature)

## Purpose

Capture **operational and design** work that does **not** modify the [001](./../001-policy-oci-publish/spec.md)
product spec: E2E validation of **complytime-policies → GHCR → sign → Quay**, **org-infra-tests** as an
interim pin, **destination `cosign verify` on Quay**, **cosign copy** vs **`oras copy -r`**, Quay UI
vs CLI for Gemara bundles, and **team asks** for review. This feature is the **single spec home** for
that narrative; [001](../001-policy-oci-publish/spec.md) remains the **v1 release** requirements.

## Scope (in)

- Traceability: **go-gemara** → **oci-artifact** → **complytime/org-infra** → **complytime-policies**
  (see [research.md](./research.md) and [team-handoff.md](./team-handoff.md)).
- Cross-links: [complytime/org-infra#211](https://github.com/complytime/org-infra/pull/211),
  [complytime-policies#5](https://github.com/complytime/complytime-policies/issues/5),
  [org-infra 008](https://github.com/complytime/org-infra/blob/main/specs/008-quay-promote-signature-verification/spec.md),
  [oci-artifact 002](https://github.com/complytime/oci-artifact/blob/main/specs/002-gemara-oci-supply-chain-e2e/spec.md) (use fork or local clone if not on `complytime/oci-artifact` `main` yet).
- **Open questions** and **acceptance** for E2E/demo (registry behavior, not **001** FR text).

## Scope (out)

- Redefining **001** **FR-004** / **verify_signature** defaults (remains in **001**).
- Implementing org-infra workflow changes (tracked in **org-infra** **008** and PRs).

## Success criteria (this feature)

- [ ] Team can find **one** place in **complytime-policies** for Quay E2E + handoff (this directory).
- [ ] **org-infra** **008** and **oci-artifact** **002** are linked and kept in sync when promote design lands.
- [ ] When **complytime/org-infra** `main` matches the validated reusable set, **README** **FR-006**
  migration (org-infra-tests → org-infra) is executed per **001** **SC-004** / **FR-006**, not here.

## References

- [research.md](./research.md) — Quay dest verify, `oras copy -r`, empty layers, tooling split.
- [team-handoff.md](./team-handoff.md) — briefing for reviews and ideation.
- [plan.md](./plan.md) — implementation handoff and dependencies.
