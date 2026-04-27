# Design: Policy OCI publish pipeline (Option 3)

## Context

Policy content under `governance/` and `bundles/` should publish as Gemara OCI artifacts with
consistent security controls. Current patterns split pack/push, sign/verify, and promote behavior
across multiple reusables and caller-owned steps. Option 3 consolidates these responsibilities in
`oci-artifact`, and `complytime-policies` becomes a thin caller.

The artifact contract (`bundle.Pack`, manifest/media types) continues to belong to go-gemara and
must not be redefined in this repository.

**Stakeholders:** maintainers (release UX), platform/security (signing and registry controls),
consumers (reliable fetch and verify).

## Goals / Non-Goals

**Goals**

- Define one standardized publish contract in `oci-artifact` for bundle publishing.
- Keep `complytime-policies` workflows minimal (inputs, trigger, and secret forwarding only).
- Enforce explicit sign and verify behavior for promoted artifacts.
- Reduce cross-repo moving parts and debug surface for release incidents.

**Non-Goals**

- Implement bundle layout logic in `complytime-policies`.
- Maintain separate one-off promote logic in every caller repository.
- Store secret values in docs or workflow source.

## Architecture

### 1) `oci-artifact` as publish owner

`oci-artifact` provides the callable unit (composite action or reusable workflow) that performs:

1. Pack Gemara bundle from root file path.
2. Push to GHCR staging.
3. Sign and verify staged digest.
4. Promote/copy to Quay.
5. Ensure destination verification semantics are met (copy referrers or re-sign destination).
6. Return stable outputs (`image`, `digest`, `source_ref`, `dest_ref`, `verified`).

### 2) `complytime-policies` as thin caller

`complytime-policies` contains only:

- Release trigger policy (`workflow_dispatch` and/or tag rules).
- Input mapping (`bundle_file`, `release_tag`, destination image path).
- Permission and secret pass-through expected by `oci-artifact`.
- Optional environment protection gates.

No direct caller-owned oras copy or cosign choreography remains in this repo.

### 3) Credential model

Credentials are passed by caller workflow secrets:

- GHCR token (typically `GITHUB_TOKEN` for package write in repo scope).
- Quay robot username/token from repo or org action secrets.

The called interface documents secret names and minimum permissions, while keeping values external.

## Decisions

1. **Choose Option 3 as default path**  
   - **Choice:** centralize full publish pipeline in `oci-artifact` and consume from this repo.  
   - **Rationale:** lowest long-term maintenance and cleanest contract for additional bundle repos.  
   - **Alternative rejected:** caller-level standalone scripts as primary solution.

2. **Single publish interface contract**  
   - **Choice:** define stable inputs/outputs and a versioned `uses:` reference.  
   - **Rationale:** callers upgrade by pin bump, without internal workflow rewrites.

3. **Destination trust behavior is explicit**  
   - **Choice:** `oci-artifact` must either preserve signature/referrer graph or re-sign Quay refs.  
   - **Rationale:** avoids false confidence from copying payload only.

4. **Release controls stay with caller**  
   - **Choice:** trigger restrictions and environment gates remain in `complytime-policies`.  
   - **Rationale:** per-repo governance and release ownership stay local.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| `oci-artifact` interface churn breaks callers | Pin versions, publish changelog, treat input/output changes as breaking. |
| Referrer/signature copy varies by registry behavior | Add integration test path in `oci-artifact` covering GHCR -> Quay verification. |
| Over-centralization slows urgent fixes | Keep fallback standalone workflow documented for emergency rollback only. |
| Secret name mismatch between repos | Define canonical secret contract and validate missing secrets early. |

## Migration Plan

1. Implement the full publish interface in `oci-artifact`.
2. Validate end-to-end from test bundle to GHCR and Quay with signature verification expectations.
3. Switch `complytime-policies` workflow(s) to call the new interface.
4. Remove redundant caller-owned sign/promote/copy steps.
5. Update docs and run one release rehearsal.

**Rollback:** temporarily route releases to the existing standalone caller workflow while keeping the
same artifact naming and release tags.

## Open Questions

- Should `oci-artifact` expose one reusable workflow only, or both reusable + composite layers?
- Is Quay verification required to pass with copied referrers, or is destination re-sign acceptable?
- Which outputs are mandatory for downstream audit records (digest only vs source+dest refs)?
