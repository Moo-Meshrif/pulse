#!/usr/bin/env bash
# Deploy checks for the `sign-in` function (plan Phase 3c). Usage:
#   bash supabase/functions/sign-in/check.sh anonymous   # no account needed (made-up identifiers)
#   bash supabase/functions/sign-in/check.sh accounts    # needs the PULSE_TEST_* environment variables
# It prints statuses, header names and yes/no results only: never a password, token or email.
set -u
URL="${PULSE_SUPABASE_URL:-$(grep -o 'https://[a-z0-9]*\.supabase\.co' "$(dirname "$0")/../../../lib/core/config/app_config.dart" | head -1)}/functions/v1/sign-in"
VOLATILE='^(date|cf-ray|set-cookie|sb-request-id|x-deno-execution-id|endpoint-load-metrics|content-length|cf-cache-status)'

# post <identifier> <password> [x-forwarded-for]  ->  writes /tmp/pulse_h /tmp/pulse_b, prints the HTTP status
post() {
  local extra=()
  [ -n "${3:-}" ] && extra=(-H "x-forwarded-for: $3")
  python3 - "$1" "$2" > /tmp/pulse_payload <<'PY'
import json,sys
print(json.dumps({"identifier": sys.argv[1], "password": sys.argv[2]}))
PY
  curl -s -o /tmp/pulse_b -D /tmp/pulse_h -w '%{http_code}' -X POST "$URL" \
    -H 'Content-Type: application/json' ${extra[@]+"${extra[@]}"} --data @/tmp/pulse_payload
}
stable_headers() { tr -d '\r' < /tmp/pulse_h | grep -v -i -E "$VOLATILE" | sort; }
payload() { python3 -c 'import json,sys;print(json.dumps({"identifier":sys.argv[1],"password":sys.argv[2]}))' "$1" "$2" > /tmp/pulse_payload; }
timed() { curl -s -o /dev/null -w '%{time_total}' -X POST "$URL" -H 'Content-Type: application/json' --data @/tmp/pulse_payload; }
wait_window() { echo "  (waiting $1 s for the per-IP window to clear)"; sleep "$1"; }

anonymous() {
  local a b c
  echo "== 1. unknown username, unknown email and a wrong password look identical"
  s1=$(post "nobody.$RANDOM$RANDOM" 'wrong-password-1');  b1=$(cat /tmp/pulse_b); h1=$(stable_headers)
  s2=$(post "nobody$RANDOM$RANDOM@example.com" 'wrong-password-1'); b2=$(cat /tmp/pulse_b); h2=$(stable_headers)
  echo "  username: $s1 $b1"; echo "  email   : $s2 $b2"
  [ "$s1|$b1|$h1" = "$s2|$b2|$h2" ] && echo "  RESULT identical status, body and headers: YES" || { echo "  RESULT identical: NO"; echo "$h1" > /tmp/pulse_h1; echo "$h2" > /tmp/pulse_h2; diff /tmp/pulse_h1 /tmp/pulse_h2; }

  echo "== 2. response times (seconds; both are padded to ~0.4)"
  payload "nobody.$RANDOM$RANDOM" 'x'; printf '  unknown username: '; timed; echo
  payload "nobody$RANDOM$RANDOM@example.com" 'x'; printf '  unknown email   : '; timed; echo

  wait_window 61
  echo "== 3. does a spoofed x-forwarded-for change the per-IP throttle key? (12 attempts, a new made-up identifier and a new spoofed IP each time; the per-IP limit is 5 per minute)"
  codes=""; for i in $(seq 1 12); do codes="$codes $(post "spoof.$RANDOM$RANDOM" 'x' "198.51.100.$i")"; done
  echo "  statuses:$codes"
  n429=$(echo "$codes" | tr ' ' '\n' | grep -c '^429$')
  if [ "$n429" -eq 0 ]; then echo "  RESULT: SPOOFABLE (no 429 in 12 calls from one real IP): the first x-forwarded-for entry is client-controlled; use the last entry"
  else echo "  RESULT: not spoofable ($n429 calls hit the real-IP limit): the platform replaces the header"; fi

  wait_window 61
  echo "== 4. the 6th attempt for one identifier in 15 minutes is a 429 with Retry-After (a wait far above 60 s proves it is the identifier limit, not the per-IP one)"
  id="limit.$RANDOM$RANDOM"; codes=""
  for i in $(seq 1 5); do codes="$codes $(post "$id" 'x' "203.0.113.$i")"; done
  wait_window 61
  codes="$codes $(post "$id" 'x' "203.0.113.9")"
  echo "  statuses:$codes"; echo "  last response headers: $(tr -d '\r' < /tmp/pulse_h | grep -i '^retry-after')  body: $(cat /tmp/pulse_b)"
  echo "== 5. bad input"; for body in '{}' 'not json'; do printf '%s' "$body" > /tmp/pulse_payload; printf '  %s -> ' "$body"; curl -s -o /tmp/pulse_b -w '%{http_code} ' -X POST "$URL" -H 'Content-Type: application/json' --data @/tmp/pulse_payload; cat /tmp/pulse_b; echo; done
  printf '  GET -> '; curl -s -o /tmp/pulse_b -w '%{http_code} ' "$URL"; cat /tmp/pulse_b; echo
}

