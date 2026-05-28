# Implementation Plan: Published policy OCI release pipeline (content + thin workflow)

**Branch**: `001-policy-oci-publish` | **Date**: 2026-04-22 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-policy-oci-publish/spec.md` (includes **Clarifications** sessions 2026-04-22, 2026-04-27, 2026-04-28, and 2026-04-29).

## Summary

Implement a **thin** `.github/workflows/publish-policy-oci.yml` over **`governance/`** and **`bundles/`** Gemara YAML: checkout (default branch) → one pinned **composite** ([`gemaraproj/gemara-registry-cli`](https://github.com/gemaraproj/gemara-registry-cli) per **FR-006**) that does **GHCR** staging **and** ORAS **promote to** **`quay.io/…`** in the same `uses:`. A separate **`workflow_call`** to [org-infra **`resuable_publish_quay.yml`**](https://github.com/complytime/org-infra/blob/main/.github/workflows/resuable_publish_quay.yml) is **no longer a convergence target** (Session 2026-05-04); the composite is the accepted production path. Historical reference (see spec **Session 2026-04-27** / [PR #19](https://github.com/complytime/complytime-policies/pull/19)) — not a second job in the current “Option 3” implementer path. **v1** norms: **`workflow_dispatch` only**; workflow **`concurrency`**; default **`resign` +** destination verify in CI; tag-exists guard (`oras resolve`) before publish. Document pins (**FR-006**), secrets (**FR-007**), consumers (**FR-005**). See **`research.md`** for historical `workflow_call` design notes.

## Technical Context

**Language/Version**: Gemara YAML; CI **`ubuntu-latest`**; composite action uses internal **Go** (version per action `action.yml` / `setup-go`, not this repo’s module).  
**Primary Dependencies**: **GitHub Actions**; one pinned **composite** that runs pack/push, optional **cosign**, and ORAS promote to Quay; **id-token** for keyless where enabled. The composite ([`gemaraproj/gemara-registry-cli`](https://github.com/gemaraproj/gemara-registry-cli)) is the **accepted production path** (Session 2026-05-04); org-infra `workflow_call` is not required. **research.md** still describes the historical two-job + promote shape.  
**Storage**: N/A; **OCI** on **GHCR** + **Quay**.  
**Testing**: Manual **E2E** (**SC-003**), task **T019**.  
**Target Platform**: **GitHub-hosted** `ubuntu-latest`.  
**Project Type**: **Policy repository** + **CI integration**.  
**Performance Goals**: Within a single workflow job timeout (align with org promote expectations, ~**15 min** as ballpark).  
**Constraints**: **FR-002** (dispatch-only **v1**, **`concurrency`**, publish-matrix docs); **FR-003**/**FR-004** (thin caller; composite as accepted production path per **Session 2026-05-04**; verify defaults per **Session 2026-04-27**); **FR-006**–**FR-008**; **Apache-2.0** / **AGENTS.md**; no secrets in git.  
**Scale/Scope**: One public image; start **one** **`file:`** root; document matrix expansion.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Gemara and ecosystem fit**: Caller passes paths; validation stays SDK/action + merge-time checks.
- [x] **Traceability and reviewability**: Small workflow + doc diffs; SHA-pinned **`uses:`**.
- [x] **Testable requirements**: **SC-001**–**SC-002** and **SC-004** satisfied by static alignment + **green** `workflow_dispatch` (see **T021**); full **SC-003** (run evidence in `quickstart.md` **“Verified E2E (optional)”**) is gated by open **T019** per **tasks.md** Phase 6.
- [x] **Release and consumer impact**: **v1** dispatch, concurrency, verify defaults; consumer docs (**FR-005**).
- [x] **Licensing and hygiene**: Secrets via GitHub only; minimal **`permissions`**.

### Constitution Check (post–Phase 1 design)

- [x] **`contracts/`**, **`quickstart.md`**, **`spec.md`** align with **Clarifications**. **`research.md`** / **`data-model.md`**: historical; superseded for workflow shape by **PR #19** (single composite) unless revisited.

## Project Structure

### Documentation (this feature)

```text
specs/001-policy-oci-publish/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source code (repository root)

```text
governance/
├── controls/
├── guidance/
└── policies/
bundles/
.github/workflows/          # publish-policy-oci.yml
README.md
```

**Structure Decision**: Policy content under **`governance/`** / **`bundles/`**; automation under **`.github/workflows/`**; no duplicate OCI contract in-tree.

## Complexity Tracking

> No constitution violations requiring justification.

## Phase outputs (this plan command)

| Phase | Artifact | Status |
|-------|-----------|--------|
| 0 | `research.md` | Historical — `workflow_call` to org-infra is the **pre–Option-3** research; composite is now the accepted path (Session 2026-05-04). |
| 1 | `data-model.md`, `contracts/publish-pipeline.md`, `quickstart.md` | **contracts** / **quickstart** aligned with **Session 2026-05-04** and `gemaraproj/gemara-registry-cli` pin; **data-model** may still show promote as a node — treat **contracts** as source of truth for the caller. |
| 2 | `tasks.md` | Maintained via **`/speckit.tasks`**; see `specs/001-policy-oci-publish/tasks.md` |

**Agent context**: `.cursor/rules/specify-rules.mdc` → plan + siblings under `specs/001-policy-oci-publish/`.
