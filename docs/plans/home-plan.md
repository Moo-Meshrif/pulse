# Plan: home
Source specs: docs/specs/home/ (`00-overview.md`, `01-design-tokens.md`, `02-components.md`, `screens/s1-home-feed.md`, `assets.md`, `open-questions.md`, `source-tokens.md`), docs/specs/_theme/; post widgets from docs/specs/post/02-components.md and `screens/s2-post-options.md`; rail posting state from docs/specs/story/screens/s4-posting-rail.md
Status: approved
Mode: one-by-one
Tests: cubit + widget tests in each phase (mirror `lib/` under `test/`, helpers in `test/helpers/pump_app.dart`; widget tests EN + AR/RTL + 1.5x text), as in the post plan

## Progress (updated 2026-10-15): only device checks remain
| Phase | State |
|---|---|
| 0 Prerequisites, 1 Tokens and strings, 2 Feed state and post actions | done |
| 3 Header and feed list, 4 Story rail | done |
| 5 Loading, empty, error and status states, 6 Integration | done |
| 7 Polish | in progress: automated checks done; device checks (B3), loader comparison (B2) and the screenshot comparison are the user's |

## Summary
- **Screen:** S1 Home feed (`/home`, tab 0 of the control shell): header, Stories rail with the Your story tile (incl. Posting… / Retry), post feed, and its states (skeleton first load, pull to refresh, load more, load-more error, empty, first-load error, end of feed, rail empty).
- **Home owns:** C1 HomeHeader, C2 StoryRail, C3 StoryItem, C4 YourStoryItem, C12 FeedStatusRow, C14 feed skeleton, plus the feed state. C15 `PostActionsCubit` lives in the post feature (moved 2026-10-14, post detail will use it); Home provides it. No data layer of its own (Q14).
- **Home composes:** `PostCard`, `PostOptionsFlow`, `PostVisibilitySheet`, `HiddenPostRow` and their plain types from the post feature's public presentation exports (`.claude/conventions/architecture.md` exception, 2026-10-14).
- **Goal:** a signed-in person sees the feed of people they follow, the story rail, and can like, save, double-tap, use every post option and open stories, inside the control shell.
- **Out of scope** (specs): `/search`, `/activity`, profile, comments page, suggestions screen (Q6, Q20, placeholders only); post sharing by link and system share (post T7); Edit caption page (post T6); New post (post feature); nav bar, tab switching, Create sheet (control feature); dark mode.

## Reuse
- Theme: `context.appColors` (`background`, `surface`, `primary`, `primarySoft`, `textPrimary`, `textSecondary`, `border`, `like`, `storyRing`, `warningInk`, `mediaChip`), `context.text` (`logo`, `caption`, `name`, `bodySm`, `label`, `stat`), `AppSpacing` / `AppRadius` / `AppScale` (unscaled literals need `// unscaled: <reason>`), existing `PostCardDimens`, `PostOptionsDimens`, `NavDimens`, `StoryDimens` (check before adding a home dimension).
- Widgets: `AppSafeArea`, `ContentWidth`, `AvatarInitials`, `LogoTile` / `LogoLockup`, `AppSvgIcon`, `AppText`, `AppEmpty`, `PillButton`, `PrimaryButton`, `AppImage` / `CachedPicture`, `PulseLineLoader` (`color`, `width`; Lottie), `NavClearance` (bottom space inside the shell), notices `context.showSnackBar` / `showNotice` / `showFailure`.
- Utils: `compact_count` (counts), `post_time` (relative time), `avatar_initials`.
- Post (public): `GetHomeFeedUseCase` (page 20, `FeedPageEntity.nextCursor`), `SignPostMediaUrlsUseCase`, `SetPostLikeUseCase`, `SetPostSaveUseCase`, `HidePostUseCase`, `SetCommentsEnabledUseCase`, `DeletePostUseCase`, entities `PostEntity` / `PostMediaEntity`; widgets and types listed in Summary.
- Shared content: `ReportContentUseCase` (`ContentKind.post`), `SetMuteUseCase` (`MuteScope.posts`), `ContentAudience` (`PostVisibilitySheet` saves through `SetContentAudienceUseCase` itself).
- Follow: `ToggleFollowUseCase` (Unfollow / Undo). Activity: `GetUnreadActivityCountUseCase` (bell dot; new activity feature, migration `20261014120000_notifications.sql`).
- Story (public): `GetStoryRailUseCase`, `WatchStoryRailChangesUseCase`, `WatchStoryUploadUseCase` (`StoryUploadStatus`), `RetryStoryUploadUseCase`, `StoryRailItemEntity`, `StoryViewerArgs`; routes `AppRoutes.storyOf(id)`, `AppRoutes.createStory`; string `storyPosting` exists.
- Navigation: `AppRoutes.profileOf(id)` (placeholder, story-plan T3), `AppNavigator`, `AppRouter.onGenerateRoute`, shell `ControlScreen._root` (Home tab, control T1), `ControlView._onTab` (re-tap, control T6).
- Icons registered: `search`, `bell`, `plus`, `inbox`, `cloudAlert`, `wifiOff`, `logo`, `bookmarkFilled` and the post card set.
- Packages present: `video_flux`, `blurhash_ffi`, `lottie`. Missing: `skeletonizer`.

