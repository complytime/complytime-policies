# Release Process for complytime-policies

## Cutting a Release

Ensure CUE validation passes on the latest `main` commit and review
the release notes preview before proceeding.

1. **Preview the changelog** (optional):

   ```bash
   gh workflow run release_notes_preview.yml
   ```

2. **Create the GitHub Release** (tags the commit, publishes changelog):

   ```bash
   gh workflow run release.yml --ref main -f tag=v0.1.0
   ```

3. **Publish OCI artifacts with the semver tag**:

   ```bash
   gh workflow run publish-policy-oci.yml --ref main -f version=v0.1.0
   ```

   Semver tags are immutable — the workflow fails if the tag already
   exists on the registry. If a bad release is published, fix forward
   with a new patch release (e.g., `v0.1.1`).

Pushes to `main` that touch `bundles/**` or `governance/**`
automatically publish `:latest` to GHCR and Quay — no manual step
needed for that.

## Versioning

This repository follows [Semantic Versioning](https://semver.org/).
All bundles share a single release tag
(see [ADR-0001](adr/0001-one-quay-repo-per-bundle.md)).

| Change type | Bump |
|---|---|
| Controls removed, IDs renamed (breaking) | **Major** |
| New policies, catalogs, guidance, or bundles | **Minor** |
| Content corrections, documentation, CI fixes | **Patch** |

The [release-drafter configuration](../.github/release-drafter.yml)
suggests the next version based on PR labels — verify before
publishing.
