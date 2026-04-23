# Research: Quay E2E, destination verify, Gemara “empty layers” (002)

**Feature:** [spec.md](./spec.md) | **Base pipeline spec:** [001 spec](../001-policy-oci-publish/spec.md)

## 1. E2E path under test

Staging on **GHCR** → **keyless sign** + verify → **promote** to test **Quay** with
**`resuable_publish_quay`** and **`verify_signature: true`**. The org pattern runs **`cosign verify`**
on **source** and **destination** by digest when verification is on.

## 2. Failure mode observed (Quay + cosign copy)

In some runs, **destination** `cosign verify` returned **“no signatures found”** even though
**source** verify passed and **`cosign copy`** (plus **`cosign copy --only=sig,att,sbom`**) had been
used. A **passing** run in a public test mirror used **`oras copy -r`**, which copies the image
**and** referring artifacts so material lands in a form **`cosign verify`** can resolve on **Quay**.

**Design owner:** [complytime/org-infra `specs/008-quay-promote-signature-verification`](https://github.com/complytime/org-infra/blob/main/specs/008-quay-promote-signature-verification/spec.md).
This repository (**complytime-policies**) only **pins** the org-infra SHA in the caller workflow; it
does not define the copy implementation.

## 3. “Empty” layers in the Quay UI

**Gemara** publish (**go-gemara** `Pack` + **`oras.Copy`**) is an **OCI bundle** layout, not a
classic **Docker** multi-layer rootfs. Quay’s **layer**-oriented UI may look **empty** or minimal
while **`crane manifest`**, **`cosign verify`**, and digest pulls succeed. **Do not** use the web
**layers** view alone as an acceptance test.

## 4. Tooling split (ideation for org policy)

- **Cosign** for the **verifiable subject** (signed digest) and objects in the **cosign** graph
  that **`cosign verify`** and CI must resolve.
- **ORAS** / **crane** for OCI **outside** that graph (side SPDX repos, alternate artifact names,
  non-subject blobs) when agreed.
- **Promotion GHCR → Quay** is a **special** copy: must keep **downstream** `cosign verify`
  working; options (cosign-only vs **`oras copy -r`**) live under **org-infra** **008**.

## 5. Interim mirror (org-infra-tests)

A public **test mirror** may be used so **`workflow_call`** SHAs resolve and
**`allow_unprotected_ref`** is consistent across reusables while **complytime/org-infra** `main`
catches up. **Retire** the mirror when pins and behavior are **at parity** with org-infra
(**001** **FR-006** / **README**).

**Team handoff and asks:** [team-handoff.md](./team-handoff.md).
