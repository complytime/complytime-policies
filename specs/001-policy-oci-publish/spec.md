# Feature Specification: Published policy OCI release pipeline

**Feature Branch**: `001-policy-oci-publish`  
**Created**: 2026-04-22  
**Status**: Draft  
**Input**: User description: "Publish Gemara policy bundles and governance content as OCI artifacts: automated release on merge to the default branch, organization staging registries, signing and attestation, promotion to the public ComplyTime registry. Repository provides source content and a thin release caller; artifact contract and transport are defined by the SDK and shared org automation. Document how consumers obtain and verify published policy artifacts. Aligns with GitHub issue 5 and sub-issues 7-9."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintainers get automatic releases of policy content (Priority: P1)

ComplyTime maintainers merge vetted changes to policy bundles and governance files on the default branch. They need each such merge to produce a consistent, signable, promoted release to the organization’s public registry so downstream teams and tools can depend on a single source of truth.

**Why this priority**: Without automated publication on merge, policy fixes and updates do not reach consumers predictably, breaking compliance and integration timelines.

**Independent Test**: Can be fully tested by landing an allowed change to publishable content on the default branch and confirming that a publish run completes and the resulting release is available from the public registry (with appropriate credentials where required).

**Acceptance Scenarios**:

1. **Given** publishable content under `governance/` and any designated bundle paths (for example `bundles/`) and required registry access configured, **When** a maintainer merges an approved change to the default branch, **Then** a release pipeline runs to completion and artifacts appear at the public ComplyTime registry for that repository’s scope.
2. **Given** the same content layout, **When** a merge only touches non-publishable files (for example documentation-only paths excluded from release), **Then** behavior matches the defined policy (either no publish run or a no-op as documented).

---

### User Story 2 - Operators can trust the supply chain for published policy (Priority: P2)

Security and platform operators need published policy artifacts to follow the same staging, signing, and promotion practices as other ComplyTime releases so attestations and provenance are consistent.

**Why this priority**: Reduces org risk and supports audits; secondary to “something is published at all” (P1).

**Independent Test**: Can be tested by reviewing pipeline outputs and attestation material for a successful run and confirming the promotion path matches the organization’s standard (staging → sign/attest → public registry).

**Acceptance Scenarios**:

1. **Given** a successful release run, **When** an operator reviews the run’s outputs, **Then** signing/attestation steps and promotion to the public registry are present and follow the standard organization pattern for similar artifacts.
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
- **Back-to-back merges**: Multiple consecutive merges to the default branch should each result in a distinct, traceable published outcome (or an explicitly documented queuing/serialization behavior that avoids overwriting without intent).
- **No credentials / dry environments**: Documentation or process notes for forks or local validation should not require embedding secrets; credential setup is tracked as a separate operational task.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST keep Gemara-governed content under `governance/` (including `governance/catalogs/` and `governance/policies/`) and any additional bundle root paths the maintainers document (for example `bundles/`) consistent with the repository constitution and schema validation in force at merge time.
- **FR-002**: A merge to the default branch that includes changes to publishable content MUST trigger a release pipeline whose successful outcome is published policy artifacts in the public ComplyTime namespace agreed for this repository, unless the path set is empty by policy.
- **FR-003**: The repository MUST provide a “caller”-style integration that delegates layout, transport, signing, and promotion to the language SDK and shared organization automation, without redefining the OCI media types, layer structure, or manifest contract in a second, divergent way.
- **FR-004**: The release process MUST use the organization’s standard staging, signing, attestation, and promotion flow for this artifact class, including a staging registry step before the public ComplyTime registry, matching the org’s established pattern.
- **FR-005**: Repository documentation MUST describe how external consumers find releases, how they reference a version, and how they verify what they pulled, in terms appropriate for the primary ComplyTime CLI or documented tooling where applicable.
- **FR-006**: Operational access for publishing (robot accounts, token scopes) MUST be configured outside the git tree; the specification of required secret *names* and *scopes* MAY be documented without storing secret values in the repository.
- **FR-007**: If optional vulnerability or policy checks are used for this pipeline, their enable/disable behavior MUST match the organization’s reusable workflow contract (for example optional verify steps) and MUST NOT silently skip agreed blocking checks in production.

### Key Entities

- **Policy bundle**: A versioned set of related Gemara policy or catalog files living under a documented path (for example a directory under `bundles/`) that is included in the publish matrix.
- **Governance artifact**: Catalogs and policies under `governance/` that are subject to the same quality bar and may be part of a published OCI object as defined by the single upstream contract.
- **Published release**: A named or digest-addressable set of OCI objects in the public ComplyTime registry that corresponds to a given merge to the default branch, consumable by downstream clients.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every merge to the default branch that is in scope for publication, the release pipeline either completes with a success status and leaves retrievable artifacts in the public ComplyTime registry, or fails with a visible, attributable failure (no silent partial publish).
- **SC-002**: A reader who is new to this repository can, using only the usage documentation in this repository, complete one successful fetch and verification of a published release that the maintainers have labeled as “current” or by explicit version, within 30 minutes under normal network conditions.
- **SC-003**: At least one end-to-end demonstration runs in a representative environment (as defined with maintainers) showing merge → published artifact → consumer verification before the feature is marked done for the planning epic.

## Assumptions

- The default branch is `main` unless the repository renames it; automation triggers are described against “default branch” to stay naming-neutral.
- The public registry scope for this project remains `quay.io/continuouscompliance/complytime-policies` (or a successor name documented in the same issue/epic) unless leadership changes the product scope.
- The language SDK and organization automation deliver the pack/unpack/transport and reusable workflows needed for this repository; this feature does not block on re-implementing those in-tree.
- Registry credentials and GitHub/Quay configuration are set up in parallel and may complete before or after the caller workflow, but a full end-to-end publish requires them.
- “Thin caller” is acceptable: this repository lists what to publish (matrix of bundles) and which secrets to use, not a duplicate OCI format specification.
- **Publishable content (for FR-002)**: for testing and automation, a merge is in scope to trigger publication when it changes paths under `governance/` (including `governance/catalogs/` and `governance/policies/`) and, when the repository includes them, `bundles/` and any other roots the publish matrix documentation lists. Merges that touch only out-of-scope paths (for example repository meta-only docs not in the matrix) do not, by this definition, require a publish; maintainers may extend the path set in the same documentation as the matrix.
- **Traceability:** This feature specification supports [complytime-policies#5](https://github.com/complytime/complytime-policies/issues/5) **Step 2** and related work ([#7](https://github.com/complytime/complytime-policies/issues/7)–[#9](https://github.com/complytime/complytime-policies/issues/9)). Upstream **SDK** and **org-infra** work is out of this repository’s implementation scope but is assumed available per the epic.
