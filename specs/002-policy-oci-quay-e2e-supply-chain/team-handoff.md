# Team handoff: OCI policy publish (complytime-policies → Quay)

**Spec:** [spec.md](./spec.md) | **Research:** [research.md](./research.md)  
**Normative v1 requirements** remain in [001-policy-oci-publish](../001-policy-oci-publish/spec.md).

## Responsibility split

| Layer | Role |
|--------|------|
| **go-gemara** | Bundle → OCI contract ([go-gemara#62](https://github.com/gemaraproj/go-gemara/pull/62)). |
| **gemara-publish-oci / oci-artifact** | Pack + push in CI (`bundle.Pack` + `oras.Copy`). See **oci-artifact** [002](https://github.com/complytime/oci-artifact/blob/main/specs/002-gemara-oci-supply-chain-e2e/spec.md). |
| **complytime/org-infra** | `workflow_call` reusables + composite + GHCR / attest / sign / Quay ([org-infra#211](https://github.com/complytime/org-infra/pull/211)). |
| **complytime-policies** | Thin caller: [`.github/workflows/publish-policy-oci.yml`](../../.github/workflows/publish-policy-oci.yml). Architecture: [#5](https://github.com/complytime/complytime-policies/issues/5). |

## Current reality (2026-04)

- This **002** spec covers the **Quay E2E / promote / verify** story for **any** org-infra pin
  (production or interim). The **org-infra-tests** entry below is only the **interim** pin path.
- **org-infra-tests** (public mirror) used while upstream **main** and **pins** align; retire at parity
  with [complytime/org-infra](https://github.com/complytime/org-infra).
- **Forks:** **`allow_unprotected_ref: true`** on publishing/sign jobs as required by org reusables.
- **Quay dest verify:** Stock **`cosign copy` + `cosign copy --only=…`** did not always pass **Verify
  destination signature**; **`oras copy -r`** worked in a green E2E—decision in **org-infra**
  [008](https://github.com/complytime/org-infra/blob/main/specs/008-quay-promote-signature-verification/spec.md). May **delay demo** until merged and pinned.
- **Quay UI** may show odd/empty “layers” for Gemara OCI; use **CLI**—see [research.md](./research.md) §3.

## Open questions

1. **Empty layers in Quay** — confirm with **`crane`** / **`oras`**, not UI only.
2. **cosign graph vs oras** for out-of-graph artifacts — see [research.md](./research.md) §4.
3. **SBOM / vulnerability attestation** expectations vs Quay+verify path — ideation in **org-infra** **008**
   and downstream policy.

## Ask to the team

1. Review the **cosign graph vs oras/crane** split; object if policy publish should **not** use this
   chain.
2. Watch [org-infra#211](https://github.com/complytime/org-infra/pull/211) and
   [complytime-policies#5](https://github.com/complytime/complytime-policies/issues/5) as architecture
   SSOT; add Quay **oras** changes to the agreed PR.
3. Review **complytime-policies** PRs for **thin-caller** + **FR-006** when moving pins **org-infra-tests
   → org-infra**.

## Capturing this work

| Repo | Location |
|------|----------|
| **complytime-policies** | This directory [002](.) |
| **oci-artifact** | [002-gemara-oci-supply-chain-e2e](https://github.com/complytime/oci-artifact/blob/main/specs/002-gemara-oci-supply-chain-e2e/spec.md) (path after merge) |
| **org-infra** | [008](https://github.com/complytime/org-infra/blob/main/specs/008-quay-promote-signature-verification/spec.md) |
