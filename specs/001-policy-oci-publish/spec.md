# Feature Specification: Published policy OCI release pipeline

**Feature Branch**: `001-policy-oci-publish`  
**Created**: 2026-04-22  
**Status**: Draft (implementation: **Option 3**; **SC-003** run evidence: `specs/001-policy-oci-publish/quickstart.md` **“Verified E2E (optional)”**; open **T019** in `tasks.md`)  
**Input**: User description: "Publish Gemara policy bundles and governance content as OCI artifacts: automated, controlled release to the public registry (not required on every merge to publishable paths), organization staging registries, signing and attestation, promotion to the public ComplyTime registry. Repository provides source content and a thin release caller; artifact contract and transport are defined by the SDK and shared org automation. Document how consumers obtain and verify published policy artifacts. Aligns with GitHub issue 5 and sub-issues 7-9."

## Clarifications

### Session 2026-04-22

- Q: What is the canonical **v1** intentional release trigger for the publish pipeline? → A: **`workflow_dispatch` only** for v1 (registry version/tag strings supplied via documented workflow inputs). Tag-push or other triggers may be added later with explicit precedence rules in publish documentation.
- Q: For **v1**, what is the default **`verify_signature`** posture for the publish pipeline? → A: **Default strict:** cosign sign and verify MUST be enabled on both source and destination (`sign_source: true`, `verify_source: true`, `sign_destination: true`). A bypass is allowed **only** with an **explicit org-documented agreement** (not as a silent operational default). *Updated in Session 2026-05-04: the composite action handles signing directly; no separate org-infra `workflow_call` is required.*
- Q: For **v1**, how should **overlapping** **`workflow_dispatch`** runs be handled? → A: **GitHub Actions `concurrency`** at workflow scope (documented group key and **`cancel-in-progress`** policy in publish docs), **plus** registry immutability checks (for example **`fail_if_dest_exists`**) as applicable.

### Session 2026-04-27 (PR #19: thin composite caller)

- Q: **FR-004** requires a **`workflow_call`** to org-infra **`resuable_publish_quay.yml`**. The implemented workflow uses one pinned **composite** (`gemaraproj/gemara-registry-cli@…`; previously `sonupreetam/gemara-publish-oci` which is now superseded) that embeds GHCR publish, optional cosign, and ORAS copy to Quay. Does that satisfy the spec? → A: **Yes.** The composite is the accepted publish and promotion mechanism: it performs **staging → public** promotion with keyless cosign sign/verify in one auditable `uses:` per **FR-006**. *Updated in Session 2026-05-04: the composite is the production path; no convergence to org-infra `workflow_call` is required.*
- Q: What are the default **signing / verify** values for the published workflow? → A: **`trust_mode: resign`**, **`verify_quay: true`** (destination `cosign verify` in CI when promote runs), with source and destination sign/verify enabled (`sign_source: true`, `verify_source: true`, `sign_destination: true` as of Session 2026-05-04). This supersedes an earlier “copy-only, all verify off” demo description.
- Q: Where is the **input and secret contract** for the thin caller? → A: [contracts/publish-pipeline.md](contracts/publish-pipeline.md) and the workflow file; keep them in sync when pins or `with:` change.

### Session 2026-04-28 (SpecKit `/speckit-clarify`)

- Q: The **001-policy-oci-publish** feature branch trailed this PR; should it be fully reconciled with the **Option 3** / **PR #19** spec set? → A: **Yes** — branch `001-policy-oci-publish` carries the full `specs/001-policy-oci-publish/`, `contracts/`, and **README** layout; for SpecKit **`.specify/scripts/bash/check-prerequisites.sh`**, check out a **`001-*` feature branch** (this feature) instead of a `feat/...` work branch, or the script will not return **FEATURE_SPEC**.

### Session 2026-04-29 (SpecKit `/speckit-clarify`)

