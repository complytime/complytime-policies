# Implementation Plan: Published policy OCI release pipeline (content + thin workflow)

**Branch**: `001-policy-oci-publish` | **Date**: 2026-04-22 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-policy-oci-publish/spec.md` (includes **Clarifications** session 2026-04-22).

## Summary

Implement a **thin** `.github/workflows/publish-policy-oci.yml` pipeline over **`governance/`** and **`bundles/`** Gemara YAML: checkout (default branch) → pinned **composite publish action** → **GHCR** staging → **`workflow_call`** **`complytime/org-infra`** [`.github/workflows/resuable_publish_quay.yml`](https://github.com/complytime/org-infra/blob/main/.github/workflows/resuable_publish_quay.yml) → **`quay.io/continuouscompliance/complytime-policies`**. **v1** norms (spec + clarifications): **`workflow_dispatch` only**; workflow **`concurrency`** for overlapping runs (document **group** + **`cancel-in-progress`** in **`README.md`**); promote **`verify_signature: true`** unless org-documented exception (scope + sunset). Document pins (**FR-006**), secrets (**FR-007**), consumers (**FR-005**). See **`research.md`** §§1–7 for decisions.

## Technical Context

**Language/Version**: Gemara YAML; CI **`ubuntu-latest`**; composite action uses internal **Go 1.25.x** (not this repo’s module).  
**Primary Dependencies**: **GitHub Actions**; **Publish Gemara OCI bundle** composite (e.g. **`complytime/oci-artifact`** / interim SHA); **`complytime/org-infra`** promote reusable workflow; **crane/cosign** inside org workflow.  
**Storage**: N/A; **OCI** on **GHCR** + **Quay**.  
**Testing**: Manual **E2E** (**SC-003**).  
**Target Platform**: **GitHub-hosted** `ubuntu-latest`.  
**Project Type**: **Policy repository** + **CI integration**.  
**Performance Goals**: Within org promote timeout (~**15 min**).  
**Constraints**: **FR-002** (dispatch-only **v1**, **`concurrency`**, publish-matrix docs); **FR-003**/**FR-004** (thin caller, **`verify_signature: true`** default); **FR-006**–**FR-008**; **Apache-2.0** / **AGENTS.md**; no secrets in git.  
**Scale/Scope**: One public image; start **one** **`file:`** root; document matrix expansion.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **Gemara and ecosystem fit**: Caller passes paths; validation stays SDK/action + merge-time checks.
- [x] **Traceability and reviewability**: Small workflow + doc diffs; SHA-pinned **`uses:`**.
- [x] **Testable requirements**: Green run + digests + docs match **SC-001**–**SC-004**.
- [x] **Release and consumer impact**: **v1** dispatch, concurrency, verify defaults; consumer docs (**FR-005**).
- [x] **Licensing and hygiene**: Secrets via GitHub only; minimal **`permissions`**.

### Constitution Check (post–Phase 1 design)

- [x] **`research.md`**, **`contracts/`**, **`data-model.md`**, **`quickstart.md`** align with spec clarifications.

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
├── catalogs/
└── policies/
bundles/
.github/workflows/          # publish-policy-oci.yml (add)
README.md
```

**Structure Decision**: Policy content under **`governance/`** / **`bundles/`**; automation under **`.github/workflows/`**; no duplicate OCI contract in-tree.

## Complexity Tracking

> No constitution violations requiring justification.

## Phase outputs (this plan command)

| Phase | Artifact | Status |
|-------|-----------|--------|
| 0 | `research.md` | Current — no **NEEDS CLARIFICATION** |
| 1 | `data-model.md`, `contracts/publish-pipeline.md`, `quickstart.md` | Current — aligned with **FR-002**/**FR-004** |
| 2 | `tasks.md` | Maintained via **`/speckit.tasks`**; see `specs/001-policy-oci-publish/tasks.md` |

**Agent context**: `.cursor/rules/specify-rules.mdc` → plan + siblings under `specs/001-policy-oci-publish/`.
