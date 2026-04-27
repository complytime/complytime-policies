#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Local static checks: thin caller -> sonupreetam/gemara-publish-oci Option 3.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WF="${ROOT}/.github/workflows/publish-policy-oci.yml"
OCI_ARTIFACT_ACTION="sonupreetam/gemara-publish-oci"
OCI_ARTIFACT_PIN="3e82d5dfa822ce486ce9b129665e8b6db3e7b2b9"
QUAY_TEST_DEST="test_complytime/complytime-policies"

if [[ ! -f "$WF" ]]; then
  echo "error: missing $WF" >&2
  exit 1
fi

python3 -c "import yaml; yaml.safe_load(open('${WF}'))"
echo "ok: publish-policy-oci.yml parses as YAML"

grep -qF "${OCI_ARTIFACT_ACTION}@${OCI_ARTIFACT_PIN}" "$WF" || {
  echo "error: expected ${OCI_ARTIFACT_ACTION}@${OCI_ARTIFACT_PIN} in workflow" >&2
  exit 1
}
echo "ok: workflow uses ${OCI_ARTIFACT_ACTION} @ ${OCI_ARTIFACT_PIN}"
grep -qF "${OCI_ARTIFACT_ACTION}" "$WF" || {
  echo "error: expected ${OCI_ARTIFACT_ACTION} in workflow" >&2
  exit 1
}

grep -qF "$QUAY_TEST_DEST" "$WF" || {
  echo "error: expected default dest ${QUAY_TEST_DEST} in workflow" >&2
  exit 1
}
echo "ok: default dest_image matches test Quay repo (${QUAY_TEST_DEST})"

grep -qF "publish_mode: gemara-file" "$WF" || {
  echo "error: expected publish job to set publish_mode: gemara-file" >&2
  exit 1
}
grep -qE "bundle_file:" "$WF" && grep -qE "file:" "$WF" || {
  echo "error: expected workflow to map bundle_file input to action file input" >&2
  exit 1
}
grep -qE "promote_to_quay:\s*\"true\"" "$WF" || {
  echo "error: expected workflow to enable promote_to_quay" >&2
  exit 1
}
echo "ok: workflow uses oci-artifact composite for publish/sign/promote"

echo
echo "Interim demo run (on GitHub):"
echo "  1) Fork or repo: Actions → Publish policy OCI → Run workflow"
echo "  2) release_tag: e.g. demo-0.0.1 (new tag; fail_if_dest_exists: true)"
echo "  3) allow_unprotected_ref: true on a fork or unprotected default branch"
echo "  4) trust_mode: resign (recommended) or copy-referrers for spike"
echo "  5) dest_image: default (${QUAY_TEST_DEST}) for test Quay; robot must push there"
echo "  6) Quay repo URL: quay.io/${QUAY_TEST_DEST}:\$release_tag"
