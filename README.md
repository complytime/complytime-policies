# complytime-policies

Centralized repository for Gemara policies used by [ComplyTime](https://github.com/complytime) tooling. Policies defined here are published as OCI artifacts to a public **Quay.io** namespace and consumed (for example via `complyctl get`).

## Overview

This repository contains governance artifacts used to define and enforce security controls across supported platforms (GitHub, GitLab, etc.). The governance content follows the [Gemara](https://github.com/gemaraproj/gemara) framework and is organized into catalogs and policies.

**Published OCI release pipeline (v1):** a thin GitHub Actions workflow ([`.github/workflows/publish-policy-oci.yml`](.github/workflows/publish-policy-oci.yml)) stages bundles on **GHCR**, then promotes to **Quay** using the organization’s reusable promote workflow. Normative requirements and **Clarifications** are in [`specs/001-policy-oci-publish/spec.md`](specs/001-policy-oci-publish/spec.md).

## Repository structure

```
complytime-policies/
├── .github/workflows/   # publish-policy-oci.yml (v1 OCI release)
├── bundles/               # Gemara root YAML for published OCI bundles
├── governance/
│   ├── catalogs/          # Security control catalogs
│   └── policies/         # Implementation policies
├── LICENSE
└── README.md
```

## Publishable path matrix (v1)

| In scope | Purpose |
|----------|--------|
| `governance/catalogs/`, `governance/policies/` | Catalog and policy YAML that may be included in a bundle per Gemara and the chosen root `file:` |
| `bundles/*.yaml` | Root Gemara documents used as the composite publish action’s **`file:`** (see default root below) |

| Out of scope (no impact on published artifact from this path alone) | Examples |
|------------------------------------------------------------------------|----------|
| Docs / meta not in the matrix | `README.md`, spec-only changes under `specs/` (unless the publish matrix is updated) |
| Other roots until documented | New bundle roots require a publish matrix update in this file |

**Default root YAML for the v1 workflow:** `bundles/cis-fedora-l1-workstation.yaml` (add more jobs or a matrix later; see [`specs/001-policy-oci-publish/research.md`](specs/001-policy-oci-publish/research.md) §6).

## Pinned action references (FR-006)

| Component | Pinned `uses` | Interim? |
|-----------|----------------|----------|
| Staging: Gemara pack, digest, SLSA + SPDX attest | **Inline** in [`.github/workflows/publish-policy-oci.yml`](.github/workflows/publish-policy-oci.yml) (not `workflow_call`: `reusable_publish_gemara_oci` is not on [public org-infra](https://github.com/complytime/org-infra) yet) | Revisit when that reusable ships — then delete duplicate steps and `uses:` it |
| Staging: keyless cosign + verify attestations | `complytime/org-infra/.github/workflows/reusable_sign_and_verify.yml@9205a3ac6b76b75dbe6e22b2f0f330bc8edbeb38` | No (bump with org when behavior changes) |
| Cross-registry promote | `complytime/org-infra/.github/workflows/resuable_publish_quay.yml@9205a3ac6b76b75dbe6e22b2f0f330bc8edbeb38` | No (pin updates when the reusable workflow’s behavior changes) |
| Interim composite (pack + push) | `sonupreetam/gemara-publish-oci@7203d6158a16208a0338cc33ea001bb077f4705c` in the same workflow | **Yes** (migrate to `complytime/oci-artifact@…` or org-agreed ref per upstream) |

**Why inline staging?** GitHub resolves `uses: org/repo/...@sha` for **reusable workflows** only if that file exists on the remote. The former pin used a **local** org-infra commit and a workflow not merged upstream, which produced *workflow was not found*. This repo inlines the same steps until [complytime/org-infra](https://github.com/complytime/org-infra) publishes `reusable_publish_gemara_oci.yml`.

**Migration:** when **gemaraproj**-published **go-gemara** and the composite action are in org-agreed repos, update the **action** `uses:` here (or in org-infra if reusing the reusable), bump the **org-infra** SHA for sign/promote, and document **interim** retirement per **SC-004** (see **Migration (interim action)** below).

## GitHub secrets (no values in git, FR-007)

Configure these in the repository (or org) **Secrets**:

| Secret | Purpose |
|--------|--------|
| (optional) *none extra for publish* | GHCR uses `secrets.GITHUB_TOKEN` with `packages: write` and attestations for the `publish-ghcr` (org reusable) and `sign-verify` jobs. |
| `QUAY_ROBOT_USERNAME` | Quay robot or service account **username** for the promote `workflow_call` (`dest_username`) |
| `QUAY_ROBOT_TOKEN` | Quay robot **token** or password (`dest_password`) |

The promote job passes `source_token: ${{ secrets.GITHUB_TOKEN }}` to pull the staging image from **GHCR**.

**Forks:** add **repository** Actions secrets on the **fork** you run the workflow from. Organization secrets and the upstream repo’s secrets do **not** apply to forks. **Environment** secrets are invisible unless the job declares `environment:` (v1 does not).

## Unprotected default branch (forks) + public org-infra pins

1. **Invalid `workflow_call` (e.g. “`allow_unprotected_ref` is not defined”)** — The [pinned](https://github.com/complytime/complytime-policies/blob/main/.github/workflows/publish-policy-oci.yml) public [`reusable_sign_and_verify.yml`](https://github.com/complytime/org-infra/blob/main/.github/workflows/reusable_sign_and_verify.yml) on `complytime/org-infra@main` only documents inputs such as `image_name`, `digest`, `verify_vuln`, etc. Do **not** pass `allow_unprotected_ref` into that `uses:` block; the workflow file is **invalid** if you add unknown keys. The in-repo **`publish-ghcr`** job may still use `allow_unprotected_ref` in its own `if:` conditions.

2. **Sign job and `ref_protected`** — On the same public pin, the sign job is gated with `if: github.ref_protected` (no fork escape hatch in that file). So on a **typical unprotected fork**, the **Keyless sign + verify** job may be **skipped** and the run will not complete the full chain. The practical fix is to **turn on branch protection** for the default branch in the **same** repository where you trigger the workflow (e.g. your fork’s `main`), so the dispatch has `ref_protected` true. A small repo such as [org-infra-tests](https://github.com/sonupreetam/org-infra-tests) is useful to **exercise** org-infra’s reusable workflows in isolation on a **protected** `main`; it does **not** replace publishing **this** repository’s `bundles/` unless you copy that content and workflow there. Longer term, add `allow_unprotected_ref` to `reusable_sign_and_verify` in **complytime/org-infra** (or pin a fork that has it) and then pass the input from this caller.

## v1 release procedure (FR-002)

- **Only trigger:** `workflow_dispatch` (no tag-only trigger in v1). Use **Actions → Publish policy OCI → Run workflow** and set **`release_tag`**. That tag is used for both the GHCR staging image and the primary Quay `dest_tag`. Set **`allow_unprotected_ref: true`** on an **unprotected** default branch so **this repo’s** **`publish-ghcr`** job (and SLSA/SBOM attestation steps) are not skipped — that input is **not** passed to [public `reusable_sign_and_verify`](https://github.com/complytime/org-infra/blob/main/.github/workflows/reusable_sign_and_verify.yml) (it has no such `workflow_call` input). The **org-infra** sign job runs only when **`github.ref_protected`** is true, so for a full run on a **fork** either **enable branch protection** on `main` (see [unprotected / forks](#unprotected-default-branch-forks--public-org-infra-pins)) or pin a fork of org-infra that adds an `allow_unprotected_ref` input to that reusable.
- **Optional inputs:** **`bundle_file`** (default in workflow), **`allow_unprotected_ref`** (default `false`, **caller-only**; see above), **`dest_image`** (default `test_complytime/complytime-policies` for POC; set to `continuouscompliance/complytime-policies` for org production when Quay and secrets are ready).
- **Branch scope:** the **`publish-ghcr`** job checks out the **repository default branch** only, so the published content matches vetted `main` (or your renamed default) as required by the spec.
- **Concurrency:** workflow `concurrency.group: publish-policy-oci` and **`cancel-in-progress: false`** (serialize overlapping runs; document if you change this).
- **Immutability:** promote uses `fail_if_dest_exists: true` (org default) so a duplicate `dest_tag` on Quay fails the run. Choose a new **`release_tag`** for each public release.
- **Overlapping runs:** a second **Run workflow** while one is in flight **waits** (same concurrency group) instead of starting a second full publish, reducing races on staging/promote.

## Who may run the workflow (FR-002)

- By default, anyone with **GitHub Actions: write**-equivalent access to this repository can run **`workflow_dispatch`** in this org’s settings.
- If you need **Environment** protection rules (e.g. required reviewers before promote), add a `publish` (or `production`) **Environment** in GitHub, attach the **promote** job to that environment, and list the environment name in this section once configured.

## Operator checklist (User Story 2)

1. **Publish** job: confirm **Pack and push to GHCR** and **Keyless sign staging image** completed; the digest comes from the composite action, then `cosign sign` (OIDC) so promote can verify.
2. **Promote** job: `verify_signature` is **on** (see [Pinned action references](#pinned-action-references)); expect **cosign verify** on the **staging** digest. If verify still fails at **“Verify source signature”**, check identity/regex alignment with the org workflow in [`specs/001-policy-oci-publish/research.md`](specs/001-policy-oci-publish/research.md) §5, or a **documented exception** with scope and sunset per the spec’s **Clarifications**.
3. On success, note the **Promote** log output **digest** / full image ref for the public Quay image.

**Optional** org vulnerability/reviewer workflows (**FR-008**): not wired in v1; if enabled later, set inputs only in line with the org reusable contract and document here.

## Interim POC / verification (SC-003)

**Interim values for a fork / demo run** (matches [FR-006](#pinned-action-references-fr-006)):

| Piece | Interim value |
|-------|----------------|
| Pack + push (in-repo staging job) | `sonupreetam/gemara-publish-oci@7203d6158a16208a0338cc33ea001bb077f4705c` |
| org-infra (sign + Quay only) | `complytime/org-infra@9205a3ac6b76b75dbe6e22b2f0f330bc8edbeb38` |
| Test Quay repository | `quay.io/test_complytime/complytime-policies` (workflow default **`dest_image`**: `test_complytime/complytime-policies`) |

**Local static check (before pushing):** from the repo root, `bash scripts/verify-interim-demo.sh` (validates YAML, public org-infra reuses pin, test-Quay default, and the Gemara composite pin in the workflow file).

**GitHub end-to-end:**

1. Add repository **Actions** secrets: `QUAY_ROBOT_USERNAME`, `QUAY_ROBOT_TOKEN` (robot must **push** to `quay.io/repository/…` for the default `dest_image` path).
2. **Actions → Publish policy OCI → Run workflow:** set a **new** `release_tag` (e.g. `demo-0.0.1`); with `fail_if_dest_exists: true`, reusing an existing dest tag will fail.
3. **Forks / unprotected default branch:** set **`allow_unprotected_ref`** to `true` so the **`publish-ghcr`** staging job (and attestation steps) are not skipped. For **`reusable_sign_and_verify`**, also ensure the default branch is **protected** in that repo (or see [Unprotected default branch](#unprotected-default-branch-forks--public-org-infra-pins)); public org-infra does not take `allow_unprotected_ref` on that `uses:` line.
4. Leave **`dest_image`** at the default to target the **test** Quay repo above, or set **`continuouscompliance/complytime-policies`** when the org robot is scoped to production.
5. On success, copy **GHCR** and **Quay** digests from the logs; paste into release notes or a PR comment for **SC-003** evidence.

## Consumers (FR-005)

Public images for the **ComplyTime** org are expected at `quay.io/continuouscompliance/complytime-policies` (set **`dest_image`** on dispatch when promoting there; the default is **`quay.io/test_complytime/complytime-policies`** for POC / fork demos). Step-by-step **fetch / verify** examples: [`specs/001-policy-oci-publish/quickstart.md`](specs/001-policy-oci-publish/quickstart.md) (or use **`complyctl get`** as documented in ComplyTime when aligned with the published tag).

**Examples in this file:** image refs are labeled **(placeholder — replace after first real release run)** where the exact tag/digest must come from a successful publish log.

## Migration (interim action) — SC-004

- Track the move from the interim **`sonupreetam/gemara-publish-oci@…`** pin to a **complytime** / **gemaraproj**-owned composite action: open a repository issue, link the **FR-006** exit criteria, and update **Pinned action references** in this file when the pin flips.

## E2E demonstration (SC-003)

Follow **[Interim POC / verification](#interim-poc--verification-sc-003)**; after a green run, record the staging (**GHCR**) and public (**Quay**) digests (issue/PR, release note, or this file if maintainers keep a log here).

---

## Governance content (existing)

### Catalogs

- [Branch Protection Catalog](governance/catalogs/ampel-branch-protection-catalog.yaml)

### Policies

- [Branch Protection Policy](governance/policies/ampel-branch-protection-policy.yaml)

## Usage (CLI)

```bash
complyctl get
```

## License

This project is licensed under the Apache License 2.0; see the [LICENSE](LICENSE) file.
