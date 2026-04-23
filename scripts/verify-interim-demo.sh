#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Local static checks: org-infra-tests (gemara + sign + quay) + test Quay default.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WF="${ROOT}/.github/workflows/publish-policy-oci.yml"
# sonupreetam/org-infra-tests: all three workflow_call targets use this SHA in publish-policy-oci.
ORG_INFRA_TESTS_PIN="9a166dd4be83f39f599be4827d38d43b74efe1c2"
# Composite is pinned inside org-infra-tests/reusable_publish_oras.yml (publish_mode: gemara); optional sibling check.
INTERIM_ACTION="sonupreetam/gemara-publish-oci"
INTERIM_ACTION_REF="7203d6158a16208a0338cc33ea001bb077f4705c"
QUAY_TEST_DEST="test_complytime/complytime-policies"
TESTS_REPO="${ROOT}/../org-infra-tests/.github/workflows/reusable_publish_oras.yml"

if [[ ! -f "$WF" ]]; then
  echo "error: missing $WF" >&2
  exit 1
fi

python3 -c "import yaml; yaml.safe_load(open('${WF}'))"
echo "ok: publish-policy-oci.yml parses as YAML"

grep -qF "$ORG_INFRA_TESTS_PIN" "$WF" || {
  echo "error: expected org-infra-tests ref ${ORG_INFRA_TESTS_PIN} in workflow" >&2
  exit 1
}
echo "ok: workflow uses org-infra-tests @ ${ORG_INFRA_TESTS_PIN}"
grep -qF "sonupreetam/org-infra-tests" "$WF" || {
  echo "error: expected sonupreetam/org-infra-tests in workflow" >&2
  exit 1
}

grep -qF "$QUAY_TEST_DEST" "$WF" || {
  echo "error: expected default dest ${QUAY_TEST_DEST} in workflow" >&2
  exit 1
}
echo "ok: default dest_image matches test Quay repo (${QUAY_TEST_DEST})"

grep -qF "reusable_publish_oras.yml" "$WF" || {
  echo "error: expected publish-ghcr to use reusable_publish_oras" >&2
  exit 1
}
grep -qE "publish_mode: *gemara" "$WF" || {
  echo "error: expected publish-ghcr to set publish_mode: gemara" >&2
  exit 1
}
echo "ok: staging uses org-infra-tests/reusable_publish_oras (publish_mode: gemara)"
if [[ -f "$TESTS_REPO" ]]; then
  grep -qF "publish_mode: gemara" "$TESTS_REPO" || {
    echo "error: expected publish_mode: gemara in $TESTS_REPO" >&2
    exit 1
  }
  grep -qF "${INTERIM_ACTION}@${INTERIM_ACTION_REF}" "$TESTS_REPO" || {
    echo "error: expected ${INTERIM_ACTION}@${INTERIM_ACTION_REF} in $TESTS_REPO" >&2
    exit 1
  }
  echo "ok: sibling org-infra-tests oras workflow pins ${INTERIM_ACTION} @ ${INTERIM_ACTION_REF}"
else
  echo "skip: place org-infra-tests next to this repo to verify gemara composite pin in reusable_publish_oras.yml"
fi

echo
echo "Interim demo run (on GitHub):"
echo "  1) Fork or repo: Actions → Publish policy OCI → Run workflow"
echo "  2) release_tag: e.g. demo-0.0.1 (new tag; fail_if_dest_exists: true)"
echo "  3) allow_unprotected_ref: true on a fork or unprotected default branch"
echo "  4) dest_image: default (${QUAY_TEST_DEST}) for test Quay; robot must push there"
echo "  5) Quay repo URL: quay.io/${QUAY_TEST_DEST}:\$release_tag"