- Q: Should **001-policy-oci-publish** treat **only** this SpecKit tree (`specs/001-policy-oci-publish/`) as the feature spec source, and **not** `openspec/changes/...`? → A: **Yes** — do not merge or maintain **OpenSpec** change folders on this branch; **SpecKit** spec/plan/tasks/contracts are authoritative. Other branches may use OpenSpec experimentally; keep **001-** free of it to avoid duplicate/conflicting spec surfaces.

### Session 2026-05-04 (composite as accepted production path)

- Q: **FR-004** previously described the composite action as **interim** with a **convergence target** of a literal `workflow_call` to org-infra's `resuable_publish_quay.yml`. The composite now handles publish + keyless cosign sign/verify on source and destination + registry-agnostic promotion in a single atomic `uses:`, verified E2E with full signing (runs [25314153282](https://github.com/sonupreetam/complytime-policies/actions/runs/25314153282) and [25314721510](https://github.com/sonupreetam/complytime-policies/actions/runs/25314721510)). Is the composite the accepted production path? → A: **Yes.** The pinned composite action is the **accepted** publish and promotion mechanism for this artifact class. A separate `workflow_call` to `resuable_publish_quay.yml` is **not required** and is no longer a convergence target. The composite provides: (1) single atomic unit with no multi-job coordination, (2) registry-agnostic `destination_*` inputs, (3) keyless cosign on both source and destination, (4) simpler caller contract. The org-infra reusable was designed for container-oriented flows and is not the right fit for Gemara bundle artifacts. **FR-004** is updated to reflect this.
- Q: What are the production **signing defaults**? → A: `sign_source: true`, `verify_source: true`, `sign_destination: true`, `verify_destination` gated by `verify_quay` dispatch input (default `true`). `trust_mode: resign` remains the default.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintainers get reliable, automatable releases of policy content (Priority: P1)

ComplyTime maintainers land vetted changes to policy bundles and governance files on the default branch, often across multiple pull requests for one logical update. They need a **controlled release**—not a separate registry publication on every individual merge to publishable paths—so incomplete series of changes are not each promoted as if they were finished releases, while still being able to produce a consistent, signable, promoted release to the organization’s public registry when the work is ready.

**Why this priority**: Without a predictable, automatable way to cut a release when content is complete, policy updates do not reach consumers in a coordinated way; conversely, publishing on every small merge fragments consumers’ version expectations and can ship partial updates.

**Independent Test**: Can be fully tested by landing allowed changes to publishable content on the default branch, then triggering (or simulating) a **`workflow_dispatch`** release as defined in this spec (**v1**), and confirming that a publish run completes and the resulting release is available from the public registry (with appropriate credentials where required).

**Acceptance Scenarios**:

1. **Given** publishable content under `governance/` and any designated bundle paths (for example `bundles/`) and required registry access configured, **When** a maintainer runs the documented **`workflow_dispatch`** release for the current default branch state (**v1**), **Then** a release pipeline runs to completion and artifacts appear at the public ComplyTime registry for that repository’s scope, reflecting the **aggregate** of publishable content at that point in time.
2. **Given** the same content layout, **When** a merge to the default branch only touches non-publishable files (for example documentation-only paths excluded from the publish matrix), **Then** the release trigger behavior matches the defined policy (for example no unplanned full publish; integration checks only as documented).
3. **Given** multiple merges land on the default branch in sequence, **When** a single release is cut after those merges, **Then** the published outcome corresponds to one coherent release, not a mandatory publish per merge unless the project explicitly documents that model for a path class.

---

### User Story 2 - Operators can trust the supply chain for published policy (Priority: P2)

Security and platform operators need published policy artifacts to follow the same staging, signing, and promotion practices as other ComplyTime releases so attestations and provenance are consistent.

**Why this priority**: Reduces org risk and supports audits; secondary to “something is published at all” (P1).

**Independent Test**: Can be tested by reviewing pipeline outputs and attestation material for a successful run and confirming the promotion path matches the organization’s **intent** (staging → **cosign verify** on destination when enabled → public Quay). For **v1** as implemented (**Session 2026-04-27**), verification is the composite’s **`verify_quay`** (destination) path; the composite action is the accepted production path (Session 2026-05-04).

