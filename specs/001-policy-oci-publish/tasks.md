---
description: "Task list for Published policy OCI release pipeline (001-policy-oci-publish)"
---

# Tasks: Published policy OCI release pipeline

**Input**: Design documents from `/specs/001-policy-oci-publish/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`  
**Tests**: Omitted — spec does not require automated tests; validation is manual **E2E** (**SC-003**).

**Organization**: Phases follow **US1** (P1), **US2** (P2), **US3** (P3) in `specs/001-policy-oci-publish/spec.md`. **v1** norms: **`workflow_dispatch` only** (**FR-002**); workflow **`concurrency`**; destination verification for trust (**FR-004**): **interim** = composite `verify_quay` / `trust_mode` per **Session 2026-04-27**; **convergence** = org **`resuable_publish_quay`** `verify_signature` (see **research.md** for that design).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Parallelizable (different files, no blocking dependency on incomplete tasks in this list).
- **[USn]**: User story label (story phases only).

## Path conventions

- Content: `governance/`, `bundles/`
- Workflow: `.github/workflows/publish-policy-oci.yml`
- Docs: `README.md`, `specs/001-policy-oci-publish/quickstart.md`

---

## Phase 1: Setup (shared infrastructure)

**Purpose**: Reader-facing entry points.

- [X] T001 Add publish pipeline overview (thin caller, staging → Quay, links to `specs/001-policy-oci-publish/spec.md` and **Clarifications**) to `README.md`
- [X] T002 Add publish path matrix (`governance/`, `bundles/`; excluded-path examples) to `README.md`

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: Org alignment, pins, and matrix docs before workflow merge.

**⚠️ CRITICAL**: Complete **T003**–**T008** before **US1** workflow implementation.

