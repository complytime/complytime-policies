# Research: policy OCI publish (content + thin workflow)

## 1. Release trigger (batched vs continuous)

- **Decision**: **v1** SHALL use **`workflow_dispatch` only** as the intentional release driver (**FR-002**, **Clarifications** 2026-04-22): workflow inputs carry the registry tag / version string (and optional bundle root id when matrix lands). Do **not** add **`on.push.tags`** or other triggers in **v1** without updating the spec’s precedence rules and publish documentation. Do **not** auto-publish to public Quay on every merge to `governance/`.
- **Rationale**: Spec clarification locks acceptance tests and RBAC story; dispatch is easiest to gate with environments/approvers.
- **Alternatives considered**: Tag-push–only or dual triggers (deferred until spec documents precedence relative to **`workflow_dispatch`**).

## 2. Staging registry and image coordinates

- **Decision**: Use **`ghcr.io`** as staging: **`ghcr.io/<github_owner>/<repo or package name>`** with a tag strategy that ties to the release (e.g. **`sha-<full_sha>`** or semver **`v1.2.3`**) so **`resuable_publish_quay`** can resolve **`source_tag`** and optional SHA tags.
- **Rationale**: Spec assumption explicitly names GHCR as common staging; GHCR auth via `GITHUB_TOKEN` / `packages: write` is standard for Actions.
- **Alternatives considered**: Quay staging namespace (valid if org prefers; would change `source_*` inputs only).

## 3. Composite publish action (`uses:`)

- **Decision**: Pin **`uses:`** to a **full commit SHA** of the org-agreed or **interim** repo hosting **Publish Gemara OCI bundle** (inputs: `registry`, `repository`, `tag`, `file`, `username`, `password`, optional `working_directory`, `validate`, …). Document **interim** vs **post-migration** per **FR-006** (e.g. interim: personal/fork action; steady: **`complytime/oci-artifact`** or **gemaraproj** equivalent).
- **Rationale**: Reproducible supply chain; spec forbids redefining bundle layout in this repo; action already encapsulates **`go run`** publish tool + ORAS copy.
- **Alternatives considered**: Inline `docker run` or ORAS CLI in this repo (rejected — duplicates contract and violates thin-caller intent).

## 4. Promotion: `workflow_call` to `resuable_publish_quay.yml`

- **Decision**: Second job (or sequential step) in the same workflow calls **`complytime/org-infra/.github/workflows/resuable_publish_quay.yml@<pinned SHA>`**, mapping **`source_*`** from the GHCR image/tag the composite action pushed, **`dest_*`** to **`quay.io/continuouscompliance/complytime-policies`** (or documented successor) and **`dest_tag`** matching the release tag policy. Pass **`secrets: inherit`** or explicit secret mapping per org policy.
- **Rationale**: **FR-004** mandates shared org automation for cross-registry promotion and attestation/signature handling.
- **Alternatives considered**: Custom `crane copy` in this repo (rejected by **FR-004**).

## 5. Cosign / `verify_signature` interaction

- **Decision**: **Normative for v1** (**FR-004**, **Clarifications**): the promote **`workflow_call`** MUST pass **`verify_signature: true`** (matches org workflow default). **`verify_signature: false`** is allowed **only** with an **explicit org-infra agreement** recorded in publish documentation, including **scope and sunset**, per **Promotion and signing shape** — not as a silent convenience default. The composite **publish** step (or an org-standard intermediate signing job) must produce a staging digest that **`cosign verify`** accepts under the workflow’s identity/OIDC rules, **or** the documented exception path is used until signing is fixed.
- **Rationale**: Aligns operators’ audit story (**User Story 2**) with org defaults; avoids undocumented weak posture.
- **Alternatives considered**: Default **`verify_signature: false`** for v1 (rejected by clarification); org **reusable_sign_and_verify** between jobs if pack action cannot yet attach compatible signatures (**coordinate with org-infra**).
- **Implementation (2026-04-22)**: The workflow in **`.github/workflows/publish-policy-oci.yml`** passes **`verify_signature: true`** to **org-infra** promote. **E2E confirmation** is still required that the staging image is **keyless** **cosign**-compatible with the promote job’s `cosign verify` (identity/OIDC) — if not, use the spec’s **org-documented exception** (scope + sunset) until signing aligns (**Clarifications** 2026-04-22).

## 6. Publish matrix (single vs multiple bundle roots)

- **Decision**: **Phase 1 implementation**: one **`file:`** root YAML (or one job). **Document** how to add a **matrix** of roots (`bundles/*`) in the same workflow pattern without changing OCI contract ownership.
- **Rationale**: Meets **SC-003** with lowest complexity; spec allows multiple paths over time.
- **Alternatives considered**: Full matrix day one (defer until second bundle root is required).

## 7. Overlapping `workflow_dispatch` runs

- **Decision**: Use workflow-level **`concurrency`** (**FR-002**, **Clarifications** 2026-04-22): one stable **group** key (for example `publish-policy-oci`) and an explicit **`cancel-in-progress`** choice (`true` or `false`) documented in publish docs (`specs/001-policy-oci-publish/quickstart.md`) with maintainer rationale. Keep org **`fail_if_dest_exists`** (or equivalent) for duplicate **`dest_tag`** as a second line of defense.
- **Rationale**: Reduces publish/promote races; satisfies the **Back-to-back merges / overlapping** edge case beyond registry-only failures.
- **Alternatives considered**: Concurrency off, rely on **`fail_if_dest_exists`** only (rejected by clarification).
