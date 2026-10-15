# Post feature: shared components (public widgets)

Specced here, **built in `lib/features/post/presentation/` and documented as the post feature's public presentation exports** [user, supersedes Q12, 2026-10-14]: `PostCard`, `PostOptionsFlow`, `PostVisibilitySheet`, `HiddenPostRow`, `PostVideoScope`, `PostActionsCubit` (+ `PostActionsState`, `PostRow`), and the plain types `PostCardData`, `PostCardCallbacks`, `PostCardMedia`, `PostOptionsData`, `PostOptionsActions`, and the `ContentAudienceDisplay` extension (audience icon / label). Other features (Home now; profile, saved, search later) may import exactly these, never post's datasources, models or cubits. They are pure UI: they take plain display props and callbacks. A list screen maps `PostEntity` -> `PostCardData` (media links signed through `SignPostMediaUrlsUseCase`, `visibility` -> `audienceIcon`) and supplies the callbacks. Exception to be recorded in `.claude/conventions/architecture.md` next to the entity exception.
Visual source: `../home/screenshots/s1-home-feed.png` (cards) and `screenshots/s2-post-options.png`. Reuse: `AvatarInitials`, `AppSvgIcon`, `ConfirmationDialog`, `PrimaryButton`.

| ID | Component | Anatomy / notes |
|---|---|---|
| P1 | PostCard | surface card r22, padding 12 12 6 12, no shadow: author row, caption, media, action bar. Input: `PostCardData` + callbacks |
| P2 | PostAuthorRow | Avatar 40 (ring: 2 `surface` gap + 2 `storyRing`) + name (`name` 15/700, 1 line ellipsis) / meta `{city} · {relative time}` (caption 12 textSecondary; city omitted when empty) + "···" 44 button at end (`ic_more_horizontal` 22 textSecondary; `primarySoft` while the sheet is open). Avatar = photo or initials 15/700 white on stable-hash color. Tap avatar/name -> profile |
| P2a | PostHeadline (extends P2, board `screenshots/s10-card-details-board.png`) | Replaces the plain name: text 14 / h 1.35, max 2 lines then ellipsis. Names 700 `textPrimary`; connector words ("is feeling", "is {emoji} watching", "with", "and") 400 `textSecondary`. Pieces in order: name · mood · "with {name}" / "with {a} and {b}" / "with {a} and {n} others" (names tappable -> profile; "N others" -> S10). Mood: EN feeling = "is feeling {emoji}{word}" (emoji + word, no gap, 400 textSecondary after "is feeling"); EN activity (deferred) = "is {emoji} {verb} {text}". **AR uses nouns, no gendered verb [user]**: feeling = "{emoji} {noun}" (no "is feeling" connector), e.g. "نور عادل · 😊 سعادة · مع عمر خالد و٢ آخرين"; activity (deferred) = "{emoji} {verbal noun} {text}", e.g. "📺 مشاهدة الديربي". "مع" and "و" are gender-neutral; the count follows the locale numerals. The avatar aligns to the top of the headline. Owner's own post reads "You" |
| P2b | PostMeta (extends P2) | 12 `textSecondary`, gap 5, separators "·": location (pin 12 + text 600 `primary`, tappable = opens the place; max 1 line) · relative time · audience icon 12 (globe Public, users Followers, star Close friends, lock Only me; the lock shows on Only me only as before). Combinations (board panel 7): nothing extra / location only / feeling / one tag / two tags / everything (2 headline lines + location line). Meta without location: time · audience icon |
| P2c | TagBadge + TagLabels (extends P4) | Badge: 32 circle, #161A19 @ 55%, `ic_user` 16 white, bottom-start of the media (shown when anyone is tagged, on the photos that carry tags; badge hides on videos). Tap the badge or the media: labels appear at each person's x/y of THAT photo (per media index); label = dark pill h 30 r10 #161A19 @ 82%, 13/700 white username, 7 px pointer; hides after 3 s or on tapping the media again. Tap a label -> profile. Double-tap still likes. Long-press the badge or tap "N others" -> S10. Your own label = white card with "Remove tag" (`s11-remove-tag.md`) |
| P3 | ExpandableCaption | bodySm 14/400 h1.45; collapses at 3 lines with "more" (14/600 textSecondary); "more" expands in place; "less" collapses and scrolls back to where the post's "more" was [user]. Margin 10 2 10 2 (caption only, no media: 10 2 4 2) |
| P4 | PostMedia | radius 16, width = card inner width (342 at 390), aspect from item 0 clamped 4:5 .. 1.91:1; single image/video or PageView + dots (6 x 6, gap 4, active `primary`, inactive `border`) + counter chip "1/4" (12/600 white on `mediaChip`, r10, padding 4 8, top-end); **video via `video_flux`**: autoplay muted at >= 60% visible, one at a time, mute toggle 32 circle bottom-end (`ic_volume` / `ic_volume_off`), duration chip bottom-start; blurhash placeholder; error = blurhash stays + tap to retry; double-tap likes (never unlikes) + big heart 80 white @90%, pop 0.6 -> 1.1 -> 1 (~200 ms) then fade 600 ms [user] |
| P5 | PostActionBar | **comments off** (`commentsEnabled = false`): the Comment button becomes `ic_comment_off` 24 at 45% opacity, no count, still a 44 tap target; tap shows the dark notice "Comments are off" / "{name} turned off comments for this post." instead of opening comments; a line under the actions "Comments are turned off" (`ic_comment_off` 14 + 12 `textSecondary`, padding 2 4 6). Normal: padding-top 4, gap 4, height 44: Like (heart + count), Comment (`ic_comment` + count), Share (`ic_share` 23), spacer, Save (`ic_bookmark` 22 / `ic_bookmark_filled` saved, `textPrimary`). Like/comment: min 44 x 44, padding 0 8, r22, icon 24 stroke 1.8, count 13/600, gap 6. Liked = `ic_heart_filled` `like`, pop 1 -> 1.2 -> 1 in 180 ms. Counts 1.2K, 7.5K, 2.1M (one decimal under 10, none above; 0 shows no number) |
| P6 | RelativeTime formatter | `now`, `5m`, `2h`, `1d`, `3w`, then `12 Mar` (AR localized) |
| P7 | PostOptionsSheet | pure-UI sheet in core driven by `PostOptionsActions` callbacks; the S2 sheet and flows: `screens/s2-post-options.md` |
| P8 | HiddenPostRow | collapsed card after Not interested: `screens/s2-post-options.md` panel 5 |
| P9 | PostActionsCubit | Lives in `features/post/presentation/cubit` (moved from Home [user, 2026-10-14]: the post detail page will use it too) and is a public export. NOT a widget. The data work (like/save/hide/report/comments toggle/delete) is **post's `PostActionsDatasource` + use cases** for like/save/hide/comments/delete, and the **shared** `ReportContentUseCase`, `SetContentAudienceUseCase`, `SetMuteUseCase` (`lib/shared/content`, Q13 superseded 2026-10-14); each list screen's feature (home now; profile, saved later) has its own thin Cubit that calls those use cases (optimistic updates with rollback, mute/unfollow via the follow use cases). The options sheet P7 talks to the Cubit only through callbacks (`PostOptionsActions`: save, copyLink, share, notInterested, unfollow, mute, report(reason, note), editCaption, toggleComments, delete) |

