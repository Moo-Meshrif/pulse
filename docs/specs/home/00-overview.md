# Home: overview

Platform: Flutter, phone, 390 x 844 design frame, **light only**, LTR + RTL, English + Arabic [user]. No Figma; screenshot + `source-tokens.md` (user-supplied exact tokens, `[est]` marked) are the source. Screenshot is 720 px wide (1.846x).
Theme: reuse `../_theme/` and `lib/core/theme/` (`context.appColors`, `context.text`, `AppSpacing`, `AppRadius`, `AppShadows`). Deltas only in `01-design-tokens.md`. RTL rules: `../_theme/rtl.md`. Auth is the reference for structure.
Architecture [user]: Home is presentation only and **composes**: `PostCard`, `PostOptionsFlow`, `HiddenPostRow` and `PostActionsCubit` imported from the post feature's public presentation exports (`features/post/presentation`, specced in `../post/02-components.md`), its likes, saves and option actions go through the post feature's `PostActionsCubit` (which Home provides for its feed); story data/routes (open story viewer, create story) from the story feature; the rail UI itself is home's. It calls **use cases of the post feature** (home feed, like, save, hide, delete, comments toggle) the **follow** feature (`ToggleFollowUseCase`, `GetFollowRequestCountUseCase`, `GetSuggestedProfilesUseCase`), the **shared use cases** in `lib/shared/content` (`ReportContentUseCase`, `SetMuteUseCase`) and **of the story feature** (`GetStoryRailUseCase`, `WatchStoryRailChangesUseCase`), and reads how a story or post is being sent through the shared `GetPublishStatusUseCase` / `RetryPublishUseCase` / `DiscardPublishUseCase` (`ContentPublishStatus` on the `EventBus`, 2026-10-16). It uses their public entities (`PostEntity`, `StoryRailItemEntity`, shared `ContentPublishStatus`) but never their datasources, models or repositories. The data layer (datasources, models, repositories) lives in those features. Backend: Supabase now, REST later (same datasource-interface rule as auth). Schema: applied in `supabase/migrations/20261012120000_home_feed.sql` and `20261013140000_post_options.sql` (spec copies removed). Calls in `screens/s1-home-feed.md` > Data mapping.

## Scope
| In | Out (separate feature) |
|---|---|
| Home tab content: header, Stories rail, post feed, its states | **Control page** feature (MainShell): floating iOS-style glass nav bar, tab switching, tab Navigators, Create sheet, back-behavior, re-tap-to-top. It hosts and imports the pages of all other features [user] |

Home is the Home tab root of the control shell (`ControlScreen`), which already exists; the placeholder nav (C13) is obsolete and the bottom clearance comes from `NavClearance` [user, 2026-10-14].
Source file `source-tokens.md` section 1 (nav, badges, Create sheet) is kept for the control-page spec; do not build it from here.

## Screens
| ID | Name | File | Screenshot | Route |
|---|---|---|---|---|
| S1 | Home feed | screens/s1-home-feed.md | screenshots/s1-home-feed.png | `/home` (tab 0) |

Referenced, not designed here (placeholders, TODO later): `/search`, `/activity`, profile, comments page, system share. Create story and the story viewer are built (story feature).

## Navigation map
```
/home (S1)
  Search icon        --> /search (push inside Home tab)
  Bell icon          --> /activity (push)
  "Your story" (+)   --> AppRoutes.createStory (/create/story, exists)
  Story avatar       --> AppRoutes.storyOf(authorId) with StoryViewerArgs(origin, person) (exists)
  Own story item     --> AppRoutes.storyOf(me)
  Post avatar/name   --> that profile
  "···"              --> post feature: options sheet (`../post/screens/s2-post-options.md`)
  Comment            --> comments page (placeholder)
  Share              --> system share sheet
  Like / Save        --> optimistic toggle, no navigation
  Empty state "Find people" --> /search placeholder (Q20)
```

## Files
`01-design-tokens.md` (deltas) · `02-components.md` · `screens/s1-home-feed.md` · `assets.md` · `open-questions.md` · `source-tokens.md` (raw user file) · `progress.md`
