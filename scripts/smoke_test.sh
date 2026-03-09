#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?Usage: smoke_test.sh <base_url>}"

echo "Smoke testing: $BASE_URL"

retry() {
  local url="$1"
  local name="$2"

  for i in {1..30}; do
    if curl -fsS "$url" >/dev/null; then
      echo "✅ $name ok"
      return 0
    fi
    echo "Waiting for $name... attempt $i/30"
    sleep 5
  done

  echo "❌ $name failed after retries"
  return 1
}

retry "$BASE_URL/api/health" "/api/health"
retry "$BASE_URL/api/health/db" "/api/health/db"

echo "✅ Smoke tests passed"