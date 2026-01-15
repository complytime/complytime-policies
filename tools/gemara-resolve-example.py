#!/usr/bin/env python3
"""
Proof-of-concept: Gemara Policy Resolver

This script demonstrates how to resolve assessment requirements from a Gemara Layer 3 Policy
and generate CALM control requirement files (one per assessment requirement).

Usage:
    python gemara-resolve-example.py --policy POLICY_ID
"""

import json
import sys
import argparse
from typing import Dict, List, Any, Optional
from pathlib import Path


class PolicyResolver:
    """Resolves assessment requirements from a Gemara Layer 3 Policy."""
    
    def __init__(self, mcp_client=None):
        self.mcp_client = mcp_client
    
    def resolve_assessment_requirements(
        self, 
        policy: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """
        Resolve all assessment requirements from a Layer 3 Policy.
        
        Returns list of resolved assessment requirements (one per requirement).
        """
        resolved_requirements = []
        policy_id = policy["metadata"]["id"]
        
        # Get control-references from policy
        control_refs = policy.get("control-references", [])
        
        for control_ref in control_refs:
            catalog_id = control_ref.get("reference-id")
            control_mods = control_ref.get("control-modifications", [])
            assessment_mods = control_ref.get("assessment-requirement-modifications", [])
            
            # For each control modification
            for mod in control_mods:
                control_id = mod.get("target-id")
                
                # Resolve base control (would use MCP client here)
                base_control = self._get_base_control(catalog_id, control_id)
                
                # Apply modifications to get resolved control
                resolved_control = self._apply_modifications(
                    base_control,
                    mod,
                    assessment_mods
                )
                
                # Generate one control requirement file per assessment requirement
                for req in resolved_control.get("assessment-requirements", []):
                    requirement_id = req["id"]
                    
                    # Determine if this is a modified requirement or base requirement
                    is_modified = any(
                        am.get("target-id") == requirement_id 
                        for am in assessment_mods
                    )
                    
                    resolved_requirements.append({
                        "requirement-id": requirement_id,
                        "control-id": control_id,
                        "catalog-id": catalog_id,
                        "policy-id": policy_id,
                        "text": req["text"],
                        "applicability": req.get("applicability", []),
                        "is-modified": is_modified,
                        "base-requirement-id": f"{control_id}.{requirement_id.split('.')[-1]}" if is_modified else requirement_id,
                        "gemara-url": f"gemara://policies/{policy_id}/controls/{control_id}/requirements/{requirement_id}",
                        "base-requirement-url": f"gemara://controls/{catalog_id}/{control_id}/requirements/{requirement_id}",
                        "control-title": resolved_control.get("title", base_control.get("title", control_id)),
                        "control-objective": resolved_control.get("objective", base_control.get("objective", ""))
                    })
        
        return resolved_requirements
    
    def _get_base_control(self, catalog_id: str, control_id: str) -> Dict[str, Any]:
        """Get base control from catalog (would use MCP client in real implementation)."""
        # Placeholder - in real implementation would call MCP server
        # mcp_gemara-mcp_get_layer2_control(control_id=control_id)
        return {
            "id": control_id,
            "catalog-id": catalog_id,
            "title": f"Base Control {control_id}",
            "objective": f"Base control objective for {control_id}",
            "assessment-requirements": [
                {
                    "id": f"{control_id}.TR01",
                    "text": "Base assessment requirement text",
                    "applicability": ["default"]
                }
            ]
        }
    
    def _apply_modifications(
        self,
        base_control: Dict[str, Any],
        control_mod: Dict[str, Any],
        assessment_mods: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Apply policy modifications to base control."""
        resolved = base_control.copy()
        
        # Apply control-level modifications
        if control_mod.get("title"):
            resolved["title"] = control_mod["title"]
        if control_mod.get("objective"):
            resolved["objective"] = control_mod["objective"]
        
        # Apply assessment requirement modifications
        resolved_reqs = []
        
        # Start with base requirements
        for base_req in base_control.get("assessment-requirements", []):
            req_id = base_req["id"]
            
            # Check if this requirement is modified
            mod = next(
                (am for am in assessment_mods if am.get("target-id") == req_id),
                None
            )
            
            if mod:
                # Use modified requirement
                resolved_reqs.append({
                    "id": mod.get("target-id", req_id),
                    "text": mod.get("text", base_req["text"]),
                    "applicability": mod.get("applicability", base_req.get("applicability", []))
                })
            else:
                # Keep base requirement
                resolved_reqs.append(base_req)
        
        # Add any new requirements from modifications
        for mod in assessment_mods:
            if not any(req["id"] == mod.get("target-id") for req in resolved_reqs):
                resolved_reqs.append({
                    "id": mod.get("target-id"),
                    "text": mod.get("text", ""),
                    "applicability": mod.get("applicability", [])
                })
        
        resolved["assessment-requirements"] = resolved_reqs
        return resolved


class ControlRequirementFileGenerator:
    """Generates CALM control requirement files from resolved assessment requirements."""
    
    def generate_control_files(
        self,
        resolved_requirements: List[Dict[str, Any]],
        output_dir: Path
    ):
        """Generate one control requirement file per assessment requirement."""
        
        output_dir.mkdir(parents=True, exist_ok=True)
        
        for req in resolved_requirements:
            # Generate control requirement file for this assessment requirement
            control_file = {
                "$schema": "https://calm.finos.org/release/1.1/meta/control-requirement.json",
                "$id": req["gemara-url"],
                "control-id": req["requirement-id"],
                "name": f"{req['control-title']} - {req['requirement-id']}",
                "description": req["text"],  # Assessment requirement text is the description
                "metadata": {
                    "gemara": {
                        "layer": "Layer 3",
                        "policy-id": req["policy-id"],
                        "control-id": req["control-id"],
                        "requirement-id": req["requirement-id"],
                        "source": {
                            "type": "policy",
                            "policy-id": req["policy-id"],
                            "control-id": req["control-id"]
                        },
                        "base-requirement": {
                            "reference-url": req["base-requirement-url"],
                            "catalog-id": req["catalog-id"]
                        },
                        "applicability": req["applicability"]
                    }
                }
            }
            
            # Sanitize filename
            filename = req["requirement-id"].replace(".", "-").lower() + ".requirement.json"
            filepath = output_dir / filename
            
            filepath.write_text(json.dumps(control_file, indent=2))
            print(f"✓ Generated control requirement file: {filepath}")


class URLMappingGenerator:
    """Generates URL mapping files for local development."""
    
    def generate_mapping(
        self,
        resolved_requirements: List[Dict[str, Any]],
        control_files_dir: Path,
        base_requirements_dir: Optional[Path],
        output_path: Path
    ):
        """Generate URL mapping file."""
        
        mapping = {}
        
        for req in resolved_requirements:
            requirement_id = req["requirement-id"]
            
            # Map policy-level requirement
            policy_url = req["gemara-url"]
            filename = requirement_id.replace(".", "-").lower() + ".requirement.json"
            policy_path = f"../{control_files_dir}/{filename}"
            mapping[policy_url] = policy_path
            
            # Map base requirement (if base requirements directory provided)
            if base_requirements_dir:
                base_url = req["base-requirement-url"]
                base_path = f"../{base_requirements_dir}/{filename}"
                mapping[base_url] = base_path
        
        output_path.write_text(json.dumps(mapping, indent=2))
        print(f"✓ Generated URL mapping: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Resolve Gemara policy assessment requirements and generate CALM control requirement files"
    )
    parser.add_argument(
        "--policy",
        required=True,
        help="Gemara Layer 3 Policy ID"
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("generated"),
        help="Output directory for generated artifacts"
    )
    parser.add_argument(
        "--generate-controls",
        action="store_true",
        help="Generate control requirement files (one per assessment requirement)"
    )
    parser.add_argument(
        "--generate-mapping",
        action="store_true",
        help="Generate URL mapping file"
    )
    
    args = parser.parse_args()
    
    # In real implementation, would fetch policy from MCP server
    print(f"⚠️  This is a proof-of-concept. Real implementation would:")
    print(f"   1. Fetch policy '{args.policy}' from Gemara MCP server")
    print(f"   2. Resolve all control-references to Layer 2 controls")
    print(f"   3. Apply policy modifications to assessment requirements")
    print(f"   4. Generate one CALM control requirement file per assessment requirement")
    
    # Example workflow (would be implemented with real MCP client)
    output_dir = args.output_dir
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Initialize generators
    resolver = PolicyResolver()
    control_gen = ControlRequirementFileGenerator()
    mapping_gen = URLMappingGenerator()
    
    # Placeholder policy (would come from MCP)
    policy = {
        "metadata": {"id": args.policy},
        "control-references": [
            {
                "reference-id": "FINOS-CCC",
                "control-modifications": [
                    {
                        "target-id": "CCC.C01",
                        "modification-type": "enhancement",
                        "title": "Enhanced Encryption",
                        "objective": "Enhanced encryption for cloud infrastructure"
                    }
                ],
                "assessment-requirement-modifications": [
                    {
                        "target-id": "CCC.C01.TR01",
                        "text": "All HTTPS communications MUST use TLS 1.3 or higher",
                        "applicability": ["default"]
                    }
                ]
            }
        ]
    }
    
    # Resolve assessment requirements
    print(f"\n📋 Resolving assessment requirements from policy '{args.policy}'...")
    resolved_requirements = resolver.resolve_assessment_requirements(policy)
    print(f"✓ Resolved {len(resolved_requirements)} assessment requirements")
    
    # Generate artifacts
    if args.generate_controls:
        controls_dir = output_dir / "controls" / args.policy
        control_gen.generate_control_files(resolved_requirements, controls_dir)
    
    if args.generate_mapping:
        mapping_path = output_dir / f"{args.policy}-url-mapping.json"
        controls_dir = Path("controls") / args.policy
        mapping_gen.generate_mapping(
            resolved_requirements,
            controls_dir,
            Path("controls") / "base",
            mapping_path
        )
    
    print(f"\n✅ Complete! Artifacts generated in {output_dir}/")


if __name__ == "__main__":
    main()
