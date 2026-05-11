# Frequently Asked Questions

**Question:** If I am using Gemara, do I need to know CUE?
**Answer:** Nope. CUE is for expressing the schemas and for validation. All you need to know is YAML.

**Question:** Is ComplyTime a Product?
**Answer:** No. Not at this time at least. ComplyTime is a platform of tools that are interoperable with one another. When we say "ComplyTime" we are talking about the ecosystem of interoperable tools that are used for continuous monitoring, scanning of workspace configurations using bundled OCI artifacts (e.g., Gemara Policies and Catalogs), and results that can be leveraged for a full decision and evaluation log to produce compliance report.

**Question:** How does complyctl work?
**Answer:** Check out the [complyctl section](complyctl-overview.md). Starting by fetching policies from the OCI registry, resolving dependency graphs, dispatch to providers, produce compliance reports

**Question:** What are providers?
**Answer:** See [complytime-providers](complytime-providers-overview.md) for more details.

**Question:** What is the difference between capital "P" Policy and lowercase "p" policy?
**Answer:** Capital "P" Policy describes **rules** and what needs to be assessed in **natural language**. Lowercase "p" policy is the **operational logic** to evaluate structured input in **query language**. 

**Question:** What is the Gemara-equivalent to cross-walking?
**Answer:** The Mapping Document Schema is the logical equivalent to cross-walking in the Gemara Model. A regulation like the European Union Cyber Resilience Act can overlap with other frameworks and standards like ISO 27001, etc. The overlap can be expressed in a Gemara MappingDocument to describe the relationships between the two frameworks.

**Question:** What is a Policy Engine? 
**Answer:** the complytime-providers are examples of policy engines like AMPEL and OPA. They are decision makers. The policy engine interprets "policies" (e.g., checks or rules) and determines whether specific actions or behaviors comply with them. The providers essentially take the information that is stored and generated and determine how to evaluate whether the policy _IS_ or _IS NOT_ being satisfied. 

**Question:** How does OPA work?
**Answer:** In three steps, OPA uses **Query**, **Data + Policy**, and **Decision**. The **query** would be a question like "Can USER Camille delete this file?" OPA looks at **Policy (rules)** and the **Data (info about Camille and the file)**. Then OPA sends back a **decision** "Yes" or "No" (or even complex responses like "Yes, but only if she's using the VPN").

---

**See also:** [Common Terms](COMMON-TERMS.md) | [Gemara Lexicon](gemara-lexicon.md) | [complyctl Overview](complyctl-overview.md) | [Back to Resources](README.md)