accounts() {
  local envfile; envfile="$(cd "$(dirname "$0")" && pwd)/.env.test"
  [ -f "$envfile" ] || { echo "missing $envfile"; return 1; }
  git check-ignore -q "$envfile" || { echo ".env.test is not ignored by git: refusing to run"; return 1; }
  set -a; . "$envfile"; set +a
  for v in PULSE_TEST_VERIFIED_EMAIL PULSE_TEST_VERIFIED_USERNAME PULSE_TEST_VERIFIED_PASSWORD PULSE_TEST_UNVERIFIED_EMAIL PULSE_TEST_UNVERIFIED_PASSWORD; do
    [ -n "$(printenv $v)" ] || { echo "$v is empty in .env.test"; return 1; }
  done
  wait_window 61
  check_tokens() {  # status + body -> which keys, and whether an email appears
    python3 - <<'PY'
import json
b=open('/tmp/pulse_b').read()
try: d=json.loads(b)
except Exception: d={}
print("  keys:", sorted(d.keys()))
PY
  }
  echo "== 6. email + password returns tokens only"
  s=$(post "$PULSE_TEST_VERIFIED_EMAIL" "$PULSE_TEST_VERIFIED_PASSWORD"); echo "  status: $s"; check_tokens
  grep -q -F -- "$PULSE_TEST_VERIFIED_EMAIL" /tmp/pulse_b && echo "  RESULT body contains the email: YES (bad)" || echo "  RESULT body contains the email: no"
  echo "== 7. username + password returns tokens only"
  s=$(post "$PULSE_TEST_VERIFIED_USERNAME" "$PULSE_TEST_VERIFIED_PASSWORD"); echo "  status: $s"; check_tokens
  grep -q -F -- "$PULSE_TEST_VERIFIED_EMAIL" /tmp/pulse_b && echo "  RESULT body contains the email: YES (bad)" || echo "  RESULT body contains the email: no"
  echo "== 8. a wrong password for a real account is the same 401 as an unknown user"
  s=$(post "$PULSE_TEST_VERIFIED_USERNAME" "definitely-wrong-$RANDOM"); b=$(cat /tmp/pulse_b); h=$(stable_headers)
  s0=$(post "nobody.$RANDOM$RANDOM" "definitely-wrong-$RANDOM"); b0=$(cat /tmp/pulse_b); h0=$(stable_headers)
  echo "  real user, wrong password: $s $b"; echo "  unknown user             : $s0 $b0"
  [ "$s|$b|$h" = "$s0|$b0|$h0" ] && echo "  RESULT identical: YES" || echo "  RESULT identical: NO"
  echo "== 8b. timing, wrong password: real username (3 runs; the identifier allows 5 per 15 min and 2 are used) vs unknown username (5 runs), in two batches of at most 5 calls (the per-IP limit is 5 per minute)"
  wait_window 61
  local real=() unk=()
  one() {  # kind
    if [ "$1" = u ]; then payload "nobody.$RANDOM$RANDOM" "wrong-$RANDOM"; unk+=("$(timed)")
    else payload "$PULSE_TEST_VERIFIED_USERNAME" "wrong-$RANDOM"; real+=("$(timed)"); fi
  }
  one u; one r; one u; one r; one u
  wait_window 61
  one r; one u; one u
  python3 - "${real[*]}" "${unk[*]}" <<'PYX'
import sys,statistics as st
for name,v in (("real username   ",sys.argv[1]),("unknown username",sys.argv[2])):
    x=[float(i) for i in v.split()]; print(f"  {name}: n={len(x)} min={min(x):.3f} median={st.median(x):.3f}")
PYX
  wait_window 61
  echo "== 9. unverified account: correct password -> 403 with the email; wrong password -> generic 401"
  s=$(post "$PULSE_TEST_UNVERIFIED_EMAIL" "$PULSE_TEST_UNVERIFIED_PASSWORD"); echo "  correct password: status $s, body code: $(python3 -c "import json;print(json.load(open('/tmp/pulse_b')).get('code'))")"
  grep -q -F -- "$PULSE_TEST_UNVERIFIED_EMAIL" /tmp/pulse_b && echo "  RESULT 403 body contains the email: yes (expected only here)" || echo "  RESULT 403 body contains the email: no"
  s=$(post "$PULSE_TEST_UNVERIFIED_EMAIL" "definitely-wrong-$RANDOM"); echo "  wrong password  : status $s, body: $(cat /tmp/pulse_b)"
}

case "${1:-}" in anonymous) anonymous ;; accounts) accounts ;; *) echo "usage: $0 anonymous|accounts"; exit 2 ;; esac
rm -f /tmp/pulse_payload /tmp/pulse_b /tmp/pulse_h /tmp/pulse_h1 /tmp/pulse_h2
