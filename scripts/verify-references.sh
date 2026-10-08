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
