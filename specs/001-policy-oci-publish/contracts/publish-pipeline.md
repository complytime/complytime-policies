# Contract: thin caller pipeline (Option 3)

This repository is a **caller only**. Canonical OCI bundle semantics remain in **go-gemara** and the
pinned composite action (today: [`sonupreetam/gemara-publish-oci`](https://github.com/sonupreetam/gemara-publish-oci); org name `complytime/oci-artifact` is an equivalent target when the same `action.yml` is published there).

## A. Caller workflow contract

**Consumer:** `complytime-policies/.github/workflows/publish-policy-oci.yml`  
**Provider:** `sonupreetam/gemara-publish-oci@<pinned-full-sha>` (see comment in workflow; [source PR #4](https://github.com/sonupreetam/gemara-publish-oci/pull/4))

### Required `workflow_dispatch` inputs

| Input | Description |
|-------|-------------|
| `release_tag` | Tag on GHCR and Quay. |
| `bundle_file` | Root Gemara bundle YAML (repo-relative). |
| `dest_image` | Quay path `namespace/repo` without `quay.io/`. |
| `trust_mode` | `resign`, `copy-referrers`, or `copy-only` (passed to the action). |
| `verify_quay` | If `true`, run `cosign verify` on the **destination** digest after promote (proves signature in CI). |

Optional: `allow_unprotected_ref` (forks / unprotected default branch).

### Required secrets

| Secret | Use |
|--------|-----|
| `GITHUB_TOKEN` | GHCR push/pull (`packages: write`). |
| `QUAY_ROBOT_USERNAME` | Quay promotion. |
| `QUAY_ROBOT_TOKEN` | Quay promotion. |

### Required permissions

- `contents: read`
- `packages: write`
- `id-token: write` (keyless cosign when signing/verify steps run)

## B. Action input mapping (actual `with:`)

The thin caller maps into the composite as implemented in the workflow (names must match `action.yml`):

| Caller / dispatch | Action input |
|---------------------|--------------|
| `publish_mode` | `gemara-file` |
| `registry` | `ghcr.io` |
| `repository` | lowercased `${{ github.repository }}` |
| `tag` | `release_tag` |
| `file` | `bundle_file` |
| `promote_to_quay` | `"true"` |
| `quay_registry` | `quay.io` |
| `quay_image` | `dest_image` |
| `quay_tag` | `release_tag` |
| `quay_username` / `quay_password` | Quay robot secrets |
| `trust_mode` | dispatch `trust_mode` (default `resign`) |
| `sign_source` / `verify_source` | `"false"` in the checked-in workflow (demo; change if you want GHCR keyless sign) |
| `sign_destination` | `"false"` (destination sign still runs when `trust_mode: resign` per action rules) |
| `verify_destination` | from `verify_quay` → `"true"` / `"false"` |
| `allowed_identity_regex` | `^https://github.com/<this repo>/.github/workflows/` |

> **Note:** The composite **embeds** GHCR publish, optional cosign, and ORAS copy to Quay. It does **not** use a separate `workflow_call` to `complytime/org-infra` promote reusables. [spec.md](../spec.md) **FR-004** still describes the org-reusable pattern; this path is the **interim / Option 3** stack recorded under **FR-006** (pinned action, migration to org-agreed refs).

## C. Output contract

- `source_ref`, `source_digest` / `digest`
- `destination_ref`, `destination_digest`
- `verified_source`, `verified_destination` (when verify steps run)

## D. Ordering invariant

The composite enforces: publish → optional source sign/verify → optional promote → optional destination sign/verify (see action `finalize` step).
