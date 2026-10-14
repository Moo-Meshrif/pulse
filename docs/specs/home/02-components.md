# Home: components

Reuse before building: `AppSafeArea`, `ContentWidth`, `AvatarInitials`, `LogoTile`/`LogoLockup`, `AppSvgIcon`, `AppEmpty`, `PillButton`, `PrimaryButton`, `AppLoadingView`. Post widgets (PostCard, options flow, hidden row) are the post feature's public exports (`features/post/presentation`). Feature-only widgets go in `features/home/presentation/widgets/`; shared ones (2+ features) in `lib/core/widgets/`.

| ID | Component | Where | Anatomy / notes |
|---|---|---|---|
| C1 | HomeHeader | feature | Logo tile 28 + "pulse" wordmark (gap 8); at end: Search, Bell (44 circles, gap 4). Bell dot when unread > 0. Semantics labels "Search", "Activity" |
| C2 | StoryRail | feature (**home owns the rail UI** [user]; story feature owns the viewer and create-story screens and routes) | Horizontal list only: **no "Stories" title** [user, 2026-10-15]. **No scrollbar** (hidden) [user]. Empty: only "Your story". Items = dashed "Your story" tile first, then `StoryRailItemEntity`s (your own, `isMe`, shows as a normal item right after it). Reloads on `WatchStoryRailChangesUseCase`; tile state from `WatchStoryUploadUseCase`. Own `StoryRailCubit` |
| C3 | StoryItem | feature | 64 avatar with ring (unseen `primary` 2.5, seen `border` 2.5, inner padding 3) + 1-line label 12 textSecondary, width 64 |
| C4 | YourStoryItem | feature | 64 circle `primarySoft`, dashed 2 `primary` border (CustomPainter), plus icon 24; label "Your story". Tap -> `AppRoutes.createStory`. Upload states (`StoryUploadStatus`, story S4 `../../story/screens/s4-posting-rail.md`): **Idle/Done** = as above (Done: unseen ring on your item, label back to normal); **Uploading** = progress ring 64, stroke 3, `primary` on `border`, your avatar inside, label "Posting…"; **Failed** = `warningInk` ring (#B26F12), label "Retry", tap retries (`RetryStoryUploadUseCase`) + error notice with Retry |
| C5 | PostCard, author row, caption, media, action bar, relative time, options flow, hidden row | **post feature public exports** (`features/post/presentation`, specced in `../../post/02-components.md`, P1-P8) | Home maps `PostEntity` -> `PostCardData` (signs media via `SignPostMediaUrlsUseCase`, `visibility` -> `audienceIcon`), passes `PostCardCallbacks` and a `PostOptionsActions`, and handles list-level results (hidden row + Undo, removal, refresh) [user] |
| C15 | PostActionsCubit | **post feature** (`features/post/presentation/cubit`, P9; moved out of Home [user, 2026-10-14] because the post detail page will use it); Home provides one per feed screen | List cubit: optimistic like/save with rollback; builds the ten `PostOptionsActions` callbacks. Uses `SetPostLikeUseCase`, `SetPostSaveUseCase`, `HidePostUseCase`, `SetCommentsEnabledUseCase`, `DeletePostUseCase` (post), `ReportContentUseCase`, `SetMuteUseCase(MuteScope.posts)` (shared), `ToggleFollowUseCase` (follow). Audience change: `PostVisibilitySheet` saves it and `onAudienceChanged` updates the card; Edit caption = null (coming soon) |
| C11 | PulseLoader = existing `PulseLineLoader` | `lib/core/widgets/loading_overlay/pulse_line_loader.dart` (**not new**) | Takes `color` and `width`; used for pull-to-refresh (56 wide, stroke 2.2) and load-more (44 wide, stroke 2). Check in the plan that it matches board `../screenshots/page-loading.png` (sweeps on with a glowing head, wipes off, 1.8 s, stroke per size) and extend with a `stroke` parameter only if missing [user board] |
| C14 | Feed skeleton | feature | `Skeletonizer` (shimmer) over the real layout: story circles + post cards (avatar 40, 2 text lines, media r16, action bar). Header and nav are real. Blocks #E6E9E7, highlight #F1F3F2, sweep left → right every 1.4 s (mirrors in RTL); cross-fades to content in 200 ms; static under reduce motion [user] |
| C12 | FeedStatusRow | feature | load-more band 72 with PulseLoader 44; error row "Couldn't load more · Retry"; end "You're all caught up" 48 band |
| C13 | ~~Placeholder nav~~ | **obsolete** [user, 2026-10-14] | The control shell exists: Home is the Home tab root (`ControlScreen`) and reads its bottom space from `NavClearance` |

## States
| Component | States |
|---|---|
| Header bell | dot hidden / shown |
| Story item | unseen, seen |
| Post card states | see post P1-P9 |