## Blockers
| Id | Item | Blocks phase | Needed from | Status |
|---|---|---|---|---|
| B1 | Arabic copy drafts `x-review` (Q8) | none | user review | open, no code marker |
| B2 (default applied in Phase 5: width only; compare on device in Phase 7) | Q16: `PulseLineLoader` has no stroke parameter (stroke comes from the Lottie and scales with width). Default: use `width` only (56 refresh, 44 load more); compare against `screenshots/page-loading.png` and add a stroke parameter only if it visibly differs | 5 | user check on device | default proposed |
| B3 | Device checks: video autoplay in the feed (>= 60% visible, one at a time, muted), slow network load more, real story upload ring | 7 | user | open |

## Code TODOs
| Id | What is pending | Code it sits in | Phase |
|---|---|---|---|
| H1 | `/search` not specced (Q6): placeholder route | the search route + header search tap | 0 |
| H2 | `/activity` not specced (Q6): placeholder route | the activity route + bell tap | 0 |
| H3 | Comments page not specced (Q6): placeholder route | the comments route + card comment callback | 0 |
| H4 | "Find people" opens the `/search` placeholder until a suggestions/search spec exists (Q20) | the empty state button | 5 |
| H5 | ~~Bell dot must count unread notifications and follow requests~~ done 2026-10-14: `GetUnreadActivityCountUseCase` over `activity_unread_count()`; notifications migration **applied 2026-10-15** to project `pulse` (recorded as `20261014213146_notifications`) | the bell dot source | 3 |
| H6 | Share on the card: spec says system share sheet; post sharing by link is coming soon (post T7, `share_plus` not added) | the card's share callback | 3 |
| post T6 | Edit caption: home passes `onEditCaption: null` (coming soon), existing marker in `PostOptionsFlow` | no new marker | 3 |
| story T3 | Profile taps open the profile placeholder (existing marker in the router) | no new marker | 3 |
| control T1 | Home tab placeholder: resolved by mounting Home | remove marker | 6 |
| control T6 | Re-tap Home on its root also refreshes the feed | remove marker | 6 |
| post T5 | Feed refresh after "Post shared" | remove marker | 6 |
| B1 | Arabic review | no code marker | - |

## Phases

### Phase 0: Prerequisites
**Status:** [x] done 2026-10-14: `skeletonizer ^3.0.0` added; `/search`, `/activity`, `/post/:postId/comments` placeholder routes with H1-H3 markers; router test extended; icons verified registered. Skeletonizer README is read in Phase 5 before use.
**Goal:** package and routes the screen depends on.
**Depends on:** none.
**Spec refs:** `assets.md`; `screens/s1-home-feed.md` > Behavior; `open-questions.md` Q6, Q20.
**Tasks:**
- [x] Add `skeletonizer` to pubspec (`fvm flutter pub get`).
- [x] Add `/search`, `/activity` and a comments route (takes the post id) to `AppRoutes` + `AppRouter`, each opening `PlaceholderScreen`, with markers `TODO(home-plan H1)`, `H2`, `H3`.
- [x] Confirm every icon in `assets.md` is registered in `app_assets.dart` (all seen registered; add any missing).
**Out of scope:** any home UI.
**Done when:** app compiles, `fvm flutter analyze` clean, the three routes open the placeholder.
**Verify:** router test for the three routes.

