#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?Usage: smoke_test.sh <base_url> (e.g. http://1.2.3.4)}"

echo "Smoke testing: $BASE_URL"

curl -fsS "$BASE_URL/api/health" >/dev/null
echo "✅ /api/health ok"

curl -fsS "$BASE_URL/api/health/db" >/dev/null
echo "✅ /api/health/db ok"

echo "✅ Smoke tests passed"