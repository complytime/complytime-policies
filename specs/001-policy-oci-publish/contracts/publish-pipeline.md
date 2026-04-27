# Contract: thin caller pipeline (Option 3)

This repository is a caller only. Canonical OCI bundle semantics remain in go-gemara and the pinned
`complytime/oci-artifact` composite action.

## A. Caller workflow contract

**Consumer:** `complytime-policies/.github/workflows/publish-policy-oci.yml`  
**Provider:** `complytime/oci-artifact@<pinned-sha>`

### Required caller inputs

| Input | Description |
|-------|-------------|
| `release_tag` | Source and destination tag. |
| `bundle_file` | Root Gemara bundle path (forwarded to action `file`). |
| `dest_image` | Destination Quay path without registry. |
| `trust_mode` | `resign`, `copy-referrers`, or `copy-only`. |

### Required secrets

| Secret | Use |
|--------|-----|
| `GITHUB_TOKEN` | Source GHCR push/pull (`packages: write`). |
| `QUAY_ROBOT_USERNAME` | Destination auth user. |
| `QUAY_ROBOT_TOKEN` | Destination auth token. |

### Required permissions

- `contents: read`
- `packages: write`
- `id-token: write`

## B. Action input mapping

The thin caller maps values directly into a single action invocation:

- `publish_mode: gemara-file`
- `registry: ghcr.io`
- `repository: <lowercase github.repository>`
- `tag: release_tag`
- `file: bundle_file`
- `promote_to_destination: "true"`
- `destination_registry: quay.io`
- `destination_repository: dest_image`
- `destination_tag: release_tag`
- `trust_mode: trust_mode`

### Current demo profile (branch-specific)

For `feat/demo-push-only-caller`, the caller intentionally disables signature steps:

- `sign_source: "false"`
- `verify_source: "false"`
- `sign_destination: "false"`
- `verify_destination: "false"`
- `trust_mode: copy-only` (workflow default)

## C. Output contract

Callers and operators should rely on these outputs:

- `source_ref`, `source_digest`
- `destination_ref`, `destination_digest`
- `verified_source`, `verified_destination`

## D. Ordering invariant

The action enforces this order internally:

1. Publish source reference.
2. Sign/verify source digest.
3. Promote to destination (if enabled).
4. Apply destination trust model and verification.