### Phase 1: Tokens and strings
**Status:** [x] done 2026-10-14: `HomeDimens` (header, bell dot, list, end band, load-more lead, skeleton counts/durations), `railTitle` text style (Noto Sans 17/600, EN + AR), `skeletonBase` / `skeletonHighlight` colors, strings `homeSearch`, `homeActivity`, `homeEmptyTitle`, `homeEmptyBody`, `homeFindPeople`, `homeLoadMoreError`, `homeCaughtUp` (EN + AR `x-review`). Reused instead of new: `storyRailTitle` ("Stories"), `storyYourStory`, `postLess`, `tryAgain`, `retry`, `bodyXs` / `meta` for the footer text, `StoryDimens` rail values, `LoadingDimens` bands. Full suite green (1506).
**Goal:** home dimensions, the two new text styles, skeleton colors and strings.
**Depends on:** 0.
**Spec refs:** `01-design-tokens.md` (Typography, Dimensions, Loading); `screens/s1-home-feed.md` > Strings; `../_theme/typography.md`, `colors.md`.
**Tasks:**
- [x] Home dimensions (header padding 20 16 8 16, logo tile 28 r9, action button 44 / icon 24 / gap 4, bell dot 9 + border 2 at top 9 end 10, section title margin 4 16 10 16, story row padding 4 16 12 16, gap 14, avatar 64 / ring 2.5 / inner 3 / label gap 6, list padding 4 12 0 12, card gap 12, refresh band 64, load-more band 72, end band 48); reuse `PostCardDimens` / `StoryDimens` values instead of duplicating.
- [x] Text styles: section title Noto Sans 17/600 (+ Arabic set); footer 13/400 textSecondary and Retry 13/600 primary if no existing style matches.
- [x] Skeleton tokens #E6E9E7 (block) / #F1F3F2 (highlight) in the colors extension.
- [x] Strings `homeStories`, `homeYourStory`, `homeSearch`, `homeActivity`, `homeLess` (only if post has none), `homeEmptyTitle`, `homeEmptyBody`, `homeFindPeople`, `homeTryAgain`, `homeLoadMoreError`, `homeCaughtUp` EN + AR (`x-review`); "Retry" label for the failed story tile (reuse `retry`).
**Out of scope:** widgets.
**Done when:** analyze clean, unscaled-literal test passes, l10n generated.
**Verify:** existing token tests.

### Phase 2: Feed state and post actions
**Status:** [x] done 2026-10-14: `FeedCubit` (first load, refresh, load more with a cursor, signing media in one request) and `PostActionsCubit` (now in `features/post/presentation/cubit`; optimistic like / save with rollback; the ten option actions; what was done is kept by post id on top of the feed, so the feed list is not rewritten; `FeedState.generation` tells the screen to `reset()` the actions when the posts are replaced) in `features/home/presentation/cubit`; `postCardData` / `postOptionsData` mappers; new profile use case `GetCurrentUserIdUseCase` (Home needs it for `isMine`); `ContentAudienceDisplay` added to the post exports (architecture.md + post spec). Cubit, mapper and use-case tests pass; analyze clean. A file whose link cannot be signed is left out of its post.
**Goal:** the feed list state and the per-post actions, no UI yet.
**Depends on:** 1.
**Spec refs:** `screens/s1-home-feed.md` > States, Data mapping; `02-components.md` C5, C15; `../post/02-components.md` P9 and States; `../post/screens/s2-post-options.md` (Backend, results).
**Tasks:**
- [x] Feed state (cubit): first load, refresh (content keeps its place), load more by cursor (trigger 3 cards before the end), load-more error + retry, end of feed (`nextCursor == null`), empty, first-load error (offline vs other failure for the icon).
- [x] Mapping `PostEntity` -> `PostCardData`: author name, avatar, city (`location`), created-at, caption, media with links signed through `SignPostMediaUrlsUseCase` (cache key = path), counts, liked/saved, `audienceIcon` from `visibility` (null for public).
- [x] `PostActionsCubit` (C15): optimistic like / save / double-tap like with reconcile + rollback on `Failure`; builds `PostOptionsActions`: save, not interested (hidden row) + undo, unfollow + undo (`ToggleFollowUseCase`), mute + undo (`SetMuteUseCase`, posts), report (`ReportContentUseCase`; card removed), toggle comments, delete (card removed), `onAudienceChanged` (card icon updates), `onEditCaption: null`.
- [x] Tests: blocTest for every state above, optimistic rollback, hide/undo, removal after report/delete.
**Out of scope:** widgets, rail.
**Done when:** all cubit tests pass.
**Verify:** `fvm flutter test test/features/home`.

