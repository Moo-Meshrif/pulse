#!/usr/bin/env bash
# Phase 1 of docs/plans/content-publishing-plan.md: two sessions racing on one item (local stack only).
# Session 1 holds the item's lock for 2 s; session 2 starts meanwhile and must wait, then see the result.
# Usage: supabase/tests/content_publishing_race.sh   (needs `supabase start`; cleans up after itself)
set -euo pipefail

DB_CONTAINER=${DB_CONTAINER:-supabase_db_pulse}
A=a1000000-0000-4000-8000-000000000000
failures=0

psql_run() { docker exec -i "$DB_CONTAINER" psql -U postgres -X -q -t -A -v ON_ERROR_STOP=1 "$@"; }

# Runs SQL as A in its own session; an error prints "ERR <sqlstate>".
as_a() {
  psql_run <<SQL 2>&1 | grep -v '^$' | sed -E 's/^ERROR: +([0-9A-Z]{5}).*/ERR \1/' | tail -1
\\set VERBOSITY sqlstate
select set_config('request.jwt.claims', '{"sub":"$A","role":"authenticated"}', false);
set role authenticated;
$1
SQL
}

check() {
  if [[ "$2" == "$3" ]]; then echo "ok - $1"; else echo "not ok - $1 (have: $2, want: $3)"; failures=$((failures + 1)); fi
}

item() { printf '00000000-0000-4000-8000-1000000000%02d' "$1"; }

request() {
  echo "{\"caption\":\"race\",\"media\":[{\"type\":\"image\",\"path\":\"$A/$1/0.jpg\",\"width\":10,\"height\":10,\"size\":1000,\"mime\":\"image/jpeg\"}]}"
}

share_and_upload() {
  as_a "select public.share_content('$1', 'post', '$(request "$1")');" >/dev/null
  psql_run -c "insert into storage.objects (bucket_id, name, owner_id, metadata)
               values ('post-media', '$A/$1/0.jpg', '$A', '{\"size\":1000,\"mimetype\":\"image/jpeg\"}');" >/dev/null
}

posts_with_id() { psql_run -c "select count(*) from public.posts where id = '$1';"; }

cleanup() {
  psql_run >/dev/null <<SQL
set storage.allow_delete_query = 'true';
delete from storage.objects where name like '$A/%';
delete from auth.users where id = '$A';
SQL
}
trap cleanup EXIT

cleanup
psql_run >/dev/null <<SQL
insert into auth.users (id, email) values ('$A', 'race@test.local');
update public.profiles set username = 'race_a', full_name = 'Race', birthday = '1990-01-01', signup_step = 0 where id = '$A';
SQL

# 1. Discard holds the lock; a publish arriving meanwhile must see 'discarded' and post nothing.
X=$(item 1); share_and_upload "$X"
as_a "begin; select public.discard_content('$X', 'post'); select pg_sleep(2); commit;" >/dev/null &
sleep 0.5
check "publish during discard is refused" "$(as_a "select public.publish_content('$X');")" "discarded"
wait
check "no post after discard" "$(posts_with_id "$X")" "0"

# 2. Publish holds the lock; a discard arriving meanwhile must say it already went out.
Y=$(item 2); share_and_upload "$Y"
as_a "begin; select public.publish_content('$Y'); select pg_sleep(2); commit;" >/dev/null &
sleep 0.5
check "discard during publish says published" "$(as_a "select public.discard_content('$Y', 'post');")" "published"
wait
check "exactly one post" "$(posts_with_id "$Y")" "1"

# 3. Share holds the lock on a draft; the discard that comes second wins: the item is never posted.
Z=$(item 3)
as_a "select public.open_draft('$Z', 'post');" >/dev/null
psql_run -c "insert into storage.objects (bucket_id, name, owner_id, metadata)
             values ('post-media', '$A/$Z/0.jpg', '$A', '{\"size\":1000,\"mimetype\":\"image/jpeg\"}');" >/dev/null
as_a "begin; select public.share_content('$Z', 'post', '$(request "$Z")'); select pg_sleep(2); commit;" >/dev/null &
sleep 0.5
check "discard during share" "$(as_a "select public.discard_content('$Z', 'post');")" "discarded"
wait
check "the job does not post it" "$(psql_run -c "select public.publish_due(); select state from public.pending_content where id = '$Z';" | tail -1)" "discarded"
check "no post after share + discard" "$(posts_with_id "$Z")" "0"

# 4. Discard holds the lock on a draft; the share that comes second is refused.
W=$(item 4)
as_a "select public.open_draft('$W', 'post');" >/dev/null
as_a "begin; select public.discard_content('$W', 'post'); select pg_sleep(2); commit;" >/dev/null &
sleep 0.5
check "share during discard is refused" "$(as_a "select public.share_content('$W', 'post', '$(request "$W")');")" "ERR 55000"
wait

# 5. Two publishes at once make one post.
V=$(item 5); share_and_upload "$V"
as_a "begin; select public.publish_content('$V'); select pg_sleep(2); commit;" >/dev/null &
sleep 0.5
check "second publish waits, then returns published" "$(as_a "select public.publish_content('$V');")" "published"
wait
check "two publishes make one post" "$(posts_with_id "$V")" "1"

if [[ $failures -gt 0 ]]; then echo "$failures failed"; exit 1; fi
echo "all passed"
