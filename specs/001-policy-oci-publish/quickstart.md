# Quickstart: Option 3 thin caller (maintainers)

## Prerequisites

- Policy YAML under **`governance/`** and **`bundles/`** passes merge-time validation in this repository.
- GitHub **secrets** (names only): see **GitHub secrets** in [`README.md`](../../README.md) — `QUAY_ROBOT_USERNAME`, `QUAY_ROBOT_TOKEN` for Quay; GHCR uses `GITHUB_TOKEN` from the workflow.
- Pinned `uses` rows in `README.md` and in [`.github/workflows/publish-policy-oci.yml`](../../.github/workflows/publish-policy-oci.yml).

## What “thin” means

1. **Checkout** the **default branch** in the workflow.  
2. The caller invokes one pinned composite, for example `uses: sonupreetam/gemara-publish-oci@<full-sha>` (or `complytime/oci-artifact@<sha>` when the same `action.yml` is on `main`); see the workflow and **FR-006** for the current pin.  
3. The action performs publish to GHCR, optional keyless sign/verify, and ORAS copy to Quay per
   `with:` inputs (`trust_mode`, `verify_quay`, `dest_image`, etc.) in a single `uses:`.

**Defaults (as in the checked-in workflow, PR #19):** `trust_mode: resign`, `verify_quay: true` (see **spec** Session 2026-04-27). You can set `copy-only` for a stricter no-resign path when debugging.

No in-repo redefinition of OCI manifest layout; see [contracts/publish-pipeline.md](contracts/publish-pipeline.md).

**Overlapping runs:** workflow `concurrency` group `publish-policy-oci` with `cancel-in-progress: false` (**FR-002**).

## Run the release workflow

1. Go to **Actions** → **Publish policy OCI** → **Run workflow** (on the default branch).  
2. **release_tag (required):** single tag for GHCR and Quay destination.
3. Optional: set `trust_mode` / `verify_quay` if you need a non-default path.  
4. On success, copy `source_ref`, `destination_ref`, and (when `verify_quay: true`) `verified_destination` from workflow logs.

**Workflow file:** [`.github/workflows/publish-policy-oci.yml`](../../.github/workflows/publish-policy-oci.yml)

## Local / fork checks

- **Forks** usually cannot complete E2E without fork-level Quay secrets and registry permissions.
- **Dry checks:** `yamllint` / schema validation of edited YAML only, not a full push.

## First E2E (org credentials)

1. Merge the desired policy/bundle state to the **default branch**.  
2. Run **Publish policy OCI** with a **new** `release_tag`.
3. Confirm source and destination refs plus verification outputs.
4. For consumers, follow the **Consumers** section in `README.md` and **SC-002** timing guidance in the spec.

## Consumers: fetch and verify (SC-002)

After a successful publish, the public image is at **`quay.io/continuouscompliance/complytime-policies:<release_tag>`** (see spec **Clarifications** if that path changes). Replace **`<tag>`** with the dispatch **`release_tag`** (or a **`<sha-…>`**-derived tag if your org workflow enabled SHA-style tags).

1. **Resolve digest** (optional but recommended for pinning):

   ```bash
   crane digest "quay.io/continuouscompliance/complytime-policies:<tag>"
   ```

2. **Verify cosign signature**:

   ```bash
   cosign verify "quay.io/continuouscompliance/complytime-policies@sha256:<digest>" \
     --certificate-identity-regexp '.*' \
     --certificate-oidc-issuer-regexp '.*'
   ```

  Tighten identity/issuer regexes to your org policy.

3. **Pull or copy** the artifact with your usual OCI tool (`skopeo`, `oras`, `complyctl get`, etc.).

## Cosign caveat (FR-004)

If a run fails on verification, check `allowed_identity_regex`, `trust_mode`, and destination
signing behavior for the selected mode.
