#!/usr/bin/env bash
# update_post_settings_test.sql through PostgREST: the migration 20261027173905_update_post_settings.sql seen the way
# the app sees it (a signed-in user, JSON over /rest/v1/rpc/update_post). Local stack only.
# Usage: supabase/tests/update_post_settings_rpc.sh   (needs `supabase start` with the migration applied;
#        makes two users, one post and a few storage rows, and removes them afterwards)
set -euo pipefail

DB_CONTAINER=${DB_CONTAINER:-supabase_db_pulse}
failures=0

eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY)=')"
: "${API_URL:?supabase is not running}"

psql_run() { docker exec -i "$DB_CONTAINER" psql -U postgres -X -q -t -A -v ON_ERROR_STOP=1 "$@"; }

check() {
  if [[ "$2" == "$3" ]]; then echo "ok - $1"; else echo "not ok - $1 (have: $2, want: $3)"; failures=$((failures + 1)); fi
}

STAMP=$(date +%s)
PASSWORD="Pulse-test-1-$STAMP"

make_user() { # email -> prints "id token"
  local id token
  id=$(curl -s "$API_URL/auth/v1/admin/users" -H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H 'content-type: application/json' -d "{\"email\":\"$1\",\"password\":\"$PASSWORD\",\"email_confirm\":true}" | jq -r .id)
  psql_run -c "insert into public.profiles (id, username, full_name, birthday, signup_step)
               values ('$id', 'zz_${id:0:8}', 'Test', '1990-01-01', 0)
               on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
                 birthday = excluded.birthday, signup_step = 0;" >/dev/null
  token=$(curl -s "$API_URL/auth/v1/token?grant_type=password" -H "apikey: $ANON_KEY" -H 'content-type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"$PASSWORD\"}" | jq -r .access_token)
  echo "$id $token"
}

cleanup() {
  # make_user runs in a subshell, so the users are found by their e-mails.
  # storage refuses a plain delete of its rows unless the transaction says it is on purpose.
  psql_run -c "set local storage.allow_delete_query = 'true';
               delete from storage.objects where bucket_id = 'post-media'
                 and split_part(name, '/', 1) in (select id::text from auth.users where email like 'rpc-%-$STAMP@t.test');
               delete from public.posts where author_id in (select id from auth.users where email like 'rpc-%-$STAMP@t.test');
               delete from auth.users where email like 'rpc-%-$STAMP@t.test';" >/dev/null 2>&1 || true
}
trap cleanup EXIT

read -r A A_TOKEN < <(make_user "rpc-a-$STAMP@t.test")
read -r B B_TOKEN < <(make_user "rpc-b-$STAMP@t.test")
read -r C _ < <(make_user "rpc-c-$STAMP@t.test")
P=$(psql_run -c "select gen_random_uuid();")
PRE="$A/$P/"

reset_post() {
  psql_run -c "delete from public.posts where id = '$P';
               insert into public.posts (id, author_id, caption, location, media_count, comments_enabled, visibility)
                 values ('$P', '$A', 'old caption', 'old place', 2, false, 'close_friends');
               insert into public.post_media (post_id, position, type, path, width, height) values
                 ('$P', 0, 'image', '${PRE}0.jpg', 10, 10), ('$P', 1, 'image', '${PRE}1.jpg', 10, 10);" >/dev/null
}
psql_run -c "insert into storage.objects (bucket_id, name, owner_id, metadata) values
  ('post-media', '${PRE}0.jpg', '$A', '{\"size\":1000,\"mimetype\":\"image/jpeg\"}'),
  ('post-media', '${PRE}1.jpg', '$A', '{\"size\":1000,\"mimetype\":\"image/jpeg\"}'),
  ('post-media', '${PRE}n0.jpg', '$A', '{\"size\":1000,\"mimetype\":\"image/jpeg\"}');" >/dev/null

media_old() { echo "[{\"type\":\"image\",\"path\":\"${PRE}0.jpg\",\"width\":10,\"height\":10},{\"type\":\"image\",\"path\":\"${PRE}1.jpg\",\"width\":10,\"height\":10}]"; }
post_row() { psql_run -c "select caption || '|' || comments_enabled || '|' || visibility || '|' || media_count from public.posts where id = '$P';"; }

# Build the JSON in a variable first: macOS bash 3.2 brace-expands a `{a,b}` inside a quoted $( ) argument.
# rpc TOKEN JSON -> "HTTP_STATUS CODE" (code is the Postgres/PostgREST error code, empty on success)
rpc() {
  local out
  out=$(curl -s -o /tmp/update_post_rpc_body -w '%{http_code}' "$API_URL/rest/v1/rpc/update_post" \
    -H "apikey: $ANON_KEY" -H "Authorization: Bearer $1" -H 'content-type: application/json' -d "$2")
  echo "$out $(jq -r '.code // empty' /tmp/update_post_rpc_body 2>/dev/null || true)"
}

# 1. the old call, exactly the 8 parameters the app sent before the migration
reset_post
json="{\"p_id\":\"$P\",\"p_caption\":\"new caption\",\"p_location\":\"new place\",\"p_media\":$(media_old),\"p_mood_kind\":null,\"p_mood_key\":null,\"p_mood_text\":null,\"p_tags\":[]}"
check "old 8-parameter call is accepted" "$(rpc "$A_TOKEN" "$json")" "204 "
check "old call leaves comments and audience as they were" "$(post_row)" "new caption|false|close_friends|2"

# 2. settings given
reset_post
json="{\"p_id\":\"$P\",\"p_caption\":\"both\",\"p_media\":$(media_old),\"p_comments_enabled\":true,\"p_visibility\":\"only_me\"}"
check "settings call is accepted" "$(rpc "$A_TOKEN" "$json")" "204 "
check "comments switch and audience changed with the caption" "$(post_row)" "both|true|only_me|2"
json="{\"p_id\":\"$P\",\"p_caption\":\"c\",\"p_media\":$(media_old),\"p_comments_enabled\":false}"
check "comments only" "$(rpc "$A_TOKEN" "$json")" "204 "
check "comments only leaves the audience" "$(post_row)" "c|false|only_me|2"

# 3. explicit nulls and omitted keys change nothing
reset_post
json="{\"p_id\":\"$P\",\"p_caption\":\"n\",\"p_media\":$(media_old),\"p_comments_enabled\":null,\"p_visibility\":null}"
check "explicit nulls accepted" "$(rpc "$A_TOKEN" "$json")" "204 "
check "explicit nulls change no setting" "$(post_row)" "n|false|close_friends|2"

# 4. invalid audience, someone else, no session
reset_post
json="{\"p_id\":\"$P\",\"p_caption\":\"x\",\"p_media\":[],\"p_visibility\":\"secret\"}"
check "invalid audience is 22023" "$(rpc "$A_TOKEN" "$json")" "400 22023"
json="{\"p_id\":\"$P\",\"p_caption\":\"x\",\"p_media\":[],\"p_comments_enabled\":true,\"p_visibility\":\"public\"}"
check "another user is refused" "$(rpc "$B_TOKEN" "$json")" "403 42501"
json="{\"p_id\":\"$P\",\"p_caption\":\"x\",\"p_media\":[]}"
check "no session is refused" "$(rpc "$ANON_KEY" "$json")" "401 42501"
check "refused calls change nothing" "$(post_row)" "old caption|false|close_friends|2"

# 5. a failure after the updates (21 tags) rolls everything back
TAGS=$(jq -nc '[range(0;21) | {user_id: "00000000-0000-4000-8000-\(1000000000 + . | tostring | .[0:12])"}]')
json="{\"p_id\":\"$P\",\"p_caption\":\"half\",\"p_media\":[{\"type\":\"image\",\"path\":\"${PRE}n0.jpg\",\"width\":10,\"height\":10}],\"p_tags\":$TAGS,\"p_comments_enabled\":true,\"p_visibility\":\"only_me\"}"
check "21 tags fail with check_violation" "$(rpc "$A_TOKEN" "$json")" "400 23514"
check "the failed call rolled back caption, settings and media" "$(post_row)" "old caption|false|close_friends|2"
check "the old media rows are still there" "$(psql_run -c "select count(*) from public.post_media where post_id = '$P';")" "2"

# 6. media and tags
json="{\"p_id\":\"$P\",\"p_caption\":\"m\",\"p_media\":[{\"type\":\"image\",\"path\":\"${PRE}n0.jpg\",\"width\":20,\"height\":20}],\"p_tags\":[{\"user_id\":\"$C\"}]}"
check "media replaced and a tag stored" "$(rpc "$A_TOKEN" "$json")" "204 "
check "one media row, one tag" "$(psql_run -c "select (select count(*) from public.post_media where post_id = '$P') || '|' || (select count(*) from public.post_tags where post_id = '$P') || '|' || (select media_count from public.posts where id = '$P');")" "1|1|1"
json="{\"p_id\":\"$P\",\"p_caption\":\"x\",\"p_media\":[{\"type\":\"image\",\"path\":\"${PRE}missing.jpg\",\"width\":10,\"height\":10}]}"
check "a file that was not uploaded is 22023" "$(rpc "$A_TOKEN" "$json")" "400 22023"

# 7. one function, so PostgREST has nothing to be ambiguous about
check "exactly one update_post in the schema" "$(psql_run -c "select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'update_post';")" "1"

echo
if [[ $failures -eq 0 ]]; then echo "all passed"; else echo "$failures failed"; exit 1; fi
