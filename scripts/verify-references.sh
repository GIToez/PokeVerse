#!/usr/bin/env bash
# Verifies references/ against references/MANIFEST.sha256 (taken from the original archive).
set -euo pipefail

cd "$(dirname "$0")/../references"
sha256sum --quiet -c MANIFEST.sha256

expected=$(wc -l < MANIFEST.sha256)
actual=$(find Projeto -type f | wc -l)
if [ "$expected" -ne "$actual" ]; then
  echo "File count mismatch: expected $expected, found $actual" >&2
  exit 1
fi
echo "OK: all $expected reference files match the original archive."

# OTClient Redemption: the committed tree must equal upstream commit 53c3878 and the working
# copy must not be modified.
otc_tree=d5c63e8c93175669866adb6cca946d9beab320bc
cd ..
if [ "$(git rev-parse HEAD:references/otclient-redemption)" != "$otc_tree" ]; then
  echo "references/otclient-redemption/ differs from upstream (expected tree $otc_tree)" >&2
  exit 1
fi
if ! git diff --quiet HEAD -- references/otclient-redemption; then
  echo "references/otclient-redemption/ has local modifications" >&2
  exit 1
fi
echo "OK: references/otclient-redemption/ matches upstream opentibiabr/otclient 53c3878."
