# Integrating CALM with Gemara Compliance Policies

This guide explains how to integrate CALM (Common Architecture Language Model) architectures with Gemara compliance policies. The integration enables you to validate that CALM architectures meet compliance requirements defined in Gemara Layer 3 Policies.

## Overview

The integration between CALM and Gemara works through a two-step process:

1. **Create Standards**: Define CALM standards that enforce metadata requirements needed to work with Gemara policies
2. **Create Patterns from Policies**: Generate CALM patterns from Gemara Layer 3 Policy documents that validate architectures against compliance requirements

## Integration Approach

### Step 1: Create Standards for Gemara Metadata

To integrate with Gemara, you need to create CALM standards that enforce the metadata structure required to reference Gemara policies and controls. This repository includes three key standards:

#### 1. Node Metadata Standard (`complytime-node-metadata.standard.json`)

Enforces consistent metadata on CALM nodes, including:
- `primary_function`: Describes the node's purpose
- `gemara_layer`: Optional field indicating which Gemara layer(s) the node operates at

#### 2. Relationship Metadata Standard (`complytime-relationship-metadata.standard.json`)

Enforces consistent metadata on CALM relationships, including:
- `interaction_type`: Synchronous or Asynchronous
- `direction`: inbound or outbound
- `data_contract`: Description of data exchanged

#### 3. Gemara Policy Inclusion Standard (`complytime-gemara-policy-inclusion.standard.json`)

Defines the structure for including Gemara assessment requirements as CALM control requirements. This standard ensures:
- Proper `gemara://` URL format for control requirements
- Traceability to Layer 2 base requirements
- Policy-specific modifications are preserved
- Applicability scopes are maintained

### Step 2: Create Patterns from Policy Documents

Once you have standards in place, you can create CALM patterns from Gemara Layer 3 Policy documents. Patterns validate that architectures:

- Include required components (nodes)
- Reference appropriate Gemara control requirements
- Follow deployment patterns specified in policies

#### Process: Creating Patterns from Policies

```
Gemara Layer 3 Policy
    ↓
Fetch via MCP Server (or load from file)
    ↓
Extract control references and requirements
    ↓
Generate CALM Pattern JSON Schema
    ↓
Create Control Requirement Files
    ↓
Create URL Mapping File
```

#### Example: Pattern Generation Workflow

1. **Fetch the Policy**

   ```python
   # Using Gemara MCP server (in Cursor/Composer)
   policy = mcp_gemara-mcp_get_layer3_policy(policy_id="cloud-policy-001")
   ```

2. **Extract Control Requirements**

   For each control referenced in the policy:
   - Resolve Layer 2 base controls
   - Apply policy-specific modifications
   - Extract assessment requirements
   - Generate control requirement files

3. **Generate Pattern JSON Schema**

   Create a CALM pattern that:
   - Validates required node types (e.g., services, storage)
   - Enforces control requirement references
   - Validates metadata structure using your standards

4. **Create URL Mapping**

   Map `gemara://` URLs to local control requirement files:

   ```json
   {
     "gemara://policies/cloud-policy-001/controls/CCC.Core.CN01/requirements/CCC.Core.CN01.TR01": "../controls/cloud-policy-001-cn01-tr01.requirement.json",
     "gemara://controls/FINOS-CCC/CCC.Core.CN01/requirements/CCC.Core.CN01.TR01": "../controls/ccc-core-cn01-tr01.requirement.json"
   }
   ```

## Control Requirements

### What Are Control Requirements?

In CALM, a **control requirement** is a Gemara assessment requirement. Each assessment requirement from a Gemara Layer 3 Policy becomes its own CALM control requirement file.

Control requirement files provide:
- **Traceability**: Link from architecture to policy assessment requirements
- **Resolved Text**: Assessment requirement text becomes the control requirement description
- **Base Requirement References**: Maintain lineage to Layer 2 assessment requirements

### Creating Control Requirements from Policies

#### 1. Fetch Gemara Layer 3 Policy

```python
policy = mcp_gemara-mcp_get_layer3_policy(policy_id="your-policy-id")
```

The policy contains:
- `metadata`: Policy identification and metadata
- `control-references`: References to Layer 2 control catalogs
- `control-modifications`: Policy-specific modifications to controls
- `assessment-requirement-modifications`: Modifications to testable requirements

#### 2. Resolve Control References

For each `control-reference` in the policy:

```python
control_ref = policy["control-references"][0]
catalog_id = control_ref["reference-id"]  # e.g., "FINOS-CCC"

for mod in control_ref["control-modifications"]:
    control_id = mod["target-id"]  # e.g., "CCC.Core.CN01"
    
    # Fetch base Layer 2 control via MCP
    base_control = mcp_gemara-mcp_get_layer2_control(control_id=control_id)
```