- [X] T003 **(satisfied by interim spec):** **FR-004** promote verification is covered by **Session 2026-04-27** (composite + `verify_quay`) and **Session 2026-04-22** Q2 for a **future** literal org **`workflow_call`**. A separate org-infra sign-off is **not** required to merge Option 3; track **convergence** in `README` / spec. Add a **documented exception** in `research.md` §5 only if maintainers agree to **turn off** destination verify.
- [X] T004 Add **FR-006** pin documentation to `README.md`: **required** full SHA of the **composite** `uses:`; **org-infra** `resuable_publish_quay.yml` **SHA** is **N/A** for **Option 3** (promote inside the action) and **MUST** be added when the caller switches to that **`workflow_call`**
- [X] T005 Document required GitHub **secret names** and token scopes for GHCR push and Quay promote (no values) in `README.md` per **FR-007** (`specs/001-policy-oci-publish/spec.md`)
- [X] T006 Document the first primary Gemara root YAML **`file:`** path (for example `bundles/cis-fedora-l1-workstation.yaml`) and future matrix expansion in `README.md` per `specs/001-policy-oci-publish/research.md` §6
- [X] T007 Document **v1** **`workflow_dispatch` only**, **`concurrency`**, and overlapping-dispatch policy in `README.md`; for **`fail_if_dest_exists`** / unique **`dest_tag`**: **Option 3** does **not** plumb org promote inputs through this repo—document that distinction and point to `README` + **Edge Cases** in `specs/001-policy-oci-publish/spec.md` (satisfied in [`quickstart.md`](quickstart.md) **What “thin” means** — *Overlapping runs* / promote inputs)
- [X] T008 Add `README.md` subsection on **who may run** **`workflow_dispatch`** and optional **GitHub Environment** gating for production (fill per org/repo policy; aligns with **FR-002** default-branch scope) — **satisfied** in [`quickstart.md`](quickstart.md) (**Who can run** under **What “thin” means**; root [README **Releasing**](../README.md#releasing) is the lean pointer)

**Checkpoint**: Foundation documented.

---

## Phase 3: User Story 1 — Controlled releases (Priority: P1) 🎯 MVP

**Goal**: **`workflow_dispatch`** publishes default-branch aggregate content to GHCR then public Quay.

**Independent Test**: On default branch with secrets, run dispatch and confirm GHCR + Quay tag/digest for documented **`file:`** (**SC-001**, **FR-002**).

### Implementation for User Story 1

*Supersedes 2026-04-27 ([PR #19](https://github.com/complytime/complytime-policies/pull/19)):* **T011**–**T012** are satisfied by a **single** `uses:` of the composite: promote (ORAS copy) runs **inside** the action, not a second workflow job. Convergence to a separate org-infra `workflow_call` is tracked in spec **FR-004** (interim) / Session 2026-04-27.

- [X] T009 [US1] Create `.github/workflows/publish-policy-oci.yml` with **`on.workflow_dispatch` only** for **v1**, top-level **`concurrency`** per **FR-002**, and inputs matching `README.md` and `specs/001-policy-oci-publish/spec.md`
- [X] T010 [US1] Add checkout of the **repository default branch** (policy content scope per **FR-002**) and GHCR **publish** job with pinned composite `uses:` in `.github/workflows/publish-policy-oci.yml` per `specs/001-policy-oci-publish/contracts/publish-pipeline.md`
- [X] T011 [US1] **(shape superseded):** *Originally:* promote job with `complytime/org-infra/.../resuable_publish_quay.yml`. *As shipped:* promote is **inside** the composite; destination verify via `verify_quay` and action inputs per **FR-004** interim + `contracts/publish-pipeline.md`
- [X] T012 [US1] Set minimal `permissions` in `.github/workflows/publish-policy-oci.yml` and consistent `tag` / `dest` mapping; no `needs:` between publish and promote (single job)

**Checkpoint**: **US1** MVP complete.

---

## Phase 4: User Story 2 — Supply chain trust (Priority: P2)

**Goal**: Operators see **cosign verify** on promote and org-standard promotion; no silent skipping of agreed checks.

**Independent Test**: Logs show promote + destination verify (composite **`verify_quay`**) and signing posture per **trust_mode**; org **`verify_signature: true`** on **resuable_publish_quay** applies after **FR-004** convergence unless **T003** exception is documented (**User Story 2**, **FR-008**).

### Implementation for User Story 2

- [X] T013 [US2] **(superseded shape):** Wire `allowed_identity_regex` and other composite inputs (e.g. `verify_destination` / `verify_quay` mapping) in `.github/workflows/publish-policy-oci.yml`; *not* org-infra `workflow_call`-specific keys unless a future job calls that reusable
- [X] T014 [US2] Add operator checklist (verify steps, digests, failure modes) to `README.md` per **User Story 2** in `specs/001-policy-oci-publish/spec.md`
- [X] T015 [US2] **(N/A for current composite):** the pinned action does not expose a **`verify_vuln`/`verify_vulns`**-style input in this repo’s `with:` block. If **FR-008** / org later requires vulnerability gates, add only **supported** action inputs and document in `README.md` — *no* silent skips.

**Checkpoint**: **US2** satisfied.

---

## Phase 5: User Story 3 — Consumer clarity (Priority: P3)

**Goal**: External readers fetch and verify using repo docs only.

**Independent Test**: Follow `README.md` / `specs/001-policy-oci-publish/quickstart.md` using a dispatch release’s registry tag or digest (**SC-002**).

### Implementation for User Story 3

- [X] T016 [US3] Add consumer fetch/verify steps to `specs/001-policy-oci-publish/quickstart.md` and add a Consumers pointer in `README.md` per **FR-005**
- [X] T017 [US3] Ensure `README.md` examples use live registry refs or explicit **placeholder** labels per **User Story 3** in `specs/001-policy-oci-publish/spec.md`

**Checkpoint**: **US3** documentation matches workflow behavior.

---

## Phase 6: Polish & cross-cutting concerns

**Purpose**: E2E evidence, migration tracking, spec alignment.

- [X] T018 [P] Add migration tracking link or instruction for retiring interim composite-action pin in `README.md` per **FR-006** / **SC-004**
- [ ] T019 Run **SC-003** end-to-end (`workflow_dispatch` → staging → promote → verify) and add digest/tag or log pointers under **“Verified E2E (optional)”** in `specs/001-policy-oci-publish/quickstart.md` (or briefly in root `README` if maintainers prefer) — **blocks** declaring the epic “done” for consumers
- [X] T020 [P] Reconcile `specs/001-policy-oci-publish/quickstart.md` with final `.github/workflows/publish-policy-oci.yml` inputs and job names
- [X] T021 [P] **Static** alignment: `spec.md` / `contracts/` / `README` / `quickstart` describe the same **Option 3** **inputs`, **defaults**, and **pin** as `.github/workflows/publish-policy-oci.yml`. Does **not** satisfy **SC-003** (see **T019**)

---

## Dependencies & execution order

### Phase dependencies

- **Phase 1** → **Phase 2** → **Phase 3** → **Phases 4–5** (can overlap after **T012**) → **Phase 6**

### User story dependencies

- **US1** depends on **Phase 2**.
- **US2** depends on **T009**–**T012**; **T013** depends on **T003**.
- **US3** depends on **US1**; **T017** may follow **T019** for live examples.

### Within **US1**

- **T009** → **T010** → **T011** → **T012** (same workflow file — serialize).

### Parallel opportunities

- **T018** (`README.md`) and **T020** (`specs/001-policy-oci-publish/quickstart.md`) in **Phase 6** after workflow is stable.

### Parallel example: Phase 6

```text
T018: migration tracking in README.md
T020: quickstart.md vs publish-policy-oci.yml
```

---

## Implementation strategy

### MVP

1. **Phases 1–2** (**T001**–**T008**).  
2. **Phase 3** (**T009**–**T012**).  
3. Run **T019** before declaring production-ready.

### Incremental delivery

**US1** → **US2** → **US3** → **Phase 6**.

---

## Task summary

| Metric | Count |
|--------|-------|
| **Total** | **21** |
| **Phase 1** | 2 |
| **Phase 2** | 6 |
| **US1** | 4 |
| **US2** | 3 |
| **US3** | 2 |
| **Phase 6** | 4 |

**Format validation**: Tasks use `- [ ]` or `- [X]` with `Tnnn` and file paths; **[USn]** only Phases 3–5; **[P]** on **T018** and **T020** only.