**Acceptance Scenarios**:

1. **Given** a successful release run, **When** an operator reviews the run’s outputs, **Then** signing/verification steps and promotion to the public registry are present. Keyless cosign sign/verify is enabled on both source and destination per Session 2026-05-04 defaults.
2. **Given** optional vulnerability-related checks the organization allows for this artifact class, **When** those checks are enabled, **Then** failed checks block promotion according to the agreed policy.

---

### User Story 3 - Consumers can discover, fetch, and verify published policy (Priority: P3)

Engineers and automation that consume ComplyTime policies need clear instructions: where releases live, how to reference a version, and how to confirm integrity without reading internal pipeline code.

**Why this priority**: Consumer documentation closes the loop after publication exists; it can follow initial pipeline delivery if necessary.

**Independent Test**: A new user can follow only repository documentation to fetch and verify a published policy artifact for a known release.

**Acceptance Scenarios**:

1. **Given** a released version exists in the public registry, **When** a reader follows the documented steps, **Then** they can retrieve that version and perform the documented integrity checks.
2. **Given** the documentation references examples, **When** a release is finalized, **Then** examples use real registry locations and version references that match the implemented pipeline (or are explicitly labeled as placeholders until a stable release pin exists).

### Edge Cases

- **Upstream contract in flux**: The canonical artifact layout and transport semantics are defined outside this repository; if they change during implementation, the caller automation must remain aligned with the agreed contract and must not define a second, competing layout in-repo.
- **Registry or secret misconfiguration**: Failed authentication or mis-set promotion targets should fail the pipeline with a clear, actionable error without writing partial state to the public registry.
- **Back-to-back merges before a release**: Multiple consecutive merges to the default branch may accumulate; the release process MUST define when a new published version is created (for example one per explicit **`workflow_dispatch`**). **Overlapping dispatches** for **v1** MUST be controlled with workflow-level **`concurrency`** (see **FR-002** and **Clarifications**) and documented **`cancel-in-progress`** behavior; registry-level immutability (for example **`fail_if_dest_exists`** on promote) remains complementary.
- **No credentials / dry environments**: Documentation or process notes for forks or local validation should not require embedding secrets; credential setup is tracked as a separate operational task.
- **Upstream action location**: The composite action now lives at [`gemaraproj/gemara-registry-cli`](https://github.com/gemaraproj/gemara-registry-cli). The workflow is pinned to a branch SHA from PR #2 until a stable release tag is available. Per **FR-006**, the pin and migration status are documented in the workflow and `contracts/publish-pipeline.md`.
- **Promotion and signing shape**: The organization’s standard promote workflow (for example container-oriented **crane**/**cosign** flows) may assume a particular registry reference, signature, and tag model; the pack/push step MUST produce a **reference and attestations** that the chosen reusable workflow can consume, or the spec documents a **deliberate** exception (for example **`verify_signature: false`** only when agreed with **org-infra** and recorded in publish docs with scope and sunset). **v1** default remains **`verify_signature: true`** per **FR-004** and **Clarifications**.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST keep Gemara-governed content under `governance/` (including `governance/controls/` and `governance/policies/`) and any additional bundle root paths the maintainers document (for example `bundles/`) consistent with the repository constitution and schema validation in force at merge time.
- **FR-002**: For **v1**, a **release** SHALL mean a deliberate **`workflow_dispatch`** invocation of the repository’s publish workflow, with version or tag strings supplied via inputs documented in the publish matrix. Such a release whose scope includes the default branch state and publishable content MUST start a release pipeline whose successful outcome is published policy artifacts in the public ComplyTime namespace agreed for this repository, unless the publishable path set is empty by policy. The spec does **not** require a full public-registry publish on every merge to `governance/` or bundles. Additional non–`workflow_dispatch` triggers (for example semver tag push) MAY be introduced only when publish documentation defines **precedence** relative to **`workflow_dispatch`** so acceptance criteria stay unambiguous. For **v1**, the publish workflow MUST declare **`concurrency`** at workflow scope so overlapping **`workflow_dispatch`** runs are serialized or cancelled per policy; the publish matrix documentation MUST record the **concurrency group key** and the chosen **`cancel-in-progress`** (`true` or `false`) rationale.
- **FR-003**: The repository MUST provide a “caller”-style integration that delegates layout, transport, signing, and promotion to the language SDK and shared organization automation, without redefining the OCI media types, layer structure, or manifest contract in a second, divergent way.
- **FR-004**: The release process MUST use the organization’s standard staging, signing, attestation, and promotion flow for this artifact class, including a **staging** registry before the public ComplyTime **Quay** namespace. Promotion from staging to public MUST use a **pinned composite action** that performs staging publish, keyless cosign sign/verify on source and destination, and ORAS copy to the destination registry in one auditable `uses:` step. The composite is the **accepted** production mechanism for this artifact class (Session 2026-05-04). The pin and contract MUST be documented per **FR-006** and [contracts/publish-pipeline.md](contracts/publish-pipeline.md). Cosign sign and verify MUST be enabled on both source and destination; a bypass is allowed only with an explicit org agreement recorded in publish documentation.
- **FR-005**: Repository documentation MUST describe how external consumers find releases, how they reference a version, and how they verify what they pulled, in terms appropriate for the primary ComplyTime CLI or documented tooling where applicable.
- **FR-006**: The implementation MUST document, in the publish or release matrix documentation, **(a)** the **GitHub Action** reference (commit SHA, semver tag, or branch) used for **OCI pack and push to staging**, **(b)** whether that reference is **interim** (for example a branch SHA pin to [`gemaraproj/gemara-registry-cli`](https://github.com/gemaraproj/gemara-registry-cli) [PR #2](https://github.com/gemaraproj/gemara-registry-cli/pull/2) before a stable release tag exists) or **post-migration** (stable release on the org-owned repo), and **(c)** the **exit criteria** to move to a stable release tag under **gemaraproj** (or equivalent), at which time branch SHA pins are retired. The personal fork `sonupreetam/gemara-publish-oci` is superseded. This repository does not encode **go-gemara** `require`/`replace` for the action; the **SDK pin** remains inside the action’s `go.mod` as that upstream’s responsibility.
- **FR-007**: Operational access for publishing (robot accounts, token scopes) MUST be configured outside the git tree; the specification of required secret *names* and *scopes* MAY be documented without storing secret values in the repository.
- **FR-008**: If optional vulnerability or policy checks are used for this pipeline, their enable/disable behavior MUST match the organization’s reusable workflow contract (for example optional verify steps) and MUST NOT silently skip agreed blocking checks in production.

### Key Entities

- **Policy bundle**: A versioned set of related Gemara policy or catalog files living under a documented path (for example a directory under `bundles/`) that is included in the publish matrix.
- **Governance artifact**: Catalogs and policies under `governance/` that are subject to the same quality bar and may be part of a published OCI object as defined by the single upstream contract.
- **Published release**: A named or digest-addressable set of OCI objects in the public ComplyTime registry that corresponds to a given **release** event (and thus to the default-branch snapshot at that time), which may include the aggregate of several merges, consumable by downstream clients.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every **intentional release** (**v1**: **`workflow_dispatch`** per **FR-002**) whose content is in scope for publication, the release pipeline either completes with a success status and leaves retrievable artifacts in the public ComplyTime registry, or fails with a visible, attributable failure (no silent partial publish).
- **SC-002**: A reader who is new to this repository can, using only the usage documentation in this repository, complete one successful fetch and verification of a published release that the maintainers have labeled as “current” or by explicit version, within 30 minutes under normal network conditions.
- **SC-003**: At least one end-to-end demonstration runs in a representative environment (as defined with maintainers) showing default-branch content at release time → published artifact in **staging** (and, when applicable, **promoted** per **FR-004**) → consumer verification before the feature is marked done for the planning epic. A demonstration using **interim** action pins and pre-release **go-gemara** bundle APIs (as bundled inside that action) satisfies this criterion if labeled per **FR-006**.
- **SC-004**: Publish and release documentation explicitly states **interim** vs **post-migration** upstream **action** and **go-gemara** alignment, and the **tracked migration** path to a **gemaraproj** SDK release and **org-owned** action, per **FR-006**.

## Assumptions

*Normative: **FR-001**–**FR-008** and **Clarifications** above. The bullets below add context; if a bullet appears to **conflict** with a requirement, follow the **FR** / **Clarification**.*

- The default branch is `main` unless the repository renames it; automation triggers are described against “default branch” to stay naming-neutral.
- The public registry scope for this project remains `quay.io/complytime/complytime-policies` (or a successor name documented in the same issue/epic) unless leadership changes the product scope.
- The language SDK and organization automation deliver the pack/unpack/transport and reusable workflows needed for this repository; this feature does not block on re-implementing those in-tree.
- Registry credentials and GitHub/Quay configuration are set up in parallel and may complete before or after the caller workflow, but a full end-to-end publish requires them.
- “Thin caller” is acceptable: this repository lists what to publish (matrix of bundles) and which secrets to use, not a duplicate OCI format specification.
- **Upstream OCI pack/push**: The pipeline uses a **pinned** composite action at [`gemaraproj/gemara-registry-cli`](https://github.com/gemaraproj/gemara-registry-cli) ([PR #2](https://github.com/gemaraproj/gemara-registry-cli/pull/2) `feat/gemara-bundle-publish`), pinned by **commit SHA** for reproducibility. The personal fork `sonupreetam/gemara-publish-oci` is superseded. That action runs **`tools/publish`** with the **SDK** and any `require` / `replace` in its own `go.mod` — in line with [go-gemara](https://github.com/gemaraproj/go-gemara) bundle work (for example [PR #62](https://github.com/gemaraproj/go-gemara/pull/62)) until released. **This repository** chooses only the **action** ref and the usual `with:` inputs (registry, file, tag, and so on); it does not override the **Go** module version for **go-gemara** in workflow inputs.
- **Target state (migration)**: The action already lives under **gemaraproj** (`gemara-registry-cli`). The remaining migration step is to pin a **stable release tag** (not a branch SHA) once PR #2 merges to `main` and a release is cut. The caller workflow MUST be **updated** to that tag, and branch SHA pins MUST be **retired** as an explicit task.
- **Promotion to the public ComplyTime registry on Quay** (*non-normative echo of **FR-004***): The path from **staging** (`ghcr.io`) to `quay.io/…` is handled by the **pinned composite action** with registry-agnostic `destination_*` inputs, keyless cosign on both ends, and ORAS copy (see [contracts/publish-pipeline.md](contracts/publish-pipeline.md)). This is the **accepted production path** per Session 2026-05-04.
- **Publishable content (for FR-002)**: the paths under `governance/` (including `governance/controls/` and `governance/policies/`) and, when the repository includes them, `bundles/` and any other roots the publish matrix documentation lists. These paths define *what* goes into a release when a release is cut; they do not by themselves mandate a new public release on every merge. Merges that touch only out-of-scope paths (for example meta-only documentation not in the matrix) are outside the published artifact; maintainers may extend the path set in the same documentation as the matrix. For **v1**, the **canonical** intentional release trigger is **`workflow_dispatch`** only (see **FR-002** and **Clarifications**). Future triggers (tag push, schedule, or per-merge policy for a subset) require the same publish documentation to record precedence and governance, consistent with User Story 1.
- **Traceability:** This feature specification supports [complytime-policies#5](https://github.com/complytime/complytime-policies/issues/5) **Step 2** and related work ([#7](https://github.com/complytime/complytime-policies/issues/7)–[#9](https://github.com/complytime/complytime-policies/issues/9)). Upstream **SDK** and **org-infra** work is out of this repository’s implementation scope but is assumed available per the epic.
