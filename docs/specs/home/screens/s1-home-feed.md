# Home feed (S1)
Screenshot: `../screenshots/s1-home-feed.png` (720 px wide, 1.846x). Tokens: `../01-design-tokens.md` + `../source-tokens.md`.
Purpose / route: `/home`, tab 0 of the control-page shell; the first screen after sign-in / splash.

## Layout tree
```
Scaffold (bg background #F3F4F3)  [AppSafeArea, bottomSpace = nav clearance]
└─ ContentWidth > RefreshIndicator > CustomScrollView (no scrollbar on rail)
   ├─ SliverAppBar floating+snap: HomeHeader (C1)
   ├─ SliverToBoxAdapter: StoryRail (C2, no title)
   ├─ SliverList: PostCard (C5) x N, gap 12, list padding 4 12 0 12
   │    ├─ Author row (C6) / caption (C7) / media (C8) / action bar (C9)
   ├─ Load-more / error / end row (C12)
   └─ bottom padding 104 + viewPadding.bottom
(nav bar = control shell; bottom space from `NavClearance`)
```

## Elements
| Element | Text | Size | Color token | Font style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Logo tile | - | 28, r9 | primary | - | pad-start 16 | logo.svg |
| Wordmark | "pulse" | - | textPrimary | `logo` Sora 24/700 | gap 8 | |
| Search | - | 44 btn, icon 24 | textPrimary | - | end | `ic_search` |
| Bell + dot | - | 44 btn, icon 24; dot 9 | textPrimary / like | - | gap 4 | `ic_bell`; dot when unread > 0 |
| Your story | "Your story" | 64 | primarySoft / primary | caption 12 | gap 6 | dashed 2, `ic_plus` 24 |
| Story item | username, e.g. "nour.adel" (1 line, ellipsis) | 64 + ring 2.5 | primary / border | caption 12 textSecondary | gap 14 | 1 line |
| PostCard (all card rows) | | | | | | **post feature** public widget: see `../../post/02-components.md` (P1-P9) and the S1 screenshot |
| Posting tile | "Posting…" / "Retry" | 64, ring stroke 3 | primary on border / warningInk | caption 12 | | your story tile while `StoryUploading` / `StoryUploadFailed` (C4) |

## States
| State | UI |
|---|---|
| First load | header visible; **skeletonizer** (pub.dev `skeletonizer`) over placeholder rail (Your story + 4 items) and 2-3 placeholder PostCards, shimmer effect; blocks #E6E9E7, highlight #F1F3F2, sweep 1.4 s (mirrors in RTL), 200 ms cross-fade to content, static under reduce motion; no loading text [user] |
| Content | as screenshot |
| Pull to refresh | 64 band under header, PulseLoader 56 wide stroke 2.2; content keeps its place |
| Load more | 72 band at end (above the nav), PulseLoader 44 wide stroke 2; trigger 3 cards before the end |
| Load more error | inline "Couldn't load more · Retry" 13/600 primary |
| Empty (follows nobody / no posts) | header and rail stay on top; the shared `AppEmpty` page is centered on the whole screen (not just under the rail) [user, 2026-10-15]: `ic_inbox` icon, "Your feed is quiet", "Follow people to see their posts here.", primary "Find people" [user, 2026-10-14: the shared AppEmpty look replaces the 80 tile + soft pill] |
| Error first load | header and rail stay on top; `AppEmpty.failed` (or `AppEmpty.offline` for a lost connection) with "Try again" |
| End of feed | "You're all caught up" 13 textSecondary centered, 48 band |
| Story rail empty | only "Your story" |
| Story posting | "Your story" tile shows Posting… progress ring, then Retry on failure, then normal (C4, story S4) |

## Strings (en | ar draft, all `x-review`)
| Key | en | ar |
|---|---|---|
| homeYourStory | Your story | قصتك |
| homeSearch (semantics) | Search | بحث |
| homeActivity (semantics) | Activity | النشاط |
| homeLess | less | أقل |
| homeEmptyTitle | Your feed is quiet | خلاصتك هادئة |
| homeEmptyBody | Follow people to see their posts here. | تابع أشخاصًا لترى منشوراتهم هنا. |
| homeFindPeople | Find people | ابحث عن أشخاص |
| homeTryAgain | Try again | حاول مرة أخرى |
| homeLoadMoreError | Couldn't load more · Retry | تعذّر تحميل المزيد · أعد المحاولة |
| homeCaughtUp | You're all caught up | لقد اطلعت على كل شيء |
Post strings (more/less, time, semantics): `../../post/02-components.md`.

