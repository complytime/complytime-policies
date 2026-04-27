# Spec delta: `policy-oci-publish`

## ADDED Requirements

### Requirement: Release pipeline produces public Quay policy artifacts

The system SHALL provide an automation path that, on an **intentional release** (as documented for this repository—not necessarily every merge to the default branch), publishes Gemara-backed OCI content to the public ComplyTime Quay namespace for this product (`quay.io/continuouscompliance/complytime-policies` or a documented successor), unless publishable path rules exclude an empty or skipped release.

#### Scenario: Successful release with publishable content

- **WHEN** a maintainer runs the documented release trigger and publishable content under the documented matrix (for example `governance/`, `bundles/`) is in scope
- **THEN** the pipeline completes with success or fails with an actionable, visible error, and a successful run leaves retrievable artifacts in the public registry per the agreed naming

#### Scenario: No silent partial failure

- **WHEN** authentication to staging or public registry fails or promotion is rejected
- **THEN** the run does not report success for a partial write to the public registry in a way that hides the failure from operators

### Requirement: Thin caller to oci-artifact publish interface

The system SHALL not define a second OCI manifest, media type, or layer-assembly contract in this
repository. Pack, push, sign, verify, and promote responsibilities SHALL be delegated to a single
versioned publish interface owned by `oci-artifact` (composite action or reusable workflow) that
implements go-gemara (or successor) bundle semantics. Caller repositories SHALL supply only
release inputs, destination settings, and secrets according to the documented interface contract.

#### Scenario: OCI contract ownership

- **WHEN** implementation work occurs in this repository
- **THEN** changes SHALL NOT re-specify `bundle.Pack` layout, ORAS media types, or root manifest shape beyond caller inputs (registry, path, tag, root YAML file) to the action

#### Scenario: Centralized publish orchestration

- **WHEN** artifacts are released from this repository
- **THEN** the caller workflow SHALL invoke the standardized `oci-artifact` interface and SHALL
  NOT implement its own standalone oras/cosign promotion choreography for normal releases

### Requirement: Documented publish interface version and migration

The system SHALL document, in publish and release documentation: (a) the `oci-artifact` publish
interface `uses` reference (commit SHA or semver tag); (b) whether that reference is interim or
stable; and (c) migration criteria for moving to newer interface versions. The repository SHALL NOT
set go-gemara `require` or `replace` in workflow files; SDK dependency details SHALL remain within
the called interface implementation.

#### Scenario: Interim interface is labeled

- **WHEN** a pre-release or temporary `oci-artifact` publish interface ref is used
- **THEN** documentation explicitly marks it as interim and defines migration expectations

#### Scenario: Consumer and operator documentation

- **WHEN** a reader or operator follows only this repository’s documented steps
- **THEN** they can identify where releases live, how to reference a version or digest, how
  verification is performed, and which behavior is guaranteed by the `oci-artifact` interface

### Requirement: Operational secrets and optional checks

Operational registry and CI credentials SHALL be supplied only via GitHub (or org) secrets or environments. The repository MAY document required secret names and scopes without embedding values. If optional vulnerability or policy checks are wired into the pipeline, their enable and disable behavior SHALL align with the organization’s reusable contract and SHALL NOT silently skip agreed blocking checks in production.

#### Scenario: No secrets in clear text

- **WHEN** documentation or examples are updated
- **THEN** they SHALL NOT include raw passwords or tokens; they SHALL use placeholder names such as `secrets.NAME` or GitHub’s documented expression form for secrets

#### Scenario: Optional check contract

- **WHEN** org-level verify steps are optional in reusable workflows
- **THEN** this repository’s workflow parameters SHALL match the documented org contract so production does not silently skip agreed blocking checks
