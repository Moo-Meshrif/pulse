# Post visibility picker (S4)
Screenshot: `../screenshots/s4-visibility.png` (board "Post visibility picker", 4 panels + Tokens / Options / Data notes) [user, 2026-10-14]. Answers Q1.
Purpose: choose who can see a post. Opened from the audience chip on New post (S1) and from your own post's options (S2, new row "Change who can see"). Light sheet, same shell as Post options [seen].

## Panels
| # | Panel | Content [seen] |
|---|---|---|
| 1 | Picker (from New post) | Title "Who can see this post?" + close X; group of 4 rows (Public, Followers, Close friends + Edit pill, Only me), radio at end; "Use for future posts" + sub "You can change it in Settings → Privacy" + toggle; "Done" pill |
| 2 | Private account | Amber note under the title: "Your account is private, so only your followers can see your posts. **Privacy settings**" (link); Public row disabled with sub "Off while your account is private"; default becomes Followers |
| 3 | Chosen · close friends | Back on New post: chip turns primary ("Close friends", star icon); one-time dark notice at top "Sharing with close friends" / "12 people will see this post" (star tile); the board's "Post" button stays "Share post" (Q-V3) |
| 4 | Change later (post options) | Title "Change who can see", "Currently: Followers"; same 4 rows (no future-posts toggle); footer note "Likes and comments from people who lose access are kept but hidden from them."; "Save" pill. Feed card meta shows a 12 icon for non-public posts ("Cairo · 2h · [users icon]") |

## Layout tree (panel 1)
```
AppBottomSheet (surface, top r28, grabber)  [AppSafeArea]
├─ Title row: "Who can see this post?" Sora 18/700 · close circle 40 (end)
├─ [private only] note: warningSoft fill, warningText, r16, info icon, inline link "Privacy settings"
├─ Group (background, r18): 4 rows, min 64, padding 10 16, gap 14
│   row = tile 40 r12 (selected primarySoft, else white) + icon 20 · title 15/700 / sub 12 textSecondary · [Edit pill] · radio 24
├─ [New post only] "Use for future posts" / sub · toggle 48x28
└─ Done (New post) / Save (change later): 52 primary pill
```

## Elements
| Element | Text | Size / token | Notes |
|---|---|---|---|
| Public | "Public" / "Anyone on or off Pulse" | `ic_globe` | hidden choice when private: disabled, sub "Off while your account is private" |
| Followers | "Followers" / "{n} people" | `ic_audience` | accepted followers |
| Close friends | "Close friends" / "{n} people" + "Edit" pill | `ic_star` | Edit opens the Stories close-friends list (`/audience/close-friends`); list shared with Stories |
| Only me | "Only me" / "Saved to your profile, hidden from everyone" | `ic_lock` | sub wraps to 2 lines |
| Radio | | 24; on = `primary` + white check; off = 2 px #9AA6A2 (`dashed`) | disabled radio border `divider` |
| Disabled row | | text/icon #9AA6A2 | |
| Toggle | "Use for future posts" | 48 x 28 | saves `profiles.default_post_visibility` |
| Chip (S1) | label of the choice | h 28, r14, 12/600; default: `background` + 1 `border`; narrowed (anything narrower than your default): `primarySoft` fill + 1.5 `primary` border, primary ink | icon per choice |
| Notice (panel 3) | "Sharing with close friends" / "{n} people will see this post" | dark toast, star tile | one-time, first time you post to Close friends or Only me |
| Meta icon (card) | | 12, users / star / lock | only for non-public posts |

## Behavior
- One choice; applied on **Done** (New post) / **Save** (change later). Close X / scrim closes without changes.
- Default on a new post: Public [user], unless "Use for future posts" saved another default, or the account is private (then Followers) [seen].
- Change later: own post "···" → "Change who can see" (new row under Edit caption in S2) → Save calls the shared `SetContentAudienceUseCase` (`set_content_audience`); notice "Visibility updated".
- When the post is not Public: Copy link and Share are hidden in the options sheet [seen]. When Public they show "Coming soon" for now (Q-V3).
- Shorts reuse this picker titled "Who can watch" (later, shorts feature).

