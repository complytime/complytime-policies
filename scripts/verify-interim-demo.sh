#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Local static checks: interim demo = public org-infra pin (sign + promote) + inline gemara + test Quay.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WF="${ROOT}/.github/workflows/publish-policy-oci.yml"
# Public complytime/org-infra (reusable_sign_and_verify + resuable_publish_quay only).
ORG_PIN="9205a3ac6b76b75dbe6e22b2f0f330bc8edbeb38"
INTERIM_ACTION="sonupreetam/gemara-publish-oci"
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

grep -qF "${INTERIM_ACTION}@${INTERIM_ACTION_REF}" "$WF" || {
  echo "error: expected ${INTERIM_ACTION}@${INTERIM_ACTION_REF} in $WF" >&2
  exit 1
}
echo "ok: inline staging pins interim pack action ${INTERIM_ACTION} @ ${INTERIM_ACTION_REF}"

echo
echo "Interim demo run (on GitHub):"
echo "  1) Fork or repo: Actions → Publish policy OCI → Run workflow"
echo "  2) release_tag: e.g. demo-0.0.1 (new tag; fail_if_dest_exists: true)"
echo "  3) allow_unprotected_ref: true on a fork or unprotected default branch"
echo "  4) dest_image: default (${QUAY_TEST_DEST}) for test Quay; robot must push there"
echo "  5) Quay repo URL: quay.io/${QUAY_TEST_DEST}:\$release_tag"
