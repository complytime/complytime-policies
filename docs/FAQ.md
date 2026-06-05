# Frequently Asked Questions

**Question:** If I am using Gemara, do I need to know [CUE](https://cuelang.org/)?
**Answer:** Nope. CUE is for expressing the schemas and for validation. All you need to know is YAML.

**Question:** How does complyctl work?
**Answer:** Check out the [complyctl overview](complyctl-overview.md). It fetches policies from the OCI registry, resolves dependency graphs, dispatches to providers, and produces compliance reports.

**Question:** What are providers?
**Answer:** See [complytime-providers](complytime-providers-overview.md) for more details.

**Question:** What is a Policy (capital "P")?
**Answer:** A [Gemara Policy](COMMON-TERMS.md#gemara-policy) describes **rules** and what needs to be assessed in **natural language**. It defines scope, timelines, risk appetite, and which controls apply to an organization.

**Question:** What is a policy (lowercase "p")?
**Answer:** A policy is the **operational logic** — code written in a query language (e.g., [Rego](COMMON-TERMS.md#rego)) — that a [policy engine](COMMON-TERMS.md#opa-open-policy-agent) evaluates against structured input to produce a pass/fail decision.

**Question:** What is the Gemara-equivalent to cross-walking?
**Answer:** The Mapping Document Schema is the logical equivalent to cross-walking in the Gemara Model. A regulation like the European Union Cyber Resilience Act can overlap with other frameworks and standards like ISO 27001, etc. The overlap can be expressed in a Gemara MappingDocument to describe the relationships between the two frameworks.

**Question:** What is a Policy Engine?
**Answer:** The complytime-providers are examples of policy engines like AMPEL and OPA. They are decision makers. The policy engine interprets "policies" (e.g., checks or rules) and determines whether specific actions or behaviors comply with them. The providers essentially take the information that is stored and generated and determine how to evaluate whether the policy _IS_ or _IS NOT_ being satisfied.

**Question:** My auditor wants a format that complyctl doesn't support. What do I do?
**Answer:** complyctl currently supports [four output formats](complyctl-overview.md#for-audit-program-managers-evidence-collection): OSCAL assessment-results (JSON), SARIF, Markdown, and EvaluationLog (YAML). If your auditor requires a different format, you can post-process the OSCAL or EvaluationLog output — both are structured and machine-readable. Gemara and OSCAL have a growing ecosystem of conversion tools.

**Question:** What happens if my target system has changed between scans?
**Answer:** complyctl scans the target system as it exists at scan time — it evaluates current state, not historical state. If the system has changed (e.g., new services deployed, configurations modified), the scan results will reflect the new state. [Policies are versioned](complyctl-overview.md#for-compliance-managers) with digest pinning, so the same controls are evaluated consistently even as the target changes. Comparing scan results across time shows what drifted. See also: [complyctl overview](complyctl-overview.md#for-audit-program-managers-evidence-collection) and [providers overview](complytime-providers-overview.md#how-it-fits-your-program).

**Question:** Can I integrate my own policy engine?
**Answer:** Yes. [Providers](complytime-providers-overview.md) are standalone executables that communicate with complyctl over gRPC using the HashiCorp go-plugin protocol. A provider implements three RPCs — `Describe`, `Generate`, and `Scan` — and is discovered by naming convention (`complyctl-provider-*`) in `~/.complytime/providers/`. You can write a provider that wraps any policy engine or scanning tool. See the [complyctl overview](complyctl-overview.md#for-engineers--devops) for details on the plugin interface.

**Question:** Where can I find more resources to learn about Gemara?
**Answer:** The [_Introducing the Gemara Model_](https://openssf.org/blog/2026/03/09/introducing-the-gemara-model/) blog introduces the whitepaper and links several resources for easy access.

**Question:** Does Layer 3 require Layer 2 to be completed first?
**Answer:** No. Layer 3 compliance processes do not have a hard requirement to depend on Layer 2. However, Layer 3 does require at least Layer 1 or Layer 2 to be completed as a prerequisite. In other words, you can go from Layer 1 directly to Layer 3 without completing Layer 2, but you cannot start Layer 3 without any prior layer work.

**Question:** Are the boundaries between compliance layers rigid?
**Answer:** No. The boundaries between compliance layers are "soft" and iterative rather than rigid. Teams can move fluidly between layers as their compliance program matures, revisiting and refining earlier layers as needed.

**Question:** What is the difference between Layer 2 and Layer 3?
**Answer:** Layer 2 is technology-based. If a piece of guidance is technology-specific and you need to write a Rego policy for it, that is the trigger to use a Layer 2 control catalog. Layer 3 is for overriding assessment requirements. It allows a team to tighten constraints when adapting a standard commercial control catalog to a more stringent environment (such as FedRAMP) without needing to rewrite the entire catalog.
---

**See also:** [Common Terms](COMMON-TERMS.md) | [Gemara Lexicon](https://github.com/gemaraproj/gemara/blob/main/docs/lexicon.yaml) | [complyctl Overview](complyctl-overview.md) | [Back to Resources](README.md)