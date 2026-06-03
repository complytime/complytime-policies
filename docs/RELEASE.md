# Release Process for complytime-policies

The release process values simplicity and automation in order to
provide better predictability and low cost for maintainers.

## Overview

This repository publishes [Gemara](https://github.com/gemaraproj/gemara)
policy bundles as OCI artifacts to **GHCR** and **Quay.io**. Each bundle
is published to its own Quay repository under the `complytime` namespace
(see [ADR-0001](adr/0001-one-quay-repo-per-bundle.md)).

Two workflows work together:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **Publish policy OCI** | Push to `main` (auto) or `workflow_dispatch` | Builds, signs, and pushes bundles to GHCR and Quay |
| **Release** | `workflow_dispatch` only | Creates a Git tag and GitHub Release with changelog |

## Process Description

### 1. Continuous publishing (`:latest`)

Every push to `main` that touches `bundles/**` or `governance/**`
automatically publishes all bundles to GHCR and Quay with the
`:latest` tag. This is handled by the **Publish policy OCI** workflow
and requires no manual intervention.

### 2. Cutting a versioned release

When a maintainer is ready to cut a versioned release:

1. **Run the Release workflow** from the Actions tab or CLI:

   ```bash
   gh workflow run release.yml --ref main -f tag=v0.1.0
   ```

   This workflow:
   - Validates the tag matches semver format (`vMAJOR.MINOR.PATCH`)
   - Ensures the release is from `main`
   - Creates the Git tag if it does not exist
   - Publishes a GitHub Release with auto-generated changelog
     via [release-drafter](https://github.com/release-drafter/release-drafter)

2. **Run the Publish policy OCI workflow** with the version input:

   ```bash
   gh workflow run publish-policy-oci.yml --ref main -f version=v0.1.0
   ```

   This applies the semver tag to OCI artifacts on GHCR and Quay
   alongside the existing `:latest` tag. Semver tags are **immutable**:
   the workflow fails if the tag already exists on the registry.

### 3. Preview release notes

Before cutting a release, maintainers can preview the changelog:

```bash
gh workflow run release_notes_preview.yml
```

This runs release-drafter in dry-run mode, writes the output to the
job summary, and uploads a `release-notes-preview.md` artifact.

## Versioning Strategy

Bundles are versioned **independently** per
[ADR-0001](adr/0001-one-quay-repo-per-bundle.md). All bundles in this
repository share a single release tag for simplicity, but the OCI
publishing workflow handles each bundle as an independent artifact.

This repository follows [Semantic Versioning](https://semver.org/):

| Change type | Version bump | Examples |
|-------------|-------------|---------|
| Breaking changes to policy semantics (controls removed, IDs changed) | **Major** | Removing a control from a catalog, renaming control IDs |
| New policies, catalogs, guidance, or bundles added | **Minor** | Adding a new bundle, adding controls to a catalog |
| Policy content corrections, documentation, CI fixes | **Patch** | Fixing a control description, updating workflow YAML |

The [release-drafter configuration](../.github/release-drafter.yml)
includes a `version-resolver` that suggests the next version based on
PR labels. Maintainers should verify the suggested version before
publishing.

## Release Criteria Checklist

Before applying a semver tag, confirm:

- [ ] All PRs included in the release are merged to `main`
- [ ] CUE schema validation passes (the `cue-validate` workflow
      on the latest `main` commit)
- [ ] No open issues labeled `breaking` without a corresponding
      major version bump
- [ ] Release notes preview has been reviewed
      (`release_notes_preview.yml`)
- [ ] At least one maintainer has approved the release

## Consumer Notification

Downstream consumers (e.g., `complyctl` users) discover new versions
through:

- **GitHub Releases** — published with changelog on this repository
- **Quay.io tag listing** — each bundle's tag page shows available
  versions (e.g.,
  [policies-ampel-branch-protection tags](https://quay.io/repository/complytime/policies-ampel-branch-protection?tab=tags))
- **OCI tag API** — programmatic discovery:

  ```bash
  curl -sS https://quay.io/v2/complytime/policies-ampel-branch-protection/tags/list
  ```

Consumers update their `complytime.yaml` to reference the new tag:

```yaml
policies:
  - id: ampel-branch-protection
    url: quay.io/complytime/policies-ampel-branch-protection@v0.1.0
```

## Rollback Procedure

OCI semver tags are **immutable** — they cannot be overwritten once
published. If a release contains incorrect policy content:

1. **Do not delete the tag.** Consumers may have pinned to it by
   digest.
2. **Fix forward** — merge the correction to `main` and cut a new
   patch release (e.g., `v0.1.1`).
3. **Document the issue** in the new release's changelog, noting
   which version is superseded.
4. If the release has a critical security issue, add a notice to
   the GitHub Release description for the affected version.

## Cadence

Releases are currently cut on-demand by maintainers. As the bundle
catalog grows and downstream consumers stabilize, the team may adopt
a regular cadence (e.g., monthly or per-sprint).

## Tests

The [CUE schema validation workflow](../.github/workflows/cue-validate.yaml)
runs on every PR that touches `governance/**` or `bundles/**`, ensuring
policy content conforms to the Gemara schema before merge.

## Related Documentation

- [ADR-0001: One Quay Repository Per Policy Bundle](adr/0001-one-quay-repo-per-bundle.md)
- [ADR-0002: Separate Quay Org for Internal Policy Bundles](adr/0002-separate-quay-org-for-internal-policies.md)
- [Usage guide](usage.md)
- [OSPS Baseline — Build and Release controls](https://baseline.openssf.org/)