### Phase 3: Header and feed list
**Status:** [x] done 2026-10-14: `HomeScreen` (providers, listeners: reset actions when posts are replaced, refresh and action failures), `HomeView` (floating+snap header, `RefreshIndicator`, `PostVideoScope`, post list, nav clearance), `HomeHeader` (`LogoTile.header` added in core), `BellDotCubit` (H5 marker), `FeedPostItem` (card / hidden row / removed, wiring to `PostActionsCubit`, options flow, comments and profile routes, Share = coming soon with H6 marker). Next page is requested when the card 3 from the end is built. Only the ready state draws content for now; skeleton, failed, empty and the status rows are Phase 5. Not mounted in the shell yet (Phase 6). 13 screen tests (EN, AR/RTL, 1.5x on 320 dp); analyze clean.
**Goal:** the screen with header, real post cards and their behavior in content state.
**Depends on:** 2.
**Spec refs:** `screens/s1-home-feed.md` > Layout tree, Elements, Behavior, Responsive / a11y, Acceptance; `02-components.md` C1, C5; `01-design-tokens.md`; screenshot `screenshots/s1-home-feed.png`.
**Tasks:**
- [x] Screen provides the cubits; view = `ContentWidth` > `RefreshIndicator` > `CustomScrollView`; `SliverAppBar` floating + snap with C1; feed `SliverList` of `PostCard`s (gap 12, padding 4 12 0 12); bottom padding = `NavClearance.of(context)`; `AppSafeArea` per CLAUDE.md.
- [x] C1: logo tile 28 + "pulse", search and bell 44 buttons at end with semantics labels; bell dot when the follow-request count > 0 (`TODO(home-plan H5)`).
- [x] `PostCardCallbacks`: profile -> `profileOf(authorId)`; options -> `PostOptionsFlow.show` with `PostOptionsData` + actions; like/double-tap/save -> cubit; comment -> comments placeholder (H3); share -> "Coming soon" (`TODO(home-plan H6)`).
- [x] Hidden posts render `HiddenPostRow` with Undo; reported/deleted posts leave the list.
- [x] Search -> `/search`, bell -> `/activity` inside the Home tab (H1, H2 markers already on the routes).
- [x] Tests: widget EN + AR/RTL + 1.5x: header order mirrors, card taps call the cubit, options flow wiring, hidden row.
**Out of scope:** rail (Phase 4), skeleton / empty / error / status rows (Phase 5).
**Done when:** acceptance items header, cards, author row, media, action bar, AR mirroring, double-tap, more/less pass.
**Verify:** compare with `screenshots/s1-home-feed.png` in a standalone pump; widget tests.

