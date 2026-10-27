#!/usr/bin/env bash
# profile_settings_test.sql: the Phase 2 migrations (privacy, blocks, post notifications, help and reports, delete
# account) checked on the local database. The test checks itself and always rolls back.
# Usage: supabase/tests/profile_settings_rpc.sh   (needs `supabase start` with the migrations applied)
set -euo pipefail

DB_CONTAINER=${DB_CONTAINER:-supabase_db_pulse}
HERE=$(cd "$(dirname "$0")" && pwd)

out=$(docker exec -i "$DB_CONTAINER" psql -U postgres -X -q -v ON_ERROR_STOP=0 < "$HERE/profile_settings_test.sql" 2>&1 || true)
result=$(grep -o 'VALIDATION_RESULT.*' <<<"$out" | head -1 || true)

if [[ "$result" == "VALIDATION_RESULT all passed" ]]; then
  echo "all passed"
else
  echo "${result:-$out}"
  exit 1
fi
