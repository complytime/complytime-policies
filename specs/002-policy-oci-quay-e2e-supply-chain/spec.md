# Feature specification: Policy OCI — Quay E2E, supply chain handoff, and promote/verify

**Feature ID:** `002-policy-oci-quay-e2e-supply-chain`  
**Created:** 2026-04-23  
**Status:** Draft  
**Relates to:** [001-policy-oci-publish](../001-policy-oci-publish/spec.md) (thin caller and FR-001–FR-008 **unchanged** by this feature)

## Purpose

Capture **operational and design** work that does **not** modify the [001](./../001-policy-oci-publish/spec.md)
product spec: end-to-end validation and handoff of **complytime-policies → GHCR → sign → Quay**
including **destination `cosign verify`**, how promotion copies images and cosign **referrers** to
Quay (**cosign copy** vs **`oras copy -r`** — see **org-infra** **008**), and Quay **UI** vs **CLI**
for Gemara OCI bundles.

**Not** “test-mirror only”: the **test mirror** ([org-infra-tests](https://github.com/sonupreetam/org-infra-tests))
is documented as an **interim** way to pin **`workflow_call`** SHAs and run **`allow_unprotected_ref`**
on forks while **complytime/org-infra** `main` catches up. The same **002** narrative applies when
callers use **`complytime/org-infra@<sha>`** in production: Quay **dest** verify, pin migration
(**001** **FR-006** / **README**), and cross-repo links are in scope; only the **mirror** is
temporary.

[001](../001-policy-oci-publish/spec.md) remains the **v1** product requirements; **002** is the
**handoff** / coordination spec for the Quay leg and registry edge cases.

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
