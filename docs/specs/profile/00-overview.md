# Profile: overview

App: Pulse (Flutter, phone, light only, LTR + RTL, EN + AR). Design frame 390x844 [user]. No Figma. Screenshots: `screenshots/` (S12 is a board the user pasted in chat, no file). Theme: reuse `docs/specs/_theme/` and `lib/core/theme/`; deltas in `01-design-tokens.md`. RTL: `docs/specs/_theme/rtl.md`.

Feature scope [user]: own profile (S1), Settings and its pages (S2-S11, S14), someone else's profile (S12), people list (S13). One feature folder `profile`. `features/profile` today holds data/domain only (profile, interests, sign-up step); presentation is new.

## Screens
| ID | Name | Route | File |
|---|---|---|---|
| S1 | profile (own) | `/home` Profile tab root; `/u/:username` with own username resolves here | screens/s1-profile.md |
| S2 | settings | `/settings` | screens/s2-settings.md |
| S3 | personal-info | `/settings/personal-info` | screens/s3-personal-info.md |
| S4 | password-security | `/settings/security` | screens/s4-password-security.md |
| S5 | privacy | `/settings/privacy` | screens/s5-privacy.md |
| S6 | blocked-accounts | `/settings/blocked` | screens/s6-blocked-accounts.md |
| S7 | notifications | `/settings/notifications` | screens/s7-notifications.md |
| S8 | language | `/settings/language` | screens/s8-language.md |
| S9 | help-center | `/settings/help` | screens/s9-help-center.md |
| S10 | report-problem | `/settings/report` | screens/s10-report-problem.md |
| S11 | terms-policies | `/settings/terms` | screens/s11-terms-policies.md |
| S12 | other-profile (+ Following sheet, Options sheet, states) | `/u/:username` | screens/s12-other-profile.md |
| S13 | people-list (Followers, Following, Followed by) | `/people?kind=` | screens/s13-people-list.md |
| S14 | help-topic | `/settings/help/topic` | screens/s14-help-topic.md |

## Navigation map
- Profile tab (S1) -> sliders button -> S2; share button -> system share sheet; stats Followers/Following -> S13; avatar of anyone anywhere -> `/u/:username` (S12, or S1 if own).
- S2 rows: Personal info -> S3; Password & security -> S4; Privacy -> S5; Blocked accounts -> S6; Notifications -> S7; Language -> S8; Help center -> S9; Report a problem -> S10; Terms & policies -> S11. Log out -> dialog -> `/sign-in`. Delete account -> password dialog -> `/sign-in`.
- S5 Blocked accounts row -> S6. S4 Forgot password -> existing reset email flow. S9 topic card -> S14; Report a problem button -> S10. S11 rows -> existing legal routes `/terms`, `/privacy`, `/community-guidelines`, `/cookie-policy`, `/open-source-licenses`.
- S12 "Followed by" -> S13 (mutual); Followers/Following stats -> S13; Message -> "coming soon" notice.

## Scope decisions [user]
Built: everything seen, except the S8 languages other than English/Arabic (dropped, not shown) and the "coming soon" items: Shorts tab content, S4 two-factor + login alerts + device sessions list, S2 Dark mode toggle, S9 Chat with us, S12 Message button, S11 Download your data and Ad preferences (see open-questions Q-S11).

## Known gaps in code and schema (plan must add)
No followers/following list screens; no `blocks`, `post_subscriptions`, `problem_reports`, help content tables; profiles lack cover, `is_verified`, who-can-message, who-can-comment, show-activity, appear-in-search; `reports` is posts-only (profile report needs extending); profile counts RPCs (`profile_by_username`, `mutual_followers_preview`, `user_posts`) are new; account delete is new. Existing and reused: `notification_prefs` + `set_notification_prefs`, `mutes`, `close_friends`, `follows.status`, `profiles.is_private`, `username_exists`, legal routes.
