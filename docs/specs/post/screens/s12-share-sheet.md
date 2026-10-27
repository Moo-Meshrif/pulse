# Share sheet (S12)
Screenshot: `../screenshots/s12-share-board.png` (7 panels + Tokens / Behavior / Data notes). Opened from the send icon on a post card and from "Share" in the options sheet (S2). Shares are shown on the card described in `../02-components.md` P10-P11.
Purpose / route: bottom sheet over any list that shows a `PostCard`. Share the post to your own feed with an optional caption (like Facebook), or add it to your story. Send in chat is specced here (panels 5-7) but **hidden until the Chat tables exist** [user, 2026-10-21].

## What is built now [user, 2026-10-21]
| Part | Now |
|---|---|
| Composer with Tag people, Feeling and Location + Share now (panels 1-2) | built [user, board updated 2026-10-21] |
| "Shared to your feed" notice + View (panel 3), shared card in the feed, unavailable original (panel 4) | built, see `../02-components.md` P10-P11 |
| Add to story | built, see `s13-add-to-story.md` |
| Copy link, WhatsApp, More... | tiles shown, tap = "Coming soon" + `TODO(post-plan T7)` until the user provides the deep link; the share text is decided later [user] |
| Send in chat (panels 5-7) | **hidden** (the "SEND IN CHAT" header, row, search icon and compose bar are not drawn); built with the chat feature |

## Who sees the share icon [user, 2026-10-21; row 2 is an assumption to confirm]
| Post | Icon / Share row | Sheet content |
|---|---|---|
| Public (any author) | shown | composer + divider + external row |
| Followers, **your own** | shown | composer + divider + the same external row as a public post (Add to story, Copy link, WhatsApp, More). The share keeps the post's audience: the audience chip stays Followers and a tap shows "This post is for followers only, so a share of it stays for followers. To change that, change the original post's audience." (`shareAudienceLocked`); a link to the post is checked against the opener's access when the deep link opens (not built yet) [user, 2026-10-27] |
| Followers, someone else's | hidden | - (followers can't re-share it: [user, 2026-10-27]) |
| Close friends, Only me | hidden | - |
The feed card's send icon and S2's Share tile (Home too) follow this table. S2 "Copy link" keeps "Coming soon" (T7). The share count is not shown on the card.

## Layout tree (panel 1, chat hidden)
```
Sheet (same shell as S2: white, top radius 28, grabber, scrim, AppSafeArea)
├─ Header: `ic_share_forward` icon + title "Share" (Sora 18/700) + close X 40 (end)
├─ Composer (background, r18, padding 12)
│    ├─ Row: avatar 40 (you) + name (15/700) over audience chip (h 26: globe + "Public" + chevron-down)
│    ├─ Field "Say something about this..." (15, min height 40, multiline, no border)
│    └─ Row: tools Tag people (`ic_tag_person`) · Feeling (`ic_smile`) · Location (`ic_location`): circles 36, icons 19 `primary`  ·  counter (only while typing, panel 2)  ·  "Share now" (h 38, primary pill; disabled 50% while sending)
├─ Divider
└─ External row (4 tiles, horizontal): Add to story (primarySoft circle 52, primary icon 22) · Copy link · WhatsApp · More...  (circle 52 `background`, icon 22, label 12/600, gap 12)
```
With chat later: between composer and divider a "SEND IN CHAT" label (caps, 12 textSecondary) + search icon at end, then the chat row (horizontal, avatar 56, gap 14, name 12). Panels 5-7 notes below.

