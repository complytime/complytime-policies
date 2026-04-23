#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Local static checks: interim demo = org-infra pin + test Quay default + (optional) sibling org-infra gemara action pin.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WF="${ROOT}/.github/workflows/publish-policy-oci.yml"
ORG_PIN="7eabc2b960778190d38c591b7b96b376489d0acb"
INTERIM_ACTION="sonupreetam/gemara-publish-oci"
# SHA baked into org-infra reusable_publish_gemara_oci at ORG_PIN (bump with org-infra).
INTERIM_ACTION_REF="7203d6158a16208a0338cc33ea001bb077f4705c"
QUAY_TEST_DEST="test_complytime/complytime-policies"

if [[ ! -f "$WF" ]]; then
  echo "error: missing $WF" >&2
  exit 1
fi

python3 -c "import yaml; yaml.safe_load(open('${WF}'))"
echo "ok: publish-policy-oci.yml parses as YAML"

grep -qF "$ORG_PIN" "$WF" || {
  echo "error: expected org-infra ref ${ORG_PIN} in workflow" >&2
  exit 1
}
echo "ok: workflow uses org-infra @ ${ORG_PIN}"

grep -qF "$QUAY_TEST_DEST" "$WF" || {
  echo "error: expected default dest ${QUAY_TEST_DEST} in workflow" >&2
  exit 1
}
echo "ok: default dest_image matches test Quay repo (${QUAY_TEST_DEST})"

# Optional: workspace checkout of org-infra (parent or ORG_INFRA env).
GARA="${ORG_INFRA:-$ROOT/../org-infra}/.github/workflows/reusable_publish_gemara_oci.yml"
if [[ -f "$GARA" ]]; then
  grep -qF "${INTERIM_ACTION}@${INTERIM_ACTION_REF}" "$GARA" || {
    echo "error: expected ${INTERIM_ACTION}@${INTERIM_ACTION_REF} in $GARA" >&2
    exit 1
  }
  echo "ok: sibling org-infra pins interim pack action ${INTERIM_ACTION} @ ${INTERIM_ACTION_REF}"
else
  echo "skip: set ORG_INFRA or place org-infra next to this repo to verify gemara action pin in reusable_publish_gemara_oci.yml"
  echo "    (expected: ${INTERIM_ACTION}@${INTERIM_ACTION_REF})"
fi

echo
echo "Interim demo run (on GitHub):"
echo "  1) Fork or repo: Actions → Publish policy OCI → Run workflow"
echo "  2) release_tag: e.g. demo-0.0.1 (new tag; fail_if_dest_exists: true)"
echo "  3) allow_unprotected_ref: true on a fork or unprotected default branch"
echo "  4) dest_image: default (${QUAY_TEST_DEST}) for test Quay; robot must push there"
echo "  5) Quay repo URL: quay.io/${QUAY_TEST_DEST}:\$release_tag"
