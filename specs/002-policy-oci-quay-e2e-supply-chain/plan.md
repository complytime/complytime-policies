# Plan: Quay E2E supply chain handoff (002)

**Spec:** [spec.md](./spec.md) | **Prerequisite product spec:** [001 plan](../001-policy-oci-publish/plan.md) (unchanged by this work)

## Objective

Record and drive to closure: **green E2E** of policy OCI to **test Quay** with **dest**
**`cosign verify`**, and align **pins** with **complytime/org-infra** `main` when reusables match the
validated behavior.

## Dependencies (external)

- **org-infra:** [008](https://github.com/complytime/org-infra/blob/main/specs/008-quay-promote-signature-verification/spec.md) — `resuable_publish_quay` **copy** semantics and tests.
- **org-infra PRs** (e.g. [211](https://github.com/complytime/org-infra/pull/211)) landing Gemara/Quay
  reusables as reviewed.

## Phases

1. **E2E evidence** — Keep a **passing** run log (fork + **org-infra-tests** pin or **org-infra** SHA
   once merged) for demo.
2. **Pin migration** — Update [README.md](../../README.md) **FR-006** table: **org-infra-tests** →
   `complytime/org-infra@<sha>` per **001** when parity is agreed.
3. **Close 002** — Set **002** [spec.md](./spec.md) **Status** to **Superseded** or **Complete** when
   team agrees handoff is captured and **008** is implemented on `main`.

## Non-goals

- Editing [001 spec](../001-policy-oci-publish/spec.md) for this handoff; **001** stays the v1
  product requirements set.