### Phase 4: Story rail
**Status:** [x] done 2026-10-14: `StoryRailCubit` (loads the rail, reloads on rail changes and when a story finishes posting, one reload queued if a change arrives mid-load, upload status), `StoryRail` ("Stories" title + sideways row, no scrollbar), `YourStoryItem` (dashed + plus; Posting… progress ring; warning ring + Retry), `StoryItem` (unseen / seen ring, username label); taps open `/create/story` and `/story/:id` on the root Navigator with `StoryViewerArgs(origin, person)`; the failed post shows a notice with Retry; pull to refresh also reloads the rail. While posting, the ring holds your photo only once you have an own item on the rail, else an empty soft circle (the posted photo is not available to Home). Rail widgets are always shown for now; their skeleton is Phase 5. 21 new tests (cubit, widgets EN/AR/1.5x, screen); analyze clean.
**Goal:** Stories title + rail with Your story tile, upload states and story navigation.
**Depends on:** 3.
**Spec refs:** `02-components.md` C2, C3, C4; `screens/s1-home-feed.md` Elements (Your story, Story item, Posting tile), States (rail empty, story posting), Behavior, Data mapping (story rail, upload state, rail reload); `../story/screens/s4-posting-rail.md`; `../story/00-overview.md` navigation map.
**Tasks:**
- [x] Rail state (cubit): load via `GetStoryRailUseCase`; reload on `WatchStoryRailChangesUseCase` and on `StoryUploadDone`; tile state from `WatchStoryUploadUseCase`; retry via `RetryStoryUploadUseCase`.
- [x] C2: "Stories" title (17/600, margin 4 16 10 16) + horizontal list without a scrollbar; dashed Your story tile always first, then items (your own `isMe` item right after it).
- [x] C3: 64 avatar, ring `primary` 2.5 unseen / `border` seen (`allSeen`), inner padding 3, 1-line username label 12 textSecondary, width 64.
- [x] C4: dashed 2 `primary` on `primarySoft` + plus 24; Uploading = progress ring stroke 3 `primary` on `border`, label `storyPosting`; Failed = `warningInk` ring, label Retry, tap retries + error notice with Retry; Done = normal.
- [x] Taps: tile -> `AppRoutes.createStory`; item -> `AppRoutes.storyOf(authorId)` with `StoryViewerArgs(origin: tap position, person: item)`; own item -> `storyOf(me)`.
- [x] Tests: rail states (empty, items, seen/unseen), upload stream (uploading/failed/retry/done reload), RTL start, navigation args.
**Out of scope:** story viewer and camera (built).
**Done when:** acceptance "Stories title, then rail…" passes; story S4 checklist passes on the Home rail.
**Verify:** widget tests; app run opens the viewer from the rail.

