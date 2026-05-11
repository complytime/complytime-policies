# Lexicon of Terms

A glossary of terms used across the ComplyTime ecosystem. Terms are grouped by topic. If you're brand new, start with [Gemara Project](#gemara-project) and [ComplyTime](#complytime) to orient yourself, then explore other sections as needed.

---

## Table of Contents

- [ComplyTime](#complytime)
- [Gemara Project](#gemara-project)
  - [The Model](#the-model)
  - [Guidance vs. Controls](#whats-the-difference-between-a-guidance-catalog-and-a-control-catalog)
  - [Catalogs by Layer](#catalogs)
  - [Policy](#gemara-policy)
- [OCI (Open Container Image)](#oci-open-container-image)
- [Related Projects](#related-projects)
- [Tools](#tools)

---

## ComplyTime

### complyctl

A compliance runtime that pulls Gemara policies from an OCI registry and executes scans using providers. Currently, the ampel provider is used for verification of branch protection settings on GitHub and GitLab repositories.

<details>
<summary><strong>What can complyctl do for you?</strong></summary>

**Do you assist or lead audit programs and manage evidence collection?** In that case, the best way to think about complyctl is for producing structured, timestamped compliance evidence that maps directly to various frameworks. This makes it ready for audit review without manual reformatting.

**Are you a Compliance Manager focused on Audit preparation?** In that case, think about what complyctl can do for you. Complyctl turns policies into automated, _repeatable_ scans that produce standardized reports. This results in the removal of the manual gap that exists between "we _have_ a policy" and "we can _prove_ that we follow that policy."

**Focused more on Developer workflows and automation?** In that case, it's important to note that complyctl is a CLI that automates compliance scanning against policies pulled from OCI registries. You define your policies and scan targets in a `complytime.yaml` workspace configuration file. Then you run a few commands to pull the policies from the OCI registry, resolve the policy dependency graph, and get providers based on the config. Then you scan against a target and get the output reports.

</details>

See more in the [complyctl overview](complyctl-overview.md).

---

## Gemara Project

### The Model

**Gemara** — the GRC Engineering Model for Automated Risk Assessment. Gemara is defined by The Model which is built on a 7-layer architecture that separates compliance activities into layers. See the [gemara lexicon](gemara-lexicon.md) for more information.

**Gemara Catalog** — general term for one or more of the following: VectorCatalog, PrincipleCatalog, GuidanceCatalog, ControlCatalog, ThreatCatalog, CapabilitiesCatalog, RiskCatalog.

### What's the difference between a Guidance Catalog and a Control Catalog?

**Guidance** is generic — it applies across technologies.
**Controls** are specific, actionable, and assessable for a particular technology.

The test: if you can't write testable conditions for it, it's not a control.

| | **Guidance (Layer 1)** | **Control (Layer 2)** |
|:--|:--|:--|
| Example source | CIS Controls | CIS Benchmark for Linux |
| Scope | Any technology | Specific technology |
| Testable | No | Yes — has Assessment Requirements |
| Says | "Do access management" | "Reduce risk of privilege escalation by disabling direct admin login to remote systems" |

### Catalogs

#### Layer 1 — Guidance

**Gemara Guidance Catalog** — high-level guidance that would come from a regulator, standards body, or unique organization-specific use-cases of best practices.

#### Layer 2 — Threats and Controls

When we talk about Layer 2 catalogs, we are referencing what your project can do, what could go wrong, and the technology-specific security controls that make sure what _could_ go wrong _doesn't_ go wrong.

**Gemara Threat Catalog** — things that could go wrong based on the project capabilities.

**Gemara Control Catalog** — security controls that include testable requirements. If you can't write a check for the control, it likely belongs in Layer 1. However, by breaking down high-level GuidanceCatalog guidance, security controls can be extracted to support compliance with best practices, frameworks, and guidance.

#### Layer 3 — Risk

**Gemara Risk Catalog** — defined by the activities of cataloging risks and developing a register with organizational Risk Appetite, Risk Acceptance, and controls chosen to Mitigate or Accept. The risks identified for mitigation can pull in associated controls that satisfy mitigation of the threats imposed on the system.

**Mapping Document** — rich mappings between a source-reference (mapping from) and target-reference (mapping to) that can be extended by different groups.

### Gemara Policy

A Policy is a clearly-scoped set of rules based on an organization's Risk Appetite. It provides governance rules that, while based on best practices and industry standards, are tailored to an organization. Because policies inevitably introduce some level of Risk Acceptance, they cannot be properly developed without consideration for organization-specific Risk Appetite.

A policy can import other policies and catalogs in support of adherence to a plan. The policy should be time-bound and define the scope, risks, and implementation plan. The Policy imports the Guidance and Controls that can be implemented and tested for satisfaction of compliance requirements, and incorporates the Risk Catalog which catalogs risks, risk appetite, and the strategy for Risk Mitigation vs. Risk Acceptance.

**When we say "it's a Policy"** — if you need to write a timeline for how often something is reviewed or enforced, it's a Policy. The Control Catalog that supports mitigating risks encompasses the testable requirements used to check whether that Policy is being met via Evaluation.

Assessment Requirements from within a Control Catalog can be modified in the Policy. What is the best approach to assessing the Requirement of the Control that is mitigating X Threat?

---

## OCI (Open Container Image)

> When we say "pulling the bundle" or "OCI artifact," this is what we mean:

**OCI Registry** — standardized storage and distribution systems for container images and artifacts. They allow for securely storing, sharing, and managing container images and other OCI-compliant artifacts to ensure consistency and security across the development lifecycle. See [opencontainers.org](https://opencontainers.org/).

**Image** — container images are dependencies, runtimes, and source code that are aggregated as a portable image and can be leveraged across setups. Ideally a container runtime will be spawned in a Docker, Podman, or any other container orchestration system. The goal is to ensure everything works as expected regardless of the hardware stack.

**Manifest** — in terms of OCI artifacts, the manifests have everything needed to use pre-saved content and ensure consistent delivery across different platforms and environments. Container Image manifests can point to other manifests via OCI registry or OCI content-layout. Since OCI artifacts are tagged and pinned to digests, the tag (e.g., `v1.0.0`) will resolve a descriptor that provides additional context on the environment and the artifact (schemas, artifact types, configuration, date of creation, etc.).

**Bundle** — a multi-layer OCI image containing Gemara compliance artifacts — catalog YAML, guidance YAML, and policy/assessment YAML — each distinguished by media type.

**Pulling from a registry** — to pull from a container registry is to essentially extract the bundled content from a manifest that signs the artifact and stores the relevant data alongside the artifact itself. Think of it like downloading a specific folder that includes everything you need. In complyctl, `complyctl get` syncs a Gemara policy artifact from a remote OCI registry to the local OCI Layout store.

---

## Related Projects

[**OSPS Baseline**](https://github.com/ossf/security-baseline/tree/main) — the Open Source Project Security Baseline is designed to act as a minimum definition of requirements for a project relative to its maturity level.

[**FINOS Common Cloud Controls**](https://github.com/finos/common-cloud-controls/tree/main) — an open standard project that describes consistent controls for compliant public cloud deployments in the financial services sector. The standard aims to develop a unified set of cybersecurity, resiliency, and compliance controls for common services across the major cloud service providers.

[**OpenTelemetry**](https://opentelemetry.io/) — an open source observability framework for cloud-native software. It provides a single set of APIs, libraries, agents, and collector services to capture distributed traces and metrics from your application.

**When we say telemetry** — we mean the automated, remote collection and wireless transmission of data from sensors to a central system for monitoring, analysis, and recording (e.g., the data that is populated on the Grafana dashboards).

---

## Tools

### OPA (Open Policy Agent)

OPA stands for Open Policy Agent. It's a policy engine that unifies policy enforcement — used for enforcing policies in microservices, Kubernetes, CI/CD pipelines, API gateways, and more. As simple as **yes** or **no**: OPA acts as the brain for decision-making.

[OPA's Policy Philosophy](https://www.openpolicyagent.org/docs/philosophy) identifies policy as the set of rules governing the behavior of a software service. Policies are essential to the long-term success of organizations because they encode important knowledge about how to comply with legal requirements, work within technical constraints, avoid repeating mistakes, and so on.

> See the [FAQ](FAQ.md) for a minimal example.

### Rego

The high-level declarative language that OPA policies are written in. Rego is a set of **rules** that can be used to assess whether an input request is going to be allowed or denied. It defines what is true or false based on input data.

### Ampel

Ampel is a policy engine that looks at "Attestations" (digital proof) and checks them against "Policies" (rules). Ampel can pull security policies and evidence directly from OCI registries.

---

**See also:** [Gemara Lexicon](gemara-lexicon.md) | [complyctl Overview](complyctl-overview.md) | [FAQ](FAQ.md) | [Back to Resources](README.md)
