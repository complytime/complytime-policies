# Gemara Lexicon

A reference of terms defined by the [Gemara](https://github.com/openssf/gemara) framework for governance, risk, and compliance (GRC) in cybersecurity.

---

## Table of Contents

- [Assessment](#assessment)
- [Assessment Requirement](#assessment-requirement)
- [Audit](#audit)
- [Behavior Evaluation](#behavior-evaluation)
- [Capability](#capability)
- [Catalog](#catalog)
- [Compliance](#compliance)
- [Continuous Monitoring](#continuous-monitoring)
- [Control](#control)
- [Enforcement](#enforcement)
- [Evaluation](#evaluation)
- [Evaluation Finding](#evaluation-finding)
- [Governance](#governance)
- [GRC](#grc)
- [Guidance](#guidance)
- [Guideline](#guideline)
- [Intent Evaluation](#intent-evaluation)
- [Objective](#objective)
- [Opinion](#opinion)
- [Organization](#organization)
- [Policy](#policy)
- [Preventive Enforcement](#preventive-enforcement)
- [Remediative Enforcement](#remediative-enforcement)
- [Residual Risk](#residual-risk)
- [Risk](#risk)
- [Risk Acceptance](#risk-acceptance)
- [Risk Appetite](#risk-appetite)
- [Risk Assessment](#risk-assessment)
- [Risk Catalog](#risk-catalog)
- [Risk Mitigation](#risk-mitigation)
- [Rule](#rule)
- [Sensitive Activity](#sensitive-activity)
- [Threat](#threat)
- [Vector](#vector)
- [Vulnerability](#vulnerability)
- [Terms by Layer](#terms-by-layer)

---

## Assessment

**(1)** the process of determining whether an outcome meets the actor's intent; or **(2)** an atomic process within an [Evaluation](#evaluation) used to determine a resource's [Compliance](#compliance) with an [Assessment Requirement](#assessment-requirement)

> **Layer:** [5](#layer-5--evaluation--opinion)

---

## Assessment Requirement

a tightly scoped, verifiable condition that must be satisfied and confirmed by an evaluator

> **Layer:** [2](#layer-2--controls--threats)

---

## Audit

a formal, opinionated review of an organization's [Policies](#policy) and posture, conducted at a specific point in time to verify that established requirements are met

> **Layer:** [7](#layer-7--audit--continuous-monitoring)

---

## Behavior Evaluation

an opinionated observation of simulated or real-world activities

> **Layer:** [5](#layer-5--evaluation--opinion)

---

## Capability

a feature or function of a system; the primary component comprising an attack surface

> **Layer:** [2](#layer-2--controls--threats)

---

## Catalog

a structured set of related prose and relevant metadata

> **Layers:** [1](#layer-1--guidance--vectors), [2](#layer-2--controls--threats), [3](#layer-3--risk--policy)

---

## Compliance

adherence to a [Rule](#rule) or set of [Rules](#rule)

---

## Continuous Monitoring

a multi-system process designed to collect [Evaluation](#evaluation) and operational data on an ongoing basis to better detect malicious action and non-compliance, enable [Remediative Enforcement](#remediative-enforcement), and observe trends over time

> **Layer:** [7](#layer-7--audit--continuous-monitoring)

---

## Control

**(1)** an organization's ability to fully assert desired state on a system, resource, or state; or **(2)** a mechanism, such as a safeguard or countermeasure, that asserts desired state; or **(3)** prose describing the [Objective](#objective) and [Assessment Requirements](#assessment-requirement) associated with a desired state

> **Layer:** [2](#layer-2--controls--threats)

---

## Enforcement

an action taken in response to non-compliance findings and their causes

> **Layer:** [6](#layer-6--enforcement)

---

## Evaluation

the manual or automated process of forming an opinion on the state of [Compliance](#compliance), guided by a set of [Assessment Requirements](#assessment-requirement)

> **Layer:** [5](#layer-5--evaluation--opinion)

---

## Evaluation Finding

the evidence and opinionated result of an [Assessment](#assessment)

> **Layer:** [5](#layer-5--evaluation--opinion)

---

## Governance

strategic oversight of an organization and its activities

---

## GRC

**(1)** the Governance, Risk, and Compliance domain within the cybersecurity field; or **(2)** a coordinated program dedicated to these elements within a business unit

---

## Guidance

prose intended to help bring about a desired outcome for a topic or generalized scenario, based on knowledge of relevant [Vectors](#vector)

> **Layer:** [1](#layer-1--guidance--vectors)

---

## Guideline

atomic element of a [Guidance](#guidance) [Catalog](#catalog); often includes explanatory context and recommendations for designing optimal implementations

> **Layer:** [1](#layer-1--guidance--vectors)

---

## Intent Evaluation

an [Evaluation](#evaluation) ensuring that a resource is prepared in alignment with [Policy](#policy), such as through proper training, configuration, or code

> **Layer:** [5](#layer-5--evaluation--opinion)

---

## Objective

a unified statement of intent, which may encompass multiple situationally applicable statements or requirements

> **Layer:** [2](#layer-2--controls--threats)

---

## Opinion

a firmly held approximation of reality formed within the constraints of an evaluator's philosophy, perspective, and capabilities

> **Layers:** [5](#layer-5--evaluation--opinion), [6](#layer-6--enforcement), [7](#layer-7--audit--continuous-monitoring)

---

## Organization

any logical grouping of human, physical, virtual, and information resources such as a company, business unit, or team

> **Layer:** [3](#layer-3--risk--policy)

---

## Policy

a clearly-scoped set of rules based on an organization's [Risk Appetite](#risk-appetite)

> **Layer:** [3](#layer-3--risk--policy)

---

## Preventive Enforcement

any action that interrupts another process which would otherwise cause non-compliance

> **Layer:** [6](#layer-6--enforcement)

---

## Remediative Enforcement

corrective action in response to non-compliance in a deployed activity

> **Layer:** [6](#layer-6--enforcement)

---

## Residual Risk

the [Risk](#risk) remaining after [Risk Mitigation](#risk-mitigation) and [Enforcement](#enforcement) actions have been implemented

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk

the potential for loss or damage when a [Threat](#threat) is actualized, determined by calculating the impact of an event to an organization and the likelihood of its occurrence

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk Acceptance

a clearly documented decision to accept an unmitigated [Risk](#risk) as necessary or unavoidable

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk Appetite

the level of [Risk](#risk) an organization is willing to accept in pursuit of its objectives

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk Assessment

the process of identifying the potential or actual [Risks](#risk) introduced by a system

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk Catalog

a group of related [Risks](#risk) relevant to an organization; used to determine when and how [Policies](#policy) are created for the organization

> **Layer:** [3](#layer-3--risk--policy)

---

## Risk Mitigation

the process of developing actions to prevent [Threats](#threat) or reduce their impact on organization objectives

> **Layer:** [3](#layer-3--risk--policy)

---

## Rule

an active, enforceable [Policy](#policy), regulation, or law

> **Layers:** [1](#layer-1--guidance--vectors), [2](#layer-2--controls--threats), [3](#layer-3--risk--policy)

---

## Sensitive Activity

a type of action that introduces [Risk](#risk) to an organization

> **Layer:** [4](#layer-4--sensitive-activities)

---

## Threat

a circumstance or event where the concepts of a vector are applied to a [Capability](#capability) in a specific context, resulting in the potential for negative impact

> **Layer:** [2](#layer-2--controls--threats)

---

## Vector

**(1)** an opportunity for an attacker to exploit a vulnerability in the system; or **(2)** a path by which neglect could result in unintentional negative outcomes

> **Layer:** [1](#layer-1--guidance--vectors)

---

## Vulnerability

**(1)** a weakness in a system inherent in or associated with a [Capability](#capability) that can be exploited when used in unintended ways; or **(2)** a lack of [Control](#control) or gap in defense, introduced intentionally or unintentionally, which can be leveraged to cause harm

> **Layers:** [2](#layer-2--controls--threats), [4](#layer-4--sensitive-activities)

---

## Terms by Layer

### Layer 1 -- Guidance & Vectors

| Term | Definition |
| --- | --- |
| [Guidance](#guidance) | prose intended to help bring about a desired outcome for a topic or generalized scenario, based on knowledge of relevant Vectors |
| [Guideline](#guideline) | atomic element of a Guidance Catalog; often includes explanatory context and recommendations for designing optimal implementations |
| [Vector](#vector) | (1) an opportunity for an attacker to exploit a vulnerability in the system; or (2) a path by which neglect could result in unintentional negative outcomes |
| [Catalog](#catalog) | a structured set of related prose and relevant metadata |
| [Rule](#rule) | an active, enforceable Policy, regulation, or law |

### Layer 2 -- Controls & Threats

| Term | Definition |
| --- | --- |
| [Assessment Requirement](#assessment-requirement) | a tightly scoped, verifiable condition that must be satisfied and confirmed by an evaluator |
| [Capability](#capability) | a feature or function of a system; the primary component comprising an attack surface |
| [Control](#control) | (1) an organization's ability to fully assert desired state on a system, resource, or state; or (2) a mechanism that asserts desired state; or (3) prose describing the Objective and Assessment Requirements associated with a desired state |
| [Objective](#objective) | a unified statement of intent, which may encompass multiple situationally applicable statements or requirements |
| [Threat](#threat) | a circumstance or event where the concepts of a vector are applied to a Capability in a specific context, resulting in the potential for negative impact |
| [Vulnerability](#vulnerability) | (1) a weakness in a system inherent in or associated with a Capability; or (2) a lack of Control or gap in defense which can be leveraged to cause harm |
| [Catalog](#catalog) | a structured set of related prose and relevant metadata |
| [Rule](#rule) | an active, enforceable Policy, regulation, or law |

### Layer 3 -- Risk & Policy

| Term | Definition |
| --- | --- |
| [Organization](#organization) | any logical grouping of human, physical, virtual, and information resources |
| [Policy](#policy) | a clearly-scoped set of rules based on an organization's Risk Appetite |
| [Residual Risk](#residual-risk) | the Risk remaining after Risk Mitigation and Enforcement actions have been implemented |
| [Risk](#risk) | the potential for loss or damage when a Threat is actualized |
| [Risk Acceptance](#risk-acceptance) | a clearly documented decision to accept an unmitigated Risk as necessary or unavoidable |
| [Risk Appetite](#risk-appetite) | the level of Risk an organization is willing to accept in pursuit of its objectives |
| [Risk Assessment](#risk-assessment) | the process of identifying the potential or actual Risks introduced by a system |
| [Risk Catalog](#risk-catalog) | a group of related Risks relevant to an organization |
| [Risk Mitigation](#risk-mitigation) | the process of developing actions to prevent Threats or reduce their impact |
| [Catalog](#catalog) | a structured set of related prose and relevant metadata |
| [Rule](#rule) | an active, enforceable Policy, regulation, or law |

### Layer 4 -- Sensitive Activities

| Term | Definition |
| --- | --- |
| [Sensitive Activity](#sensitive-activity) | a type of action that introduces Risk to an organization |
| [Vulnerability](#vulnerability) | (1) a weakness in a system inherent in or associated with a Capability; or (2) a lack of Control or gap in defense which can be leveraged to cause harm |

### Layer 5 -- Evaluation & Opinion

| Term | Definition |
| --- | --- |
| [Assessment](#assessment) | (1) the process of determining whether an outcome meets the actor's intent; or (2) an atomic process within an Evaluation used to determine a resource's Compliance with an Assessment Requirement |
| [Behavior Evaluation](#behavior-evaluation) | an opinionated observation of simulated or real-world activities |
| [Evaluation](#evaluation) | the manual or automated process of forming an opinion on the state of Compliance |
| [Evaluation Finding](#evaluation-finding) | the evidence and opinionated result of an Assessment |
| [Intent Evaluation](#intent-evaluation) | an Evaluation ensuring that a resource is prepared in alignment with Policy |
| [Opinion](#opinion) | a firmly held approximation of reality formed within the constraints of an evaluator's philosophy, perspective, and capabilities |

### Layer 6 -- Enforcement

| Term | Definition |
| --- | --- |
| [Enforcement](#enforcement) | an action taken in response to non-compliance findings and their causes |
| [Preventive Enforcement](#preventive-enforcement) | any action that interrupts another process which would otherwise cause non-compliance |
| [Remediative Enforcement](#remediative-enforcement) | corrective action in response to non-compliance in a deployed activity |
| [Opinion](#opinion) | a firmly held approximation of reality formed within the constraints of an evaluator's philosophy, perspective, and capabilities |

### Layer 7 -- Audit & Continuous Monitoring

| Term | Definition |
| --- | --- |
| [Audit](#audit) | a formal, opinionated review of an organization's Policies and posture, conducted at a specific point in time |
| [Continuous Monitoring](#continuous-monitoring) | a multi-system process designed to collect Evaluation and operational data on an ongoing basis |
| [Opinion](#opinion) | a firmly held approximation of reality formed within the constraints of an evaluator's philosophy, perspective, and capabilities |

### General (No Layer)

| Term | Definition |
| --- | --- |
| [Compliance](#compliance) | adherence to a Rule or set of Rules |
| [Governance](#governance) | strategic oversight of an organization and its activities |
| [GRC](#grc) | (1) the Governance, Risk, and Compliance domain within the cybersecurity field; or (2) a coordinated program dedicated to these elements within a business unit |

---

**See also:** [Common Terms](COMMON-TERMS.md) | [complyctl Overview](complyctl-overview.md) | [FAQ](FAQ.md) | [Back to Resources](README.md)