#### 3. Extract and Resolve Assessment Requirements

**Important**: Generate one control requirement file per assessment requirement, not per control.

```python
# Process base assessment requirements
for base_req in base_control.get("assessment-requirements", []):
    req_id = base_req["id"]
    
    # Check if this requirement is modified by the policy
    mod = next(
        (am for am in assessment_mods if am.get("target-id") == req_id),
        None
    )
    
    if mod:
        # Use modified requirement text
        requirement_text = mod["text"]
    else:
        # Keep base requirement
        requirement_text = base_req["text"]
```

#### 4. Generate Control Requirement File

Create one control requirement file per assessment requirement:

```json
{
  "$schema": "https://calm.finos.org/release/1.1/meta/control-requirement.json",
  "$id": "gemara://policies/cloud-policy-001/controls/CCC.Core.CN01/requirements/CCC.Core.CN01.TR01",
  "control-id": "CCC.Core.CN01.TR01",
  "name": "Encrypt Data for Transmission - TLS 1.3 Required",
  "description": "All HTTPS communications MUST use TLS 1.3 or higher",
  "metadata": {
    "gemara": {
      "layer": "Layer 3",
      "policy-id": "cloud-policy-001",
      "control-id": "CCC.Core.CN01",
      "requirement-id": "CCC.Core.CN01.TR01",
      "source": {
        "type": "policy",
        "policy-id": "cloud-policy-001",
        "control-id": "CCC.Core.CN01"
      },
      "base-requirement": {
        "reference-url": "gemara://controls/FINOS-CCC/CCC.Core.CN01/requirements/CCC.Core.CN01.TR01",
        "catalog-id": "FINOS-CCC"
      },
      "applicability": ["default"]
    }
  }
}
```

**Key Points**:
- `$id` includes `/requirements/{requirement-id}` path
- `control-id` is the requirement ID (e.g., `CCC.Core.CN01.TR01`)
- `description` is the resolved assessment requirement text
- `base-requirement` references the Layer 2 assessment requirement

### Layer 2 vs Layer 3 Requirements

**Layer 2 Requirements** (direct from catalog):
- `layer`: "Layer 2"
- `catalog-id`: Required
- `source.type`: "catalog"
- No `policy-id` or `base-requirement`

**Layer 3 Requirements** (from policy):
- `layer`: "Layer 3"
- `policy-id`: Required
- `source.type`: "policy"
- `base-requirement`: Required (references Layer 2 requirement)

## Using Patterns to Validate Architectures

Once you have:
1. Standards that enforce Gemara metadata requirements
2. Patterns generated from policies
3. Control requirement files

You can validate architectures against policies:

```bash
calm validate \
  -p patterns/complytime-deployment.pattern.json \
  -a architecture/complytime-example.arch.json \
  -u standards/url-mapping.json
```

The pattern will validate that:
- Required components are present
- Components reference appropriate Gemara control requirements
- Metadata follows the standards
- Control requirements are properly structured

## Example Files

This repository includes:

- **Standards**: `standards/complytime-*.standard.json` - Standards for Gemara integration
- **Pattern**: `patterns/complytime-deployment.pattern.json` - Example pattern validating ComplyTime deployments
- **Architecture**: `architecture/complytime-example.arch.json` - Example architecture that validates against the pattern
- **Control Requirements**: `controls/*.requirement.json` - Example control requirement files
- **URL Mapping**: `standards/url-mapping.json` - Maps `gemara://` URLs to local files

## Best Practices

1. **Standards First**: Create standards that enforce metadata requirements before generating patterns
2. **One File Per Requirement**: Generate one control requirement file per assessment requirement
3. **Use Resolved Text**: Assessment requirement text becomes the control requirement description
4. **Reference Base Requirements**: Maintain traceability to Layer 2 requirements via `base-requirement`
5. **Use Consistent Naming**: Follow `{requirement-id}.requirement.json` naming convention
6. **Validate Before Committing**: Ensure files conform to standards using `make validate`
7. **Version Control**: Track control requirement files and patterns in git

## Related Documentation

- [Gemara Policy Inclusion Standard](../standards/complytime-gemara-policy-inclusion.standard.json) - Schema for assessment requirements as control requirements
- [Node Metadata Standard](../standards/complytime-node-metadata.standard.json) - Standard for node metadata
- [Relationship Metadata Standard](../standards/complytime-relationship-metadata.standard.json) - Standard for relationship metadata
