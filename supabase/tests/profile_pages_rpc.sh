#!/usr/bin/env bash
# profile_pages_test.sql through PostgREST: the migration 20261027223146_profile_pages.sql seen the way the app
# sees it (a signed-in user, JSON over /rest/v1/rpc/...). Local stack only.
# Usage: supabase/tests/profile_pages_rpc.sh   (needs `supabase start` with the migration applied;
#        makes three users, one post and one follow, and removes them afterwards)
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
BODY=$(mktemp)

make_user() { # email username -> prints "id token"
  local id token
  id=$(curl -s "$API_URL/auth/v1/admin/users" -H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H 'content-type: application/json' -d "{\"email\":\"$1\",\"password\":\"$PASSWORD\",\"email_confirm\":true}" | jq -r .id)
  psql_run -c "insert into public.profiles (id, username, full_name, birthday, signup_step)
               values ('$id', '$2', 'Test', '1990-01-01', 0)
               on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
                 birthday = excluded.birthday, signup_step = 0;" >/dev/null
  token=$(curl -s "$API_URL/auth/v1/token?grant_type=password" -H "apikey: $ANON_KEY" -H 'content-type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"$PASSWORD\"}" | jq -r .access_token)
  echo "$id $token"
}

cleanup() {
  psql_run -c "delete from public.posts where author_id in (select id from auth.users where email like 'rpc-%-$STAMP@t.test');
               delete from auth.users where email like 'rpc-%-$STAMP@t.test';" >/dev/null 2>&1 || true
  rm -f "$BODY"
}
trap cleanup EXIT

read -r A A_TOKEN < <(make_user "rpc-a-$STAMP@t.test" "zz_a${STAMP}")
read -r B B_TOKEN < <(make_user "rpc-b-$STAMP@t.test" "zz_b${STAMP}")
read -r C C_TOKEN < <(make_user "rpc-c-$STAMP@t.test" "zz_c${STAMP}")
P=$(psql_run -c "select gen_random_uuid();")
psql_run -c "insert into public.follows (follower_id, following_id) values ('$A', '$B');
             update public.profiles set is_private = true where id = '$C';
             insert into public.posts (id, author_id, caption, media_count, visibility) values ('$P', '$B', 'hi', 1, 'public');
             insert into public.post_media (post_id, position, type, path, width, height) values ('$P', 0, 'image', 'x/y.jpg', 10, 10);" >/dev/null

# rpc NAME TOKEN JSON -> "HTTP_STATUS"; the body stays in $BODY
rpc() {
  curl -s -o "$BODY" -w '%{http_code}' "$API_URL/rest/v1/rpc/$1" \
    -H "apikey: $ANON_KEY" -H "Authorization: Bearer $2" -H 'content-type: application/json' -d "$3"
}

json="{\"p_user\":\"$B\"}"
check "profile_by_id is 200" "$(rpc profile_by_id "$A_TOKEN" "$json")" "200"
check "profile has the counts and follow state" "$(jq -r '.[0] | "\(.username)|\(.posts_count)|\(.followers_count)|\(.i_follow)"' "$BODY")" "zz_b${STAMP}|1|1|accepted"
check "profile has no phone or birthday" "$(jq -r '.[0] | has("phone") or has("birthday") or has("email")' "$BODY")" "false"
check "an unknown profile is an empty list" "$(rpc profile_by_id "$A_TOKEN" '{"p_user":"00000000-0000-4000-8000-000000000001"}') $(jq length "$BODY")" "200 0"
check "no session is refused" "$(rpc profile_by_id "$ANON_KEY" "$json")" "401"

json="{\"p_user\":\"$B\",\"p_kind\":\"posts\"}"
check "user_posts shows the post" "$(rpc user_posts "$A_TOKEN" "$json") $(jq length "$BODY")" "200 1"
json="{\"p_user\":\"$C\",\"p_kind\":\"posts\"}"
check "a private profile's grid is empty for a stranger" "$(rpc user_posts "$A_TOKEN" "$json") $(jq length "$BODY")" "200 0"
check "shorts is 22023" "$(rpc user_posts "$A_TOKEN" "{\"p_user\":\"$B\",\"p_kind\":\"shorts\"}") $(jq -r .code "$BODY")" "400 22023"

json="{\"p_user\":\"$B\"}"
check "followers_of lists the follower" "$(rpc followers_of "$A_TOKEN" "$json") $(jq -r '.[0].id' "$BODY")" "200 $A"
check "a private profile's followers are empty for a stranger" "$(rpc followers_of "$B_TOKEN" "{\"p_user\":\"$C\"}") $(jq length "$BODY")" "200 0"
check "profile_id_by_username finds the id" "$(rpc profile_id_by_username "$A_TOKEN" "{\"p_username\":\"@zz_b${STAMP}\"}") $(jq -r . "$BODY")" "200 $B"
check "saved_posts runs" "$(rpc saved_posts "$A_TOKEN" '{}') $(jq length "$BODY")" "200 0"

echo
if [[ $failures -eq 0 ]]; then echo "all passed"; else echo "$failures failed"; exit 1; fi