## Panels
| # | Panel | Content |
|---|---|---|
| 1 | Share sheet | as tree. Share now is **enabled with an empty caption** (shares right away). The hint "Shares to your feed and profile" is gone in the new board |
| 2 | Write a caption | tapping the field lifts the sheet above the keyboard: the composer sits right above the keyboard (and the chat row + bottom row under it when chat exists). Field grows to 4 lines, then scrolls. Counter replaces the hint: "48 / 2000" (12). Max 2000. Done on the keyboard or a tap outside closes the keyboard |
| 3 | Shared to your feed | sheet closes; dark notice "Shared to your feed" + subtitle by audience + "View" action on the end. Shape and position as the S4 notice |
| 4 | In the feed, original gone | `../02-components.md` P11 |
| 5-7 | Send in chat (hidden for now) | 5: tap people in the row (ring + check), a message field with "Send to N" appears under the row; Share now stays usable, both can be done from one sheet. 6: search icon opens full height search (back arrow, search field 44 r22 `background`, picked people as chips with x, results: people you chat with first, then followers and people you follow; people who can't see the post are dimmed 45% with "Can't see this post"); bar above the keyboard: field 44 r22 "Write a message..." + "Send 2" primary pill 52 with send icon 18. 7: the chat shows a post bubble (author, first media, caption); "Post unavailable" tile when deleted or access was lost |

## Behavior
- **Tools** (board notes: same pickers as New post, 3.16 / 3.11): Tag people opens S6, Feeling opens S8 (Feelings only), Location opens S3. A share has no photo of its own, so S6 hides "Tag in photo" and S7 isn't used; picked values show on the share's headline and meta like on a post (`02-components.md` P2a-P2b), the composer does not preview them [estimated]. Each tool turns `primary` filled while it has a value; tapping again opens the picker to change or remove.
- **Audience chip** opens the S4 visibility picker (same sheet as New post). Default = the account's default audience from `GetPrivacyUseCase` [estimated: same as S1, confirm]. The share's audience can be Public, Followers, Close friends or Only me [user, notes].
- **Share now:** sends caption, tags, feeling and location with the share. The shared post must be Public and visible to you. Sharing a share shares the **original** post (the server resolves it). Button shows its loader; success closes the sheet and shows the notice; Home reloads the top of the feed so the new share is first (`RequestFeedRefreshUseCase`). **View** = scroll Home to the top [estimated].
- Notice subtitle by the share's audience [user]: Public "Everyone can see it now." · Followers "Your followers can see it now." · Close friends "Your close friends can see it now." · Only me "Only you can see it."
- **Failure:** sheet stays open with the text kept, dark notice "Couldn't share. Try again." [estimated]. **Offline:** same notice (no queue). **Original deleted or hidden meanwhile:** notice "This post isn't available" and the sheet closes.
- **Add to story:** closes the sheet and opens story create (`s13-add-to-story.md`).
- Close X, drag down or scrim tap closes. With text in the field, closing asks nothing (a share is cheap to redo) [estimated].
- The author of the original gets a notification of type `share`, grouped per post (row only; UI comes with Activity, like `tag`) [user].

## Data (`../schema-post-share.sql`, not applied)
| Call | Use |
|---|---|
| `rpc('share_to_feed', {p_post, p_caption, p_visibility, p_mood_*, p_location, p_tags})` | checks the original is Public and visible, resolves a share to its original, inserts the share (`posts.shared_post_id`), caption optional. Returns the new post id |
| `home_feed` | returns the embedded original, or null when the viewer can't see it (P10, P11) |
| `share_targets(p_post, q)`, `share_post(p_post, p_users[], p_text)` | chat sending, **not built now** (needs Chat tables); specced in the notes: recent chats + search each with `can_view`, one chat message per user (type post, `post_id`), up to 15 people, the server re-checks `can_view` |
Wire fields on the feed row: `shared_post_id`, `shared_post` (the embedded original or null). Use case: `ShareToFeedUseCase` (post feature); the sheet's own Cubit calls it.

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| shareTitle | Share | مشاركة |
| shareFieldHint | Say something about this... | قل شيئًا عن هذا... |
| shareTagPeople / shareFeeling / shareLocation (semantics) | Tag people / Feeling / Location | وسم الأشخاص / المشاعر / الموقع |
| shareNow | Share now | شارك الآن |
| shareCounter | {count} / 2000 | {count} / 2000 |
| shareAddToStory | Add to story | أضف إلى القصة |
| shareCopyLink / WhatsApp / More | Copy link / WhatsApp / More... | نسخ الرابط / واتساب / المزيد... |
| sharedToFeedTitle | Shared to your feed | تمت المشاركة في صفحتك |
| sharedToFeedPublic | Everyone can see it now. | يمكن للجميع رؤيتها الآن. |
| sharedToFeedFollowers | Your followers can see it now. | يمكن لمتابعيك رؤيتها الآن. |
| sharedToFeedCloseFriends | Your close friends can see it now. | يمكن لأصدقائك المقربين رؤيتها الآن. |
| sharedToFeedOnlyMe | Only you can see it. | أنت فقط من يمكنه رؤيتها. |
| sharedToFeedView | View | عرض |
| shareFailed | Couldn't share. Try again. | تعذّرت المشاركة. حاول مرة أخرى. |
Existing keys reused: `comingSoon`, S4 audience labels.

## Responsive / a11y
Sheet capped at the shared max width on wide screens; `AppSafeArea` with `bottomSpace` = its bottom padding. Tap targets >= 44 (tiles are 52). Labels = visible labels; the chip reads "Audience: Public, button"; the counter is announced politely at 1900+. RTL: chevrons mirror, chip and Share now swap sides, external row order follows reading direction. Text scale 1.5x: tiles wrap labels to 2 lines, the row scrolls horizontally if 4 tiles don't fit.

## Acceptance checklist
- [ ] Panel 1 layout matches with chat hidden; Share now works with an empty caption.
- [ ] Tools row: three 36 circles open S6, S8, S3 and the values reach the share's headline.
- [ ] Panel 2: sheet rides above the keyboard, counter shows `n / 2000`, field stops at 4 lines.
- [ ] Panel 3 notice matches the chosen audience and View brings the new share into view.
- [ ] Followers (own) shows only Add to story; Close friends / Only me and others' Followers posts have no icon.
- [ ] Copy link, WhatsApp, More say "Coming soon" with the T7 marker.
- [ ] Share of a share shows the original under your caption.
- [ ] Failure keeps the caption; EN + AR + RTL; 1.5x text.
