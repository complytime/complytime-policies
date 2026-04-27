# Tasks: policy-oci-publish

## 1. Define Option 3 contract in `oci-artifact`

- [ ] 1.1 Create/extend the `oci-artifact` reusable publish interface to own:
      pack + GHCR push + sign + verify + Quay promote
- [ ] 1.2 Define stable interface inputs/outputs (bundle file, tag, image names, verify flags,
      refs/digest outputs) and document required permissions and secrets
- [ ] 1.3 Implement destination trust behavior explicitly (copy referrers if supported or re-sign
      destination) and document which mode is used
- [ ] 1.4 Add failure-fast checks for missing secrets/permissions and clear error messages

## 2. Switch `complytime-policies` to thin caller mode

- [ ] 2.1 Update policy publish workflow(s) to invoke only the versioned `oci-artifact` interface
- [ ] 2.2 Remove caller-owned oras/cosign/promotion steps that are now centralized upstream
- [ ] 2.3 Keep local release governance controls (trigger restrictions, env gates, approvals)
- [ ] 2.4 Pin `uses` to a commit SHA or stable tag and track upgrade policy

## 3. Documentation updates

- [ ] 3.1 Document Option 3 architecture and caller responsibilities in this repository
- [ ] 3.2 Document `oci-artifact` interface reference (current pin, interim/stable status, upgrade
      criteria)
- [ ] 3.3 Document required secret names/scopes without values
- [ ] 3.4 Document consumer usage: source/destination refs, version/digest lookup, verify commands

## 4. Verification and rollout

- [ ] 4.1 Run an end-to-end release rehearsal using the new interface (test tag/path)
- [ ] 4.2 Verify logs and outputs include expected digest/source/destination refs
- [ ] 4.3 Validate verification behavior for destination artifacts matches documented trust model
- [ ] 4.4 Capture follow-up issues for interface hardening or migration off interim pins
