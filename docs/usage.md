# Consuming Published Policy Artifacts

Policy content in this repository is published as **OCI artifacts** to
[Quay.io](https://quay.io). These are **not** container images — they are
multi-layer OCI bundles assembled by [go-gemara](https://github.com/gemaraproj/go-gemara)
and must be pulled with an OCI-native tool such as
[ORAS](https://oras.land), [skopeo](https://github.com/containers/skopeo),
or [complyctl](https://github.com/complytime/complyctl).

## What is published

Each published artifact is a Gemara **bundle** built from a root Policy YAML
under `governance/policies/`. The bundle contains multiple layers representing
the policy and all of its resolved dependencies:

| Layer | Example file | Description |
|-------|-------------|-------------|
| Policy | `cis-fedora-l1-workstation-policy.yaml` | Root policy defining controls and their mapping references |
| Catalog | `cis-fedora-l1-workstation-catalog.yaml` | Security control catalog resolved from the policy's `mapping-references` |
| Guidance | `cis-fedora-l1-guidance.yaml` | Best-practice guidance resolved from the policy's `mapping-references` |

### OCI media types

| Property | Value |
|----------|-------|
| Manifest media type | `application/vnd.oci.image.manifest.v1+json` |
| Artifact type | `application/vnd.gemara.bundle.v1` |
| Layer media type (YAML content) | `application/vnd.gemara.layer.v1+yaml` |

### Registries

Each bundle is published to its own repository under the organization namespace.

| Registry | Purpose | Example reference |
|----------|---------|-------------------|
| `ghcr.io` | Staging (internal) | `ghcr.io/complytime/complytime-policies/policies-cis-fedora-l1-workstation:latest` |
| `quay.io` | Public destination | `quay.io/complytime/policies-cis-fedora-l1-workstation:latest` |

See [ADR-0001](adr/0001-one-quay-repo-per-bundle.md) for the rationale behind one
repository per bundle.

### Published bundles

| Bundle | Quay repository | Provider |
|--------|-----------------|----------|
| `ampel-branch-protection` | `quay.io/complytime/policies-ampel-branch-protection` | [ampel](https://github.com/complytime/complytime-providers/tree/main/cmd/ampel-provider) |
| `cis-fedora-l1-workstation` | `quay.io/complytime/policies-cis-fedora-l1-workstation` | [openscap](https://github.com/complytime/complytime-providers/tree/main/cmd/openscap-provider) |
| `cis-fedora-l1-server` | `quay.io/complytime/policies-cis-fedora-l1-server` | [openscap](https://github.com/complytime/complytime-providers/tree/main/cmd/openscap-provider) |

## Tags

Publishing happens automatically on push to `main` (when `bundles/` or
`governance/` files change) and can also be triggered manually via
`workflow_dispatch`.

| Tag | Mutability | Use case |
|-----|------------|----------|
| `latest` | Mutable | Tracks the most recent publish from `main` |
| `v1.0.0` (semver) | Immutable | Versioned releases via `workflow_dispatch` with `version` input |
| `@sha256:...` (digest) | Immutable | Strongest guarantee — always returns exact bytes |

For production and compliance use cases, prefer a digest-pinned or
semver-pinned reference over `latest`.

## Pulling the artifact

Use [ORAS CLI](https://oras.land/docs/installation) (v1.2+):

```bash
oras pull quay.io/complytime/policies-cis-fedora-l1-workstation:latest -o ./output
```

The extracted files are the raw Gemara YAML layers (policy, catalog, guidance).

### Resolving the digest

```bash
oras resolve quay.io/complytime/policies-cis-fedora-l1-workstation:latest
```

This returns the `sha256:…` digest, which you can use for immutable references:

```bash
oras pull quay.io/complytime/policies-cis-fedora-l1-workstation@sha256:<digest> -o ./output
```

> **Note:** ORAS, cosign, and curl use standard OCI reference syntax
> (`:tag` and `@sha256:digest`). `complyctl` uses its own `@tag` convention
> in `complytime.yaml` — see the [Using with complyctl](#using-with-complyctl)
> section below.

## Verifying the Cosign signature

All artifacts are signed with [keyless Cosign](https://docs.sigstore.dev/cosign/signing/overview/)
via GitHub Actions OIDC. Verify with:

```bash
cosign verify \
  --certificate-identity-regexp="https://github.com/complytime/complytime-policies/.github/workflows/" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  quay.io/complytime/policies-cis-fedora-l1-workstation:latest
```

A successful output confirms the artifact was produced by the
`complytime/complytime-policies` GitHub Actions workflow and has not been
tampered with since signing.

> **Tip:** Replace `:latest` with a `@sha256:<digest>` reference for the
> strongest verification guarantee.

## Verifying the artifact

Quay's package UI may appear sparse for custom OCI media types. The ORAS
CLI checks below are authoritative.

### Fetch the manifest

```bash
oras manifest fetch quay.io/complytime/policies-cis-fedora-l1-workstation:latest \
  | jq '{mediaType, artifactType, layers: [.layers[] | {mediaType, digest, size}]}'
```

### Verify each layer blob is retrievable

```bash
oras manifest fetch quay.io/complytime/policies-cis-fedora-l1-workstation:latest \
  | jq -r '.layers[].digest' \
  | while read -r d; do
      echo "checking $d"
      oras blob fetch quay.io/complytime/policies-cis-fedora-l1-workstation@"$d" --output /dev/null \
        && echo "  ok" || echo "  FAILED"
    done
```

If these checks pass but the Quay UI still looks sparse, treat the artifact
as valid.

## Using with complyctl

[complyctl](https://github.com/complytime/complyctl) can consume Gemara
bundles directly from the OCI registry. Point the policy source at a
published bundle in `complytime.yaml`:

```yaml
# complytime.yaml
policies:
  - url: quay.io/complytime/policies-ampel-branch-protection@latest
    id: ampel-bp
```

Then fetch and scan:

```bash
complyctl get
complyctl scan --policy-id ampel-bp
```

See the
[complyctl Quick Start](https://github.com/complytime/complyctl/blob/main/docs/QUICK_START.md)
for installation, full `complytime.yaml` reference, and output formats.

### Bundle providers

Each provider has its own prerequisites, `complytime.yaml` variables, and
setup instructions:

| Bundle | Provider | What it evaluates |
|--------|----------|-------------------|
| `ampel-branch-protection` | [ampel](https://github.com/complytime/complytime-providers/tree/main/cmd/ampel-provider) | GitHub / GitLab branch protection rules |
| `cis-fedora-l1-workstation` | [openscap](https://github.com/complytime/complytime-providers/tree/main/cmd/openscap-provider) | CIS Fedora L1 Workstation benchmark |
| `cis-fedora-l1-server` | [openscap](https://github.com/complytime/complytime-providers/tree/main/cmd/openscap-provider) | CIS Fedora L1 Server benchmark |

## Further reading

- [complyctl Quick Start](https://github.com/complytime/complyctl/blob/main/docs/QUICK_START.md) — installation, `complytime.yaml` reference, output formats
- [ampel provider docs](https://github.com/complytime/complytime-providers/blob/main/cmd/ampel-provider/docs/configuration.md) — variables, token auth, granular policies
- [openscap provider docs](https://github.com/complytime/complytime-providers/blob/main/cmd/openscap-provider/docs/configuration.md) — variables, profiles, prerequisites
- [complytime-demos](https://github.com/complytime/complytime-demos) — automated VM setup with sample policies
- [Quickstart for maintainers](../specs/001-policy-oci-publish/quickstart.md) — how to run the publish workflow
- [Pipeline contract](../specs/001-policy-oci-publish/contracts/publish-pipeline.md) — action inputs, secrets, and outputs
- [gemara-registry-cli](https://github.com/gemaraproj/gemara-registry-cli) — the composite action that produces the artifact
- [go-gemara](https://github.com/gemaraproj/go-gemara) — the SDK that assembles bundles
