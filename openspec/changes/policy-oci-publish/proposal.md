# Proposal: Policy OCI publish pipeline

## Why

ComplyTime policy and governance content in this repository needs a controlled and repeatable path
to publish Gemara bundles as OCI artifacts in Quay. Current approaches split responsibility across
multiple repositories and reusable workflows, which increases coupling, pin churn, and debugging
time. We want one standardized publish contract that handles pack, push, sign, verify, and promote
as a single flow.

**Why now:** the oci-artifact repository already owns Gemara pack and push logic and is the right
home for release-standardization. Moving the full flow there reduces moving parts in
complytime-policies and creates a reusable contract for future bundle publishers.

## What Changes

- Adopt **Option 3** architecture: `oci-artifact` owns the end-to-end publish action/workflow
  (pack + push to GHCR + copy/promote to Quay + sign + verify), while `complytime-policies`
  invokes it as a thin caller.
- Define and document a stable caller interface (inputs, outputs, secret names/scopes,
  permissions, trigger expectations) so policy repositories do not implement publish internals.
- Ensure signature behavior is explicit for both registries: either copy referrers/attachments as
  required or re-sign on destination, with verification behavior documented and tested.
- Update publish documentation for maintainers and consumers: release trigger model, artifact
  locations, version/digest usage, and verification steps.
- Keep out of scope: re-specifying Gemara bundle manifest contracts in this repository, embedding
  secret values, and bespoke per-repo promotion scripts.

**BREAKING:** None for Git content consumers. OCI release behavior becomes standardized through an
external oci-artifact interface.

## Capabilities

### New Capabilities

- `policy-oci-publish`: this repo can publish policy bundles by calling a single standardized
  oci-artifact publish interface, instead of composing multiple independent publish/release steps.

### Modified Capabilities

- Existing policy OCI workflows in this repository become thin wrappers that pass content path,
  tag, and credentials to the shared oci-artifact pipeline.

## Impact

- **This repository:** slimmer workflow definitions, clearer docs, fewer internal publish steps.
- **Dependencies:** pinned oci-artifact publish interface version; upstream go-gemara and oras/cosign
  details remain encapsulated in oci-artifact.
- **Systems:** GHCR staging and Quay destination remain in scope, but signing and promotion logic is
  centralized in oci-artifact.
