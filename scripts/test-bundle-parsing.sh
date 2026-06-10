#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Tests the yq expressions used by publish-policy-oci.yml and cue-validate.yml
# to parse bundle manifest layers. Validates correct behaviour under pipefail
# for both real bundles and synthetic edge cases.
#
# Usage: ./scripts/test-bundle-parsing.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR_TEST="$(mktemp -d)"
trap 'rm -rf "${TMPDIR_TEST}"' EXIT

passed=0
failed=0

pass() {
  passed=$((passed + 1))
  echo "  PASS: $1"
}

fail() {
  failed=$((failed + 1))
  echo "  FAIL: $1"
}

# --- Expressions under test (must match the workflows) ---
# publish-policy-oci.yml discover job: extract last layer (root policy file)
yq_root_file() { yq -r '(.layers // []) | select(length > 0) | .[-1]' "$1"; }

# publish-policy-oci.yml hash step + cue-validate.yml layer existence: iterate all layers
yq_all_layers() { yq -r '(.layers // [])[]' "$1"; }

# ============================================================
# Part 1: Synthetic edge cases
# ============================================================
echo "=== Synthetic edge-case tests ==="

# --- Case: no layers key ---
echo "other_key: value" > "${TMPDIR_TEST}/no-layers.yaml"

result="$(yq_root_file "${TMPDIR_TEST}/no-layers.yaml")"
[ -z "${result}" ] && pass "no-layers: root_file is empty" || fail "no-layers: root_file should be empty, got '${result}'"

result="$(yq_all_layers "${TMPDIR_TEST}/no-layers.yaml")"
[ -z "${result}" ] && pass "no-layers: all_layers is empty" || fail "no-layers: all_layers should be empty, got '${result}'"

# --- Case: empty array ---
echo "layers: []" > "${TMPDIR_TEST}/empty-layers.yaml"

result="$(yq_root_file "${TMPDIR_TEST}/empty-layers.yaml")"
[ -z "${result}" ] && pass "empty-layers: root_file is empty" || fail "empty-layers: root_file should be empty, got '${result}'"

result="$(yq_all_layers "${TMPDIR_TEST}/empty-layers.yaml")"
[ -z "${result}" ] && pass "empty-layers: all_layers is empty" || fail "empty-layers: all_layers should be empty, got '${result}'"

# --- Case: null value ---
printf "layers:\n" > "${TMPDIR_TEST}/null-layers.yaml"

result="$(yq_root_file "${TMPDIR_TEST}/null-layers.yaml")"
[ -z "${result}" ] && pass "null-layers: root_file is empty" || fail "null-layers: root_file should be empty, got '${result}'"

result="$(yq_all_layers "${TMPDIR_TEST}/null-layers.yaml")"
[ -z "${result}" ] && pass "null-layers: all_layers is empty" || fail "null-layers: all_layers should be empty, got '${result}'"

# --- Case: valid bundle (happy path) ---
cat > "${TMPDIR_TEST}/valid.yaml" <<'YAML'
layers:
  - governance/catalogs/test-catalog.yaml
  - governance/policies/test-policy.yaml
YAML

result="$(yq_root_file "${TMPDIR_TEST}/valid.yaml")"
[ "${result}" = "governance/policies/test-policy.yaml" ] \
  && pass "valid: root_file is last layer" \
  || fail "valid: root_file expected 'governance/policies/test-policy.yaml', got '${result}'"

count="$(yq_all_layers "${TMPDIR_TEST}/valid.yaml" | wc -l | tr -d ' ')"
[ "${count}" = "2" ] \
  && pass "valid: all_layers returns 2 entries" \
  || fail "valid: all_layers expected 2 entries, got ${count}"

# --- Case: single layer ---
cat > "${TMPDIR_TEST}/single.yaml" <<'YAML'
layers:
  - governance/policies/only-policy.yaml
YAML

result="$(yq_root_file "${TMPDIR_TEST}/single.yaml")"
[ "${result}" = "governance/policies/only-policy.yaml" ] \
  && pass "single: root_file is the only layer" \
  || fail "single: root_file expected 'governance/policies/only-policy.yaml', got '${result}'"

count="$(yq_all_layers "${TMPDIR_TEST}/single.yaml" | wc -l | tr -d ' ')"
[ "${count}" = "1" ] \
  && pass "single: all_layers returns 1 entry" \
  || fail "single: all_layers expected 1 entry, got ${count}"

# ============================================================
# Part 2: Real bundles in bundles/
# ============================================================
echo ""
echo "=== Real bundle tests ==="

bundle_count=0
for bundle_file in "${REPO_ROOT}"/bundles/*.yaml; do
  [ -f "${bundle_file}" ] || continue
  bundle_name="$(basename "${bundle_file}" .yaml)"
  bundle_count=$((bundle_count + 1))

  root="$(yq_root_file "${bundle_file}")"
  if [ -z "${root}" ]; then
    fail "${bundle_name}: root_file is empty"
  elif [ ! -f "${REPO_ROOT}/${root}" ]; then
    fail "${bundle_name}: root_file '${root}' does not exist"
  else
    pass "${bundle_name}: root_file '${root}' exists"
  fi

  layer_ok=0
  layer_total=0
  while IFS= read -r layer; do
    [ -z "${layer}" ] && continue
    layer_total=$((layer_total + 1))
    if [ -f "${REPO_ROOT}/${layer}" ]; then
      layer_ok=$((layer_ok + 1))
    else
      fail "${bundle_name}: layer '${layer}' does not exist"
    fi
  done < <(yq_all_layers "${bundle_file}")

  if [ "${layer_ok}" -eq "${layer_total}" ] && [ "${layer_total}" -gt 0 ]; then
    pass "${bundle_name}: all ${layer_total} layer(s) exist"
  elif [ "${layer_total}" -eq 0 ]; then
    fail "${bundle_name}: no layers found"
  fi
done

if [ "${bundle_count}" -eq 0 ]; then
  fail "no bundle files found in bundles/"
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "=== Results: ${passed} passed, ${failed} failed ==="
if [ "${failed}" -gt 0 ]; then
  exit 1
fi