## Data (follow-up migration) [seen]
Schema files: `../schema-post-visibility.sql` and `../schema-shared-content-actions.sql` (spec copies of `supabase/migrations/20261018120000_post_visibility.sql` and `20261019120000_shared_content_actions.sql`; validated and applied 2026-10-14).
- `posts.visibility text not null default 'public' check (visibility in ('public','followers','close_friends','only_me'))`; existing posts become public.
- `profiles.default_post_visibility` same check.
- `create_post(..., p_visibility)`; the audience is changed through the shared RPC `set_content_audience(p_kind, p_id, p_audience)` (author only; story takes only followers / close_friends), see `20261019120000_shared_content_actions.sql`.
- RLS: author, or public + `can_view_author`, or followers + accepted follow, or close_friends + row in `close_friends`. `home_feed` filters with the same check (likes, saves, comments, reports follow the post's read access).
- Counts "{n} people": followers count and close-friends count (`audience_summary`, read through the shared `GetAudienceSummaryUseCase`). Default audience and `is_private` come from the shared `GetPrivacyUseCase`; "Use for future posts" saves with `SaveDefaultAudienceUseCase`; enum `ContentAudience` (shared, also used by story).

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| visTitle | Who can see this post? | من يمكنه رؤية هذا المنشور؟ |
| visChangeTitle | Change who can see | تغيير من يمكنه الرؤية |
| visCurrently | Currently: {choice} | الحالي: {choice} |
| visPublic / sub | Public / Anyone on or off Pulse | عام / أي شخص داخل Pulse أو خارجه |
| visPublicOff | Off while your account is private | غير متاح لأن حسابك خاص |
| visFollowers | Followers | المتابعون |
| visCloseFriends | Close friends | الأصدقاء المقربون |
| visOnlyMe / sub | Only me / Saved to your profile, hidden from everyone | أنا فقط / محفوظ في ملفك الشخصي ومخفي عن الجميع |
| visPeople | {n} people | {n} شخص (plural ICU, review) |
| visEdit | Edit | تعديل |
| visFuture / sub | Use for future posts / You can change it in Settings → Privacy | استخدام للمنشورات القادمة / يمكنك تغييره من الإعدادات ← الخصوصية |
| visPrivateNote / link | Your account is private, so only your followers can see your posts. / Privacy settings | حسابك خاص، لذا يرى منشوراتك متابعوك فقط. / إعدادات الخصوصية |
| visKeptNote | Likes and comments from people who lose access are kept but hidden from them. | تبقى الإعجابات والتعليقات من الأشخاص الذين فقدوا الوصول لكنها تُخفى عنهم. |
| visDone / visSave | Done / Save | تم / حفظ |
| visUpdated (notice) | Visibility updated | تم تحديث الظهور |
| visNoticeCF title / body | Sharing with close friends / {n} people will see this post | المشاركة مع الأصدقاء المقربين / سيرى {n} شخص هذا المنشور |
| visNoticeMe title / body | Only you can see this post / It's saved to your profile, hidden from everyone | أنت فقط من يمكنه رؤية هذا المنشور / محفوظ في ملفك الشخصي ومخفي عن الجميع |
| postChangeVisibility (S2 row) | Change who can see | تغيير من يمكنه الرؤية |

## Responsive / a11y
Rows >= 64; radio semantics "selected"/"not selected", disabled row announced as disabled with its sub; RTL: radio and Edit at the end, Settings arrow mirrors. Wide: sheet capped at shared max width.

## Decisions [user]
- Q-V1: "Privacy settings" link (and the Settings → Privacy hint) shows the "Coming soon" notice until a Settings > Privacy screen is specced (code TODO). `/privacy` is the Privacy Policy, not settings.
- Q-V2: Only me gets its own one-time notice (lock tile), copy in Strings.
- Q-V3: the New post button stays "Share post" (S1). Sharing a post by deep link (Copy link / Share in S2) is "Coming soon" with a code TODO until post deep links exist.

## Acceptance checklist
- [ ] Sheet like Post options; 4 rows with tiles, radios, Edit pill; selected tile `primarySoft`.
- [ ] Private account: amber note with link, Public disabled, default Followers.
- [ ] Future-posts toggle saves the default; Done applies.
- [ ] Narrowed chip turns primary with icon; one-time notice for Close friends / Only me.
- [ ] Own post: "Change who can see" row, "Currently: X", Save → "Visibility updated"; meta icon on non-public cards.
- [ ] Copy link / Share hidden for non-public posts.
- [ ] A Followers / Close friends / Only me post is not visible to others outside that group (RLS + feed).
