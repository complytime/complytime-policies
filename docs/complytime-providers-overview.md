# ComplyTime Providers Overview

`complytime-providers` contains two compliance scanning tools
that plug into a central compliance CLI called `complyctl`. Each
tool — called a "provider" — checks a different type of
infrastructure against security requirements and reports
standardized results.

The two providers are:

- **OpenSCAP** — scans operating system configurations against
  security benchmarks (CIS, STIG, PCI-DSS, HIPAA, NIST)
- **AMPEL** — checks code repository branch protection policies
  on GitHub and GitLab

---

## What this does for your compliance program

The two providers evaluate technical controls and report results
in a consistent format. They are plugins for `complyctl`, a
compliance-as-code command-line tool.

| Provider | What it checks | Standards supported |
|----------|---------------|---------------------|
| OpenSCAP | Operating system configurations (passwords, permissions, services, firewall rules) | CIS Benchmarks, DISA STIGs, PCI-DSS, HIPAA, NIST |
| AMPEL | Code repository settings (branch protection, merge requirements) | Custom policy bundles for GitHub and GitLab |

### How it fits your program

- **Requirement mapping** — Each provider maps its checks to
  specific compliance requirement IDs from your control
  framework. Scan results tell you exactly which requirements
  passed and which failed.
- **Repeatable assessments** — Scans are automated and
  deterministic. The same configuration produces the same checks
  every time, eliminating manual testing variability.
- **Continuous compliance** — Because scans are scripted, they
  can run on a schedule (for example, in CI/CD pipelines). This
  gives you ongoing visibility into your compliance posture
  rather than point-in-time snapshots.
- **Evidence trail** — Scan results can be exported to a
  centralized evidence collector, creating an auditable record
  of every assessment.

### What it does not do

This tool evaluates technical controls. It does not manage
policies, track exceptions, or handle risk acceptance workflows.
It tells you whether a system meets a technical requirement and
leaves the risk management decisions to you.

---

**See also:** [Common Terms](COMMON-TERMS.md) | [complyctl Overview](complyctl-overview.md) | [FAQ](FAQ.md) | [Back to Resources](README.md)
