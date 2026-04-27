# Data model: policy OCI publish

> **Workflow shape:** The diagram below and any **separate** “promote” step describe the **pre–Option-3** and **convergence** mental model. For the **v1** **Option 3** / **PR #19** **single-composite** caller, treat [contracts/publish-pipeline.md](contracts/publish-pipeline.md) as the source of truth; do not infer `needs:` edges in GitHub Actions from this file alone.

This feature is **pipeline- and content-centric**; there is no application database. Entities below are **logical** for specs, workflows, and documentation.

## Entities

### 1. PublishableContentSet

**Description**: Snapshot of filesystem paths included when a **release** runs.

| Field | Type | Notes |
|-------|------|--------|
| `paths` | list of path globs | Default includes `governance/**`; optional `bundles/**` per publish matrix doc. |
| `default_branch_ref` | string | e.g. `main` at workflow run time (`github.ref` / SHA). |
| `workspace_sha` | string | `github.sha` for the checked-out content driving the bundle. |

**Validation**: Paths MUST match documented publish matrix; merges touching only excluded paths do not imply a release (**FR-002**).

### 2. BundleRoot

**Description**: One Gemara **root YAML** used as **`-file`** input to the composite publish action.

| Field | Type | Notes |
|-------|------|--------|
| `file` | string | Repo-relative path (e.g. `bundles/complytime/policies.yaml`). |
| `logical_name` | string | Human/id label for matrix expansion later. |

**Validation**: When `validate: true` on the action, SDK validates via **`gemara.Load`** before assemble.

### 3. StagingImageRef

**Description**: OCI reference produced by pack/push (input to promotion).

| Field | Type | Notes |
|-------|------|--------|
| `registry` | string | e.g. `ghcr.io`. |
| `repository` | string | e.g. `continuouscompliance/complytime-policies-staging`. |
| `tag` | string | e.g. `v1.0.0` or `sha-abc…`. |
| `digest` | string | From action output `digest` (`sha256:…`). |

**Relationships**: **1:1** with a successful publish run for a given **BundleRoot** at a **workspace_sha** (unless matrix multiplies refs).

### 4. PublicRelease

**Description**: Addressable policy artifact on public Quay after promotion.

| Field | Type | Notes |
|-------|------|--------|
| `dest_registry` | string | `quay.io`. |
| `dest_image` | string | e.g. `continuouscompliance/complytime-policies`. |
| `dest_tag` | string | Primary tag promoted. |
| `digest` | string | From reusable workflow output `digest`. |

**State**: Created only after **`workflow_call`** promote succeeds; immutable tags policy via **`fail_if_dest_exists`** (org workflow default **true**).

### 5. ReleaseTrigger

**Description**: How a maintainer starts a pipeline.

| Field | Type | Notes |
|-------|------|--------|
| `kind` | enum | **v1**: **`workflow_dispatch` only** (**FR-002**). Future values (e.g. `push_tag`) require spec + publish doc precedence rules. |
| `concurrency_group` | string | Workflow **`concurrency.group`** value; documented in **`specs/001-policy-oci-publish/quickstart.md`** and workflow file (**FR-002**). |
| `cancel_in_progress` | boolean | Workflow **`concurrency.cancel-in-progress`**; documented with rationale (**FR-002**). |
| `actor_constraints` | string (doc) | GitHub environments / required reviewers (optional, ops). |

## Relationships (summary)

```text
ReleaseTrigger (1) → runs workflow on → PublishableContentSet (1)
PublishableContentSet (1) → selects → BundleRoot (1..n)
BundleRoot (1) → publish action → StagingImageRef (1)
StagingImageRef (1) → resuable_publish_quay → PublicRelease (0..1)
```
