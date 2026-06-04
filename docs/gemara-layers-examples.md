# Gemara Layers: Real-World Examples and GRC Equivalents

This document maps each Gemara layer to concrete examples from the ComplyTime governance artifacts and to equivalent concepts in traditional GRC (Governance, Risk, and Compliance) platforms.

For the full layer definitions, see [Common Terms: Gemara Project](COMMON-TERMS.md#gemara-project).

---

## Layer 1 -- Guidance

**What it is:** High-level requirements from regulators, standards bodies, or organizational best practices. Guidance is technology-aware but not directly testable -- it describes _what_ an organization should do, not _how_ to verify it.

**Real-world example:** The [CIS Fedora Linux Level 1 Guidance](../governance/guidance/cis-fedora-l1-guidance.yaml) is a GuidanceCatalog. It contains statements such as:

> "Organizations MUST configure separate partitions for /tmp, /dev/shm, /home, /var, /var/tmp, /var/log, and /var/log/audit with appropriate mount options (nodev, nosuid, noexec) to limit the impact of filesystem-based attacks."

These statements set expectations but do not define the specific checks an evaluator would run.

**GRC equivalent:** Guidance maps to what a GRC platform would call a **framework requirement** or **control objective** -- the high-level statements from standards bodies (NIST 800-53, ISO 27001 Annex A, CIS Controls) that define what an organization must achieve.

---

## Layer 2 -- Threats and Controls

### Capabilities

**What it is:** The functional capabilities a project or system provides. A [CapabilityCatalog](https://github.com/gemaraproj/gemara/blob/main/capabilitycatalog.cue) enumerates the features, components, or objects that define what a system can do. Capabilities expose the attack surface that threats target -- you cannot model threats without first knowing what a system is capable of.

**Real-world example:** For the branch protection use case, capabilities would include:

| Capability | Description |
|-----------|-------------|
| Pull request workflow | Accept, review, and merge code changes via pull requests |
| Branch protection rules | Configure restrictions on who can push, merge, or force-push to branches |
| Code review enforcement | Require peer approval before changes are merged |
| Audit logging | Record repository events for accountability and forensic review |

Each capability is assigned to a group within the catalog. The [schema](https://github.com/gemaraproj/gemara/blob/main/capabilitycatalog.cue) enforces that every capability references a valid group, ensuring consistent categorization.

**GRC equivalent:** Capabilities map to an **asset inventory** or **system capability register** in a GRC platform -- the documented record of what a system does, which informs threat modeling and control selection.

### Threats

**What it is:** Things that could go wrong based on the project's capabilities. Threats inform which controls are necessary and feed into the risk analysis.

**Real-world example:** For the branch protection use case, threats would include:

- Unauthorized code reaching production via direct push to a protected branch
- Malicious changes merged without peer review
- History rewritten via force push, destroying audit trail

These threats drive the selection of controls like BP-1 (require PR reviews) and BP-3 (restrict force pushes).

**GRC equivalent:** Threats map to entries in a **threat model** or **risk register** that describe what could go wrong for a given system.

### Controls

**What it is:** Technology-specific, assessable security requirements. Each control includes assessment requirements that can be evaluated by a scanning provider. If you cannot write a testable check for it, it belongs in Layer 1.

**Real-world example:** The [Branch Protection Catalog](../governance/catalogs/ampel-branch-protection-catalog.yaml) is a ControlCatalog. It defines controls like:

| Control | Objective | Assessment Requirement |
|---------|-----------|----------------------|
| BP-1: Require Pull Request Reviews | Changes to protected branches go through a pull request process | BP-1.01: Direct pushes to protected branches MUST be blocked |
| BP-2: Require Minimum Approvals | Pull requests must have a minimum number of approvals | BP-2.01: Pull requests must require a minimum number of approvals |
| BP-3: Restrict Force Pushes | Force pushes to protected branches must be blocked | BP-3.01: Force pushes to protected branches must be blocked |

Each requirement specifies applicability (GitHub repositories, GitLab repositories) and can be evaluated by the [Ampel](COMMON-TERMS.md#ampel) provider.

**GRC equivalent:** Controls map to **technical controls** or **security requirements** in a GRC platform -- the specific, assessable items that auditors check.

---

## Layer 3 -- Risk and Policy

**What it is:** The organizational record of risk appetite, risk acceptance, and controls chosen to mitigate or accept identified risks. Risks pull in associated controls that satisfy mitigation of the threats imposed on the system.

**Real-world example:** A RiskCatalog for the branch protection scenario would document decisions such as:

- "The organization accepts the risk of not enforcing code-owner review on internal-only repositories (Risk Acceptance) but requires it for all public-facing repositories (Risk Mitigation via control BP-5)."
- "Force push restrictions are mandatory across all repositories regardless of visibility (zero appetite for history tampering)."

**GRC equivalent:** This maps to the **risk register** and **risk treatment plan** in GRC platforms -- the organizational record of identified risks, appetite thresholds, and whether each risk is mitigated, accepted, transferred, or avoided.

---

## Policy

**What it is:** A clearly-scoped set of rules based on an organization's risk appetite. A Policy imports guidance, controls, and risk catalogs; defines assessment plans and timelines; and assigns ownership.

**Real-world example:** The [AMPEL Branch Protection Policy](../governance/policies/ampel-branch-protection-policy.yaml) demonstrates how a Policy ties the layers together:

- **Imports** the Branch Protection ControlCatalog (`repo-branch-protection`)
- **Scopes** to GitHub and GitLab technologies
- **Assigns ownership:** Repository Administrator (responsible), Security Team (accountable)
- **Defines assessment plans** for each control requirement with automated evaluation via Ampel on an on-demand frequency

```yaml
# Excerpt from ampel-branch-protection-policy.yaml
imports:
    catalogs:
        - reference-id: repo-branch-protection
adherence:
    assessment-plans:
        - id: BP-1.01
          requirement-id: BP-1.01
          frequency: on-demand
          evaluation-methods:
              - type: automated
                executor:
                    id: ampel
```

**GRC equivalent:** A Gemara Policy maps to an **organizational policy** or **compliance program** in a GRC platform -- the organization-specific document that adopts controls, defines assessment schedules, assigns ownership, and records scope and risk appetite decisions.

---

## How the Layers Connect

| Gemara Layer | Contains | GRC Equivalent | Example in This Repo |
|-------------|----------|----------------|---------------------|
| Layer 1 -- Guidance | High-level requirements | Framework requirements, control objectives | [CIS Fedora L1 Guidance](../governance/guidance/cis-fedora-l1-guidance.yaml) |
| Layer 2 -- Capabilities | Functional capabilities of a system | Asset inventory, system capability register | _(not yet in repo)_ |
| Layer 2 -- Threats | What could go wrong | Threat model, risk register entries | _(not yet in repo)_ |
| Layer 2 -- Controls | Testable security requirements | Technical controls, security requirements | [Branch Protection Catalog](../governance/catalogs/ampel-branch-protection-catalog.yaml) |
| Layer 3 -- Risk | Risk appetite and treatment decisions | Risk register, risk treatment plan | _(not yet in repo)_ |
| Policy | Scoped rules, ownership, assessment plans | Organizational policy, compliance program | [AMPEL Branch Protection Policy](../governance/policies/ampel-branch-protection-policy.yaml) |

---

**See also:** [Common Terms](COMMON-TERMS.md#gemara-project) | [Gemara Lexicon](https://github.com/gemaraproj/gemara/blob/main/docs/lexicon.yaml) | [Gemara Whitepaper](https://openssf.org/resources/gemara-a-governance-risk-and-compliance-engineering-model-for-automated-risk-assessment/) | [Back to Resources](README.md)