## Behavior and navigation
- Search → `/search`; Bell → `/activity` (both pushed inside the Home tab) [user]. Neither is specced: both open `PlaceholderScreen` routes for now; Comment opens a comments placeholder route too; empty-state "Find people" opens the `/search` placeholder [user, 2026-10-14].
- "Your story" → `AppRoutes.createStory`; story avatar → `AppRoutes.storyOf(authorId)` with `StoryViewerArgs(origin: tap position, person: the item)`; your own item → `storyOf(me)` (routes exist, story feature) [user].
- Rail reloads when `WatchStoryRailChangesUseCase` fires (mute/unmute, delete) and after a story finishes posting.
- Post card behavior (avatar/name → profile, "···" → `PostOptionsFlow` (post S2), comment, share, like/save, double-tap, caption more/less, video) is owned by the post feature; Home handles list effects: hidden row + Undo, removal after report/delete, refresh [user].
- Header floats and snaps back on scroll-up [user].
- Story rail has no visible scrollbar [user].
- Re-tap of Home tab (pop to root, scroll to top + refresh) is handled by the control page.

## Data mapping
| UI | Call | Returns |
|---|---|---|
| Feed page (via post feature `GetHomeFeedUseCase`, entity `PostEntity`) | `rpc('home_feed', {p_limit: 20, p_before_created, p_before_id})` | posts with author, counts, `liked_by_me`, `saved_by_me`, `media[]` |
| Like | `rpc('set_post_like', {p_post, p_liked})` | new `like_count` |
| Save | `rpc('set_post_save', {p_post, p_saved})` | bool |
| Story rail (via story feature `GetStoryRailUseCase`, entity `StoryRailItemEntity`) | `rpc('story_rail')` | people with active stories: `isMe` (only listed when you have an active story), `storyCount`, `allSeen`; me first, then unseen, then latest. Labels = `username` [user]. "Your story" tile always first; own story (if any) shows as a normal item after it [user] |
| Media URLs | `SignPostMediaUrlsUseCase(paths)` (post feature; it calls `createSignedUrls(paths, 3600)`) | `Map<path, url>`; cache key = path |
| Story / post upload state | `GetPublishStatusUseCase(kind)` (shared) then `ContentPublishStatus` on the `EventBus` | Idle, Publishing(progress), Failed, Done, per kind (story on the rail, post in the banner) |
| Rail reload | `WatchStoryRailChangesUseCase` (story) | `Stream<void>` |
| Option: Not interested / Undo | `HidePostUseCase(postId, hidden:)` | void |
| Option: Mute / Undo | shared `SetMuteUseCase(userId, muted, MuteScope.posts)` | void |
| Option: Unfollow / Undo | follow `ToggleFollowUseCase` | void |
| Option: Report | shared `ReportContentUseCase(ContentKind.post, id, reason, note)` (server also hides it) | void |
| Option: Comments on/off, Delete | `SetCommentsEnabledUseCase`, `DeletePostUseCase` | void |
| Option: Change audience | `PostVisibilitySheet.change` saves via shared `SetContentAudienceUseCase`; result -> `onAudienceChanged` | `ContentAudience` |
| Bell dot | `GetUnreadActivityCountUseCase` (activity feature) = unread notifications + waiting follow requests, from `rpc('activity_unread_count')` | total > 0 |
| Empty CTA | `GetSuggestedProfilesUseCase` | suggestions |
Nullability: city optional; caption optional (caption-only and media-only variants); media[] may be empty. Feature trades with other features only through use cases.

## Responsive / a11y
- Wide screens: `ContentWidth` centers the feed at the shared max width (as auth) [user].
- Text scale up to 1.5 wraps captions; name and story labels stay 1 line ellipsis.
- Tap targets >= 44 x 44. Semantics labels on every icon button (strings above).
- RTL: header order, action bar order (save at end = left), story rail start, dot anchor (`end 10`) all mirror; media content does not. Icons that imply direction mirror per `rtl.md`.
- Bottom clearance 104 + viewPadding.bottom so the last card clears the nav.

## Acceptance checklist
- [ ] Header: tile 28 + "pulse", search and bell at end, red dot on bell.
- [ ] No title; the rail: dashed "Your story" first, ringed avatars, labels 12 grey, no scrollbar.
- [ ] Cards white r22, gap 12 on #F3F4F3, no shadow.
- [ ] Author row: ringed 40 avatar, bold name, grey "city · time", "···" at end.
- [ ] Media r16 full inner width, ~1.7:1 for the mock.
- [ ] Action bar: red filled heart 7.5K, comment 425, share, bookmark at end.
- [ ] Last card scrolls fully above the nav.
- [ ] AR: everything mirrors, Arabic font, Latin names unchanged.
- [ ] Caption more/less, double-tap like, pull-to-refresh, load-more, empty and error states work.
