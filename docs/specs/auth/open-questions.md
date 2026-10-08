# Auth: open questions

| # | Question | Default used in the specs | Options |
|---|---|---|---|
| Q1 | RESOLVED [user]: arrow on steps 4-8 = previous step; step 3 arrow and system back (steps 3-8) open S10 | - | - |
| Q2 RESOLVED [user, 2026-10-08]: schema supplied and trimmed to the specs in `schema.sql` (not applied yet). Original question: Supabase schema: profiles, interests, follows tables, storage bucket for avatars, suggested/popular queries, "required data" for resume | Field names full_name, username, birthday, gender, avatar_url, bio, city, phone, interests, follows `[estimated]`; required = full_name, username, birthday | user provides schema |
| Q3 | RESOLVED [user, as written]. S9 "Resend link" and "Change email" behavior (user did not answer these) | Resend: call again with 30 s cooldown; Change email: close dialog + focus field | confirm / change |
| Q4 | RESOLVED [user]: reset finishes via the emailed link -> S11 -> S12 (Supabase cannot email a password) | - | - |
| Q13 TODO | Recovery deep link: URL scheme, Supabase redirect URL, and the expired/invalid link state (not designed) | link opens `/reset-password` | user configures Supabase + provides state design |
| Q5 TODO | Terms / Privacy placeholder screens: content and titles | Title only + "Coming soon" body | provide copy later |
| Q6 | RESOLVED [user]: `ic_warning.svg` added to assets/icons | - | - |
| Q7 TODO | Avatar color assignment rule (S8) | Mock data pins the 6 colors seen; real rule: stable hash of user id -> palette index | confirm |
| Q8 | Exact paddings measured by eye (top offsets, gaps between sections, OTP box 50x60, avatar 88, dialog title size) | values in screens/*.md tagged `[estimated]` | review against screenshots during implementation |
| Q9 | Arabic copy | drafts tagged `[draft, x-review]` | user review |
| Q10 | RESOLVED [user]: Leave = sign out, then `/sign-in` | - | - |

| Q11 | RESOLVED [user]: `ic_trash.svg` added to assets/icons | - | - |
| Q12 | RESOLVED [user]: no auto-switch; each factory fixes its own title, description, buttons and button layout | - | - |
| Q14 | RESOLVED [user]: `ic_key.svg` added to assets/icons | - | - |

## Decisions from spec-to-plan (2026-10-08) [user]
- Q2 (superseded): the user supplied the schema; `schema.sql` is its trimmed form. Everything uses real Supabase once the migration is applied; no in-memory fake is planned.
- Q17 (SUPERSEDED by Q27: sign-in now goes through the `sign-in` Edge Function and the RPC is service-role only): S1 accepts email OR username as in the screenshot; usernames resolve through RPC `get_email_for_username` (callable by anon, can enumerate usernames; rate-limit it or move to an Edge Function later).
- Q18 (new): resume reads `profiles.signup_step` (3..6 = next step, 0 = complete) instead of the estimated required-fields rule.
- Q15 (resolved): a new Supabase project `pulse` (`xwldtqsvcpyzktysgmuv`, eu-west-1, free plan, in the user's org) was created with the Supabase MCP; the existing project "Waslaa" is a separate live app and is not touched. URL `https://xwldtqsvcpyzktysgmuv.supabase.co`; the anon / publishable key goes in the app constants file (public by design) in Phase 0. `schema.sql` is applied.
- Q16 (TODO, deferred to later): user will change the Supabase "Confirm signup" email template to include the 6-digit `{{ .Token }}` so S4's `verifyOTP(type: signup)` works.
- Q5, Q7, Q8 and the `/home` placeholder: spec defaults accepted (Terms/Privacy = title + "Coming soon"; avatar color = stable hash of user id -> palette index; `[estimated]` values used and checked against screenshots).
- Q13 (partly resolved): the expired/invalid-link state is specced in S11 (message + "Request a new link" -> S2) [user]. TODO (later): add the redirect URL `pulse://reset-password` in the Supabase dashboard (Authentication -> URL Configuration); the native URL-scheme config is built in Phase 10.
- Q19 (new, resolved): leaving the flow keeps progress; resume is at the saved `signup_step` and the S10 copy says so [user].
- Q20 (new, resolved): S7 is skipped when the interests list is empty (checked on step 4 Continue/Skip); S8 is skipped, straight to `/home`, when Suggested and Popular are both empty (checked on step 5 Continue/Skip); an empty tab on S8 shows a message only; the S8 school meta line is dropped (mutual friends or city, hidden otherwise) [user].
- Q21: column renamed `onboarding_step` -> `signup_step` (the app's "onboarding" is the intro screens) [user]; `schema.sql` also backfills profile rows for existing auth users.
- Q22 (superseded by S13): the user supplied the splash designs (loading, offline, can't reach): `screens/s13-splash.md`. The shared `AppLoadingView` stays for other screens waiting for first data.
- Q23 (final architecture, resolved) [user, review of the data layer]: features are capabilities (interests and follows live in `profile`); datasource interface + Supabase adapter in one file per concern, returning `data/model` classes; a repository only for `profile` (remote + local copy, "update profile saves it locally"); entity only for the profile; features trade only through use cases; the sign-up flow lives in `auth`; `startup` is named `splash`. Details: `00-overview.md` -> Structure.
- Q24 (TODO, needs the user; Phase 3b shipped without the automatic retry, the "Try again" button works): S13's offline copy promises "We'll try again as soon as you're back online". Default: add `connectivity_plus` and retry automatically when the connection returns, besides the "Try again" button. Confirm the new dependency, or drop the automatic retry and change the copy.
- Q25 (estimated, confirm): which failures show which splash state. Default: lost connection or timeout -> Offline; expired session -> Sign in; every other failure -> Can't reach Pulse.
- Q26: S13 measurements are `[estimated]` from the screenshots (72 tile, 14 gap, wordmark 30, spinner 28 / stroke 3 with a grey track, 96 circle, 40 icon, title 26, button bottom 48) (Q8).
- Q27 (DONE in Phase 3c, 2026-10-08; B12 outcome in the plan): username sign-in leaked emails (the RPC `get_email_for_username` was callable by `anon`). Decision [user]: sign-in moves to an Edge Function (`sign-in`): input validation, per-IP and per-identifier throttling (private table + `hit_rate_limit`), a generic 401 for unknown user / unknown email / wrong password, a 403 with the email only after a correct password, padded response times. The RPC becomes service-role only and leaves the app. S1 states added in Phase 4: "Too many attempts. Try again in {time}." with Sign in disabled until the countdown ends. Supersedes the "can enumerate usernames" note of Q17. Open: B12 (Auth's per-IP limit and the forwarded client IP).

