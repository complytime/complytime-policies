# complyctl Overview

## For Engineers / DevOps

**complyctl** is a CLI that automates compliance scanning against policies pulled from [OCI](COMMON-TERMS.md#oci-open-container-image) registries. You define your [policies](COMMON-TERMS.md#gemara-policy) and scan targets in a `complytime.yaml` workspace file, then run a handful of commands:

```bash
complyctl init          # scaffold complytime.yaml
complyctl get           # pull policies from OCI registry (digest-based incremental sync)
complyctl generate      # resolve policy dependency graph, dispatch configs to providers
complyctl scan prod     # run scans against a target, output reports
complyctl doctor        # pre-flight diagnostics
```

**Providers** are standalone executables (`complyctl-provider-*`) discovered by naming convention in `~/.complytime/providers/` and accessed over gRPC (HashiCorp go-plugin). They implement `Describe`, `Generate`, and `Scan` RPCs -- you can write your own. Policies are cached locally as OCI Layouts under `~/.complytime/policies/`.

Scan output lands in `.complytime/scan/` in your choice of format: EvaluationLog (YAML, default), Markdown, OSCAL assessment-results (JSON), or SARIF. Set `COMPLYTIME_EXPORT_ENABLED=true` to push evidence to an [OpenTelemetry Collector](COMMON-TERMS.md#opentelemetry-collector). Target-scoped variables support `${ENV_VAR}` expansion for secrets.

It fits into CI pipelines -- `complyctl get && complyctl scan --policy-id nist --format sarif` gives you machine-readable results with a non-zero exit on failure.

---

## For Compliance Managers

**complyctl** turns compliance policies into automated, repeatable scans that produce standardized reports -- removing the manual gap between "we have a policy" and "we can prove we follow it."

**How it works:** You publish your compliance policies (NIST 800-53, CIS benchmarks, or custom frameworks) to an [OCI registry](COMMON-TERMS.md#oci-open-container-image) using the [Gemara](https://gemara.openssf.org/) format. Engineering teams pull those policies with `complyctl get` and run `complyctl scan` against their systems. The tool resolves policy dependency graphs, dispatches checks to the appropriate scanning [providers](complytime-providers-overview.md), and produces reports.

**What you get:** Reports in OSCAL assessment-results format (the NIST standard for machine-readable compliance data), SARIF (for integration with developer tooling), human-readable Markdown, or structured EvaluationLog YAML. Each report maps findings back to specific controls with pass/fail/skip status, [confidence levels](COMMON-TERMS.md#confidence-level), and detailed messages.

**Policy-as-code:** Policies live in a versioned registry with digest-based integrity. When you publish an updated policy, teams pull the new version and re-scan -- no manual coordination needed. The `complytime.yaml` workspace file pins policy versions so you control when teams adopt updates.

**Evidence export:** With [OpenTelemetry Collector](COMMON-TERMS.md#opentelemetry-collector) integration, scan evidence flows automatically to a central collector for continuous compliance monitoring.

---

## For Audit Program Managers (Evidence Collection)

**complyctl** produces structured, timestamped compliance evidence that maps directly to control frameworks -- ready for audit review without manual reformatting.

**Evidence artifacts:** Each scan generates reports in `.complytime/scan/` with auto-generated filenames including policy ID and timestamp (e.g., `assessment-results-nist-800-53-r5-20260512T143022.json`). Available formats:

| Format | Use case |
|--------|----------|
| **OSCAL** (JSON) | NIST-standard assessment-results; machine-readable, cross-tool compatible |
| **SARIF** (JSON) | Integrates with code analysis platforms for developer-facing evidence |
| **Markdown** | Human-readable reports with control-level pass/fail, confidence scores, and messages |
| **EvaluationLog** (YAML) | Structured raw data with per-control results, steps, and evaluator metadata |

**Traceability chain:** Every finding traces back through: control ID in the policy framework, the evaluator (provider) that assessed it, the target system scanned, and the policy version used. OSCAL output includes finding UUIDs, observation timestamps, and assessed-control mappings -- the building blocks for a continuous compliance workflow.

**Repeatability:** Because policies are versioned in an OCI registry with digest pinning, you can re-run the exact same assessment months later and get comparable results. The `complytime.yaml` workspace file serves as the audit-reproducible configuration record.

**Centralized evidence:** With [OpenTelemetry Collector](COMMON-TERMS.md#opentelemetry-collector) OTLP export enabled, evidence flows to a central collector automatically after each scan -- supporting continuous monitoring programs without requiring teams to manually submit artifacts.

---

**See also:** [Common Terms](COMMON-TERMS.md) | [Gemara Lexicon](https://github.com/gemaraproj/gemara/blob/main/docs/lexicon.yaml) | [FAQ](FAQ.md) | [Back to Resources](README.md)
