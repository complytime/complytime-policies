# complytime-policies

Centralized repository for Gemara policies used by [ComplyTime](https://github.com/complytime) tooling. Policies defined here are published as OCI artifacts to a public **Quay.io** namespace and consumed (for example via `complyctl get`).

## Current publish design

Workflow: [`.github/workflows/publish-policy-oci.yml`](.github/workflows/publish-policy-oci.yml)

- **Thin caller:** a single `uses:` of the composite
  [`sonupreetam/gemara-publish-oci@967268e281b90e12b88224231583a04bb57a5c3f`](https://github.com/sonupreetam/gemara-publish-oci) (see [PR #4](https://github.com/sonupreetam/gemara-publish-oci/pull/4) / `feat/demo-push-only`); bump the SHA in the workflow when the action changes.
- **Pin table (FR-006 / T004):** the **callee** pin is the composite SHA above (also in [`.github/workflows/publish-policy-oci.yml`](.github/workflows/publish-policy-oci.yml)). This **Option 3** layout does **not** add a second line item for [complytime/org-infra **`resuable_publish_quay.yml`**](https://github.com/complytime/org-infra/blob/main/.github/workflows/resuable_publish_quay.yml) because promote is **inside** the action. On **convergence** to a caller **`workflow_call`** to that reusable, add its **commit SHA** here and in the workflow.
- **Defaults (dispatch):** `trust_mode: resign`, `verify_quay: true` (destination `cosign verify` after promote when promote runs); `sign_source` / `verify_source` stay off unless you change the workflow. Forks can set `allow_unprotected_ref: true` to run without a protected branch.
- **Overlapping runs & dest tags (T007 / FR-002, spec Edge Cases):** workflow **`concurrency`** uses group `publish-policy-oci` with `cancel-in-progress: false` (see workflow file). Use a **new** `release_tag` per intentional release. **`fail_if_dest_exists`** and related promote flags are **not** set on *this* caller repo’s `with:` for **Option 3** (they apply when calling org-infra’s **`resuable_publish_quay`** `workflow_call`); the composite’s internal ORAS path defines overwrite/tag behavior. See [contracts/publish-pipeline.md](specs/001-policy-oci-publish/contracts/publish-pipeline.md).

```mermaid
flowchart LR
  policyRepo[complytime_policies_workflow] --> ghcrPush[push_to_ghcr]
  ghcrPush --> quayCopy[copy_to_quay]
  quayCopy --> refs[source_ref_and_destination_ref]
```

## Required secrets

- `QUAY_ROBOT_USERNAME`
- `QUAY_ROBOT_TOKEN`
- `GITHUB_TOKEN` is used automatically for GHCR

Forks must define their own repository secrets.

## Run a release

Use **Actions -> Publish policy OCI -> Run workflow** and set:

- `release_tag` (required)
- optional `bundle_file` (default: `bundles/cis-fedora-l1-workstation.yaml`)
- optional `dest_image` (default: `test_complytime/complytime-policies`)
- optional `trust_mode`, `verify_quay`
- optional `allow_unprotected_ref` (`true` for unprotected fork branches)

Success criteria:

- workflow job passes
- logs contain `source_ref`, `destination_ref`, and (when `verify_quay` is true) `verified_destination`

## Policy content

- Catalogs: `governance/catalogs/`
- Policies: `governance/policies/`
- Bundle roots: `bundles/*.yaml`

## Usage

```bash
complyctl get
```

## License

Apache-2.0. See [LICENSE](LICENSE).
