# complytime-policies

Centralized [Gemara](https://github.com/gemaraproj/gemara) policies for [ComplyTime](https://github.com/complytime) tooling. Content is published as OCI to **Quay.io** and consumed with `complyctl get` (and similar clients).

## Layout

```text
complytime-policies/
├── governance/catalogs/   # Control catalogs
├── governance/policies/  # Policies
└── bundles/              # Bundle roots (publish inputs)
```

## Releasing

Manual publish: [`.github/workflows/publish-policy-oci.yml`](.github/workflows/publish-policy-oci.yml) (Actions → **Publish policy OCI**). Operator steps, inputs, and the pinned action are documented in [`specs/001-policy-oci-publish/quickstart.md`](specs/001-policy-oci-publish/quickstart.md).

**Secrets (repository):** `QUAY_ROBOT_USERNAME`, `QUAY_ROBOT_TOKEN`. GHCR uses `GITHUB_TOKEN` from the workflow. Forks need their own secrets.

## Usage

```bash
complyctl get
```

## License

Apache-2.0. See [LICENSE](LICENSE).