## States
| Component | States |
|---|---|
| Like / Save | default, active, optimistic pending (reconcile with returned count/bool; roll back on `Failure`) |
| Caption | collapsed, expanded, short (no control) |
| Media | loading (blurhash), loaded, video playing/paused, error (retry on tap) |
| Card | normal, hidden row (Undo 5 s), removed (reported / deleted), comments off |
| Tags | no tags, badge hidden labels, labels shown (3 s), own label (remove) |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| postMore / postLess | more / less | المزيد / أقل |
| time | now, 5m, 2h, 1d, 3w, 12 Mar | الآن، 5د، 2س، 1ي، 3أ، 12 مارس (ICU, review) |
| headline | is feeling, with, and, "{n} others", You | EN only for "is feeling"; AR: no connector (emoji + noun), مع، و، "{n} آخرين"، أنت (`x-review`; no gendered verbs [user]) |
| commentsOff (notice / line / post page bar) | Comments are off + {name} turned off comments for this post. / Comments are turned off / Comments on this post are turned off | التعليقات متوقفة + أوقف {name} التعليقات على هذا المنشور. / التعليقات متوقفة / التعليقات على هذا المنشور متوقفة |
| semantics | Like / Unlike,  Comment, Share, Save / Unsave, Post options, Mute / Unmute | إعجاب / إلغاء الإعجاب، تعليق، مشاركة، حفظ / إلغاء الحفظ، خيارات المنشور، كتم / إلغاء الكتم |
Counts use compact notation; numerals per `rtl.md`. Names, cities and captions come from data.

## Acceptance checklist
- [ ] Card white r22 on #F3F4F3, no shadow, author row with ringed 40 avatar, bold name, grey meta, "···" at end.
- [ ] Media r16 full inner width; red filled heart when liked; bookmark at end.
- [ ] Headline: bold names, grey connectors, mood with emoji, max 2 lines then ellipsis; meta line with location (green), time, audience icon.
- [ ] Badge on tagged media; tapping shows labels at their spots for 3 s; N others opens the Tagged people sheet.
- [ ] Comments off: dimmed comment-off icon, no count, notice on tap, line under the actions.
- [ ] Caption more/less behavior; double-tap like; video autoplay rules.

## Post page when comments are off (board 2 panel 5)
Old comments stay visible, read-only (no reply, no like). The composer is replaced by a fixed bottom bar: `ic_comment_off` 14 + "Comments on this post are turned off" 14/600 `textSecondary`, `surface`, top border `divider`, padding 14 16 34 (inside `AppSafeArea`). The post page itself is a later spec; the rule is recorded here so the page and the comment insert policy (blocked by RLS when off) match.

## Performance rules for feed cards

Cards repeat once per post, so they must stay cheap in a long feed:

- A value that changes on swipe or scroll (the media page index) lives in a `ValueNotifier` read by the counter, the dots and the items; the card's `State` never calls `setState` for it.
- P3 measures whether the caption overflows 3 lines once per text, width and text scale (cached), not on every build.
- The video scope (one video plays at a time) does not notify its dependents; each video item listens to the coordinator itself, so a pick or mute change touches each built video once.