### Phase 5: Loading, empty, error and status states
**Status:** [x] done 2026-10-14: skeleton (`FeedSkeleton`, `RailSkeleton`, `PostCardSkeleton`: Skeletonizer bones, shimmer 1.4 s mirrored in RTL, still under reduce motion, 200 ms cross-fade to content, README of `skeletonizer` 3.0.0 read); pull to refresh (`RefreshIndicator.noSpinner` + the shared `AppInlineLoading.refresh()` band under the header); `FeedStatusRow` (shared `AppInlineLoading.loadMore()`, "Couldn't load more · Retry", "You're all caught up"); empty and failed pages with the shared `AppEmpty` (user chose it over the spec's 80 tile; `.offline` for a lost connection); "Find people" opens Search (H4 marker). B2: the shared loader bands take only a width, no stroke parameter was added. 12 new screen tests; analyze clean.
**Goal:** every non-content state of S1.
**Depends on:** 4; B2 default.
**Spec refs:** `screens/s1-home-feed.md` > States; `02-components.md` C11, C12, C14; `01-design-tokens.md` > Loading; `screenshots/page-loading.png`.
**Tasks:**
- [x] C14: `Skeletonizer` shimmer over placeholder rail (Your story + 4) and 2-3 placeholder cards; header real; blocks #E6E9E7, highlight #F1F3F2, sweep 1.4 s (mirrors in RTL), 200 ms cross-fade to content, static under reduce motion; no loading text.
- [x] Pull to refresh: 64 band under the header with `PulseLineLoader` 56 `primary`; content keeps its place (B2 default: width only).
- [x] C12: load-more band 72 with `PulseLineLoader` 44; error row "Couldn't load more · Retry"; end "You're all caught up" 48 band.
- [x] Empty: `AppEmpty` style, 80 `primarySoft` tile with `ic_inbox`, title, body, soft pill "Find people" -> `/search` placeholder (`TODO(home-plan H4)`).
- [x] First-load error: same layout with `ic_cloud_alert` or `ic_wifi_off` (offline), "Try again" primary button.
- [x] Tests: each state EN + AR, reduce motion static skeleton.
**Out of scope:** shell wiring.
**Done when:** acceptance "pull-to-refresh, load-more, empty and error states work".
**Verify:** widget tests; compare loaders with the board.

### Phase 6: Integration
**Status:** [x] done 2026-10-14: Home is the Home tab root of the shell (`ControlScreen`; control T1 marker removed). A refresh signal (`FeedRefreshRepository` in post, public `RequestFeedRefreshUseCase` / `WatchFeedRefreshRequestsUseCase`) is requested by `CreatePostUseCase` after a post is shared (post T5 marker removed) and by `ControlCubit.refreshHome()` when Home is tapped at its root after scrolling to top (control T6 marker removed); Home's feed, story rail and bell cubits listen and reload. DI regenerated; the real-wiring test setup now gives Home a one-post feed (the empty page floats forever and would never settle). Boot tests: shell lands on Home with feed and rail, re-tap reloads the feed, a shared post reloads it. `grep TODO(home-plan`: H1, H2, H3, H4, H6 remain (H5 done).
**Goal:** Home lives in the shell and reacts to the rest of the app.
**Depends on:** 5.
**Spec refs:** `00-overview.md` (Scope, Navigation map); `screens/s1-home-feed.md` > Behavior; `../control/` specs (re-tap); `docs/plans/control-page-plan.md` T1, T6; `docs/plans/post-plan.md` T5.
**Tasks:**
- [x] Mount the Home screen as the Home tab root in the control shell; remove `TODO(control-page-plan T1)` and tick T1 in the control plan.
- [x] Re-tap of Home on its root: scroll to top + refresh; remove `TODO(control-page-plan T6)` and tick it.
- [x] After "Post shared" in New post, the feed refreshes (through a use case or app-level signal the builder picks per conventions); remove `TODO(post-plan T5)` and tick it.
- [x] DI regenerated (`build_runner`), boot test: signed-in start lands on Home with rail and feed (doubles).
**Out of scope:** new screens.
**Done when:** boot test passes; bottom card scrolls fully above the nav; tab re-tap refreshes.
**Verify:** `fvm flutter test`; run the app with live data.

### Phase 7: Polish
**Status:** [~] 2026-10-15: everything that can be checked without a device is done and passing: wide window (1200 dp) keeps the cards at the content width, centered; 320 dp at 2x text in EN and AR, scrolled to the end, no overflow; last card scrolls clear of the nav (138); header buttons >= 44 and labelled; Arabic mirrors the header and the action bar (Save at the left); rail labels one line; `grep TODO(home-plan` = H1, H2, H3, H4, H6, each an open Code TODOs row. **Left for the user (B3, B2):** video autoplay in the feed (>= 60% visible, one at a time, muted), load more on a slow network, a real story upload ring, the loader against `screenshots/page-loading.png`, and the side-by-side comparison with `screenshots/s1-home-feed.png`.
**Goal:** final checks across the screen.
**Depends on:** 6; B3.
**Spec refs:** `screens/s1-home-feed.md` > Responsive / a11y, Acceptance; `../_theme/rtl.md`.
**Tasks:**
- [x] Wide screen: `ContentWidth` centers the feed; 320 dp at 2.0x text EN + AR; names and labels stay 1 line.
- [x] Tap targets >= 44, semantics on every icon button; RTL mirroring per `rtl.md` (media does not mirror).
- [ ] Device checks B3 (video autoplay rules, slow network load more, story upload ring); B2 loader comparison.
- [x] `grep -rn "TODO(home-plan"`: each marker matches an open Code TODOs row.
**Done when:** full acceptance checklist of S1 passes on device side by side with the screenshot.
**Verify:** device run vs `screenshots/s1-home-feed.png`.

## Verification
Each phase: `fvm flutter analyze` clean, `fvm flutter test` green, the phase's "Done when" checked. Screens: compare with `docs/specs/home/screenshots/s1-home-feed.png` (note: it still shows the old "Trending" title; the spec title is "Stories", Q18) and `page-loading.png`.
