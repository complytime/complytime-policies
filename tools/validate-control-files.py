#!/usr/bin/env python3
"""
Validate that control requirement files exist and conform to standards.

Checks that all gemara:// URLs referenced in architectures have corresponding
control files with matching $id fields.

Usage:
    python validate-control-files.py [--architecture-dir ARCH_DIR] [--controls-dir CONTROLS_DIR]
"""

import json
import re
import sys
from pathlib import Path
from typing import List, Tuple, Optional


def extract_gemara_urls(architecture_dir: Path) -> List[str]:
    """Extract all gemara:// URLs from architecture files."""
    urls = set()
    
    for arch_file in architecture_dir.glob("*.arch.json"):
        try:
            content = arch_file.read_text()
            # Find all gemara:// URLs
            matches = re.findall(r'gemara://[^"]+', content)
            urls.update(matches)
        except Exception as e:
            print(f"⚠️  Error reading {arch_file}: {e}", file=sys.stderr)
    
    return sorted(urls)


def find_control_file(url: str, controls_dir: Path) -> Optional[Path]:
    """Find control file with matching $id for the given gemara:// URL."""
    for control_file in controls_dir.glob("*.requirement.json"):
        try:
            with control_file.open() as f:
                data = json.load(f)
                file_id = data.get("$id", "")
                if file_id == url:
                    return control_file
        except json.JSONDecodeError:
            continue
        except Exception:
            continue
    
    return None


def validate_control_file(control_file: Path, expected_url: str) -> Tuple[bool, Optional[str]]:
    """
    Validate control file structure and content.
    
    Returns:
        (is_valid, error_message)
    """
    try:
        with control_file.open() as f:
            data = json.load(f)
        
        # Validate $id matches URL
        file_id = data.get("$id", "")
        if file_id != expected_url:
            return False, f"$id mismatch: expected '{expected_url}', found '{file_id}'"
        
        # Validate required fields
        if "control-id" not in data:
            return False, "Missing required field: control-id"
        
        if "metadata" not in data:
            return False, "Missing required field: metadata"
        
        gemara_meta = data.get("metadata", {}).get("gemara", {})
        if not gemara_meta:
            return False, "Missing required field: metadata.gemara"
        
        # Validate assessment requirement structure
        layer = gemara_meta.get("layer", "")
        if "requirement-id" not in gemara_meta:
            return False, "Missing required field: metadata.gemara.requirement-id"
        if "source" not in gemara_meta:
            return False, "Missing required field: metadata.gemara.source"
        if "applicability" not in gemara_meta:
            return False, "Missing required field: metadata.gemara.applicability"
        
        if layer == "Layer 3":
            if "policy-id" not in gemara_meta:
                return False, "Layer 3 requirement missing required field: metadata.gemara.policy-id"
            if "base-requirement" not in gemara_meta:
                return False, "Layer 3 requirement missing required field: metadata.gemara.base-requirement"
        elif layer == "Layer 2":
            if "catalog-id" not in gemara_meta:
                return False, "Layer 2 requirement missing required field: metadata.gemara.catalog-id"
        
        return True, None
        
    except json.JSONDecodeError as e:
        return False, f"Invalid JSON: {e}"
    except Exception as e:
        return False, f"Error reading file: {e}"


def main():
    """Main validation function."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Validate control requirement files exist and conform to standards"
    )
    parser.add_argument(
        "--architecture-dir",
        type=Path,
        default=Path("architecture"),
        help="Directory containing CALM architecture files"
    )
    parser.add_argument(
        "--controls-dir",
        type=Path,
        default=Path("controls"),
        help="Directory containing control requirement files"
    )
    
    args = parser.parse_args()
    
    architecture_dir = args.architecture_dir
    controls_dir = args.controls_dir
    
    if not architecture_dir.exists():
        print(f"❌ Architecture directory not found: {architecture_dir}", file=sys.stderr)
        sys.exit(1)
    
    if not controls_dir.exists():
        print(f"❌ Controls directory not found: {controls_dir}", file=sys.stderr)
        sys.exit(1)
    
    print("🔍 Validating control requirement files...")
    
    # Extract URLs from architectures
    urls = extract_gemara_urls(architecture_dir)
    
    if not urls:
        print("⚠️  No gemara:// URLs found in architecture files")
        sys.exit(0)
    
    errors = []
    warnings = []
    
    # Validate each URL has a corresponding control file
    for url in urls:
        control_file = find_control_file(url, controls_dir)
        
        if control_file is None:
            errors.append(f"Missing control file for {url}")
            continue
        
        # Validate file structure
        is_valid, error_msg = validate_control_file(control_file, url)
        
        if not is_valid:
            errors.append(f"{control_file}: {error_msg}")
        else:
            # Check policy-id consistency for Layer 3 controls
            try:
                with control_file.open() as f:
                    data = json.load(f)
                    gemara_meta = data.get("metadata", {}).get("gemara", {})
                    
                    if gemara_meta.get("layer") == "Layer 3":
                        # Extract policy-id from URL
                        match = re.match(r'gemara://policies/([^/]+)/controls/', url)
                        if match:
                            expected_policy_id = match.group(1)
                            file_policy_id = gemara_meta.get("policy-id", "")
                            
                            if file_policy_id != expected_policy_id:
                                warnings.append(
                                    f"{control_file}: Policy ID mismatch "
                                    f"(expected '{expected_policy_id}', found '{file_policy_id}')"
                                )
            except Exception:
                pass
            
            print(f"✓ Found control file: {control_file}")
    
    # Print warnings
    for warning in warnings:
        print(f"⚠️  {warning}")
    
    # Print errors and exit
    if errors:
        print("\n❌ Validation errors:")
        for error in errors:
            print(f"   {error}")
        print(f"\n❌ Found {len(errors)} error(s)")
        sys.exit(1)
    
    print("\n✅ All control files validated successfully")
    sys.exit(0)


if __name__ == "__main__":
    main()
