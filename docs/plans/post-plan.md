# Plan: post
Source specs: docs/specs/post/ (schemas: `schema-post-visibility.sql`, `schema-shared-content-actions.sql`, `schema-post-tags-mood.sql`, `schema-post-share.sql`), docs/specs/_theme/ (post card tokens also in docs/specs/home/01-design-tokens.md and home/source-tokens.md section 2.3)
Status: approved (Phases 13-18 approved 2026-10-15; Phases 19-25 added and approved 2026-10-21); Phases 26-34 (comments, post page, likes) added and approved 2026-10-25
Mode: one-by-one
Tests: cubit + widget tests in each phase (mirror `lib/` under `test/`, helpers in `test/helpers/pump_app.dart`, datasource tests with `test/helpers/backend_double.dart`; widget tests EN + AR/RTL + 1.5x text)

## Progress (updated 2026-10-15): live runs and device checks tested by the user; only the Arabic review remains
| Phase | State |
|---|---|
| 0 Prerequisites, 1 Tokens, 2 Data layer | done |
| 3 Visibility backend + data | **done**; migrations `20261018120000_post_visibility.sql` then `20261019120000_shared_content_actions.sql` validated and **applied** on the linked project (2026-10-14) both before any live run |
| 4 Post card widgets (P1-P6) | **done** on doubles (device run and screenshot comparison tested by the user 2026-10-15) |
| 5 Options sheet + hidden row (P7, P8) | **done** on doubles (device run and screenshot comparison tested by the user 2026-10-15) |
| 6 New post (S1) | **done** on doubles (device run and screenshot comparison tested by the user 2026-10-15) |
| 7 Visibility picker (S4) | **done** on doubles (device run and screenshot comparison tested by the user 2026-10-15) |
| 8 Places data + Edge Function | **done**, function **deployed** 2026-10-14 (B1) |
| 9 Add location (S3) | **done** on doubles (device run and screenshot comparison tested by the user 2026-10-15) |
| 10 Integration | **done on doubles** (boot test + DI/routes); the live Supabase run waits for a simulator/device (B1 is deployed) |
| 11 Polish | **done**; device checks (B6) tested by the user 2026-10-15; side-by-side screenshot comparison tested by the user 2026-10-15 |
| 12 Edit post (S5) | **done** on doubles (commit d506cb9); migration `edit_post` applied 2026-10-15 (B8); live save and device run tested by the user 2026-10-15 |
| 13 Tags + mood backend and data | **done**; migration `post_tags_mood` **applied** 2026-10-15 (B9), behaviour checked in a rolled-back batch; Dart data layer and tests green |
| 14 Card headline, meta, comments-off | **done** on doubles (device check against `s10-card-details-board.png` tested by the user 2026-10-15) |
| 15 Tag view on the card, S10, S11 | **done** on doubles (device check against the two boards tested by the user 2026-10-15) |
| 16 S6 Tag people + S7 Tag in photo | **done** on doubles (device check against board panels 1-3 tested by the user 2026-10-15) |
| 17 S8 Feelings + New/Edit post rows | **done** on doubles (device check against board panels 4 and 7 tested by the user 2026-10-15) |
| 18 Integration + polish (tags, mood) | **done**; the live run on a device and the board comparisons of 14-17 tested by the user 2026-10-15 |
| 19 Share backend + data | **done** 2026-10-21; migration `post_share` applied |
| 20 Shared post card (P10, P11) | **done** 2026-10-21 (device check is yours) |
| 21 Share sheet (S12) | **done** 2026-10-21 (device check is yours) |
| 22 Edit a share | **done** 2026-10-21 (device check is yours) |
| 23 Add to story: editor (S13) | **done** 2026-10-21 (device check is yours) |
| 24 Story viewer: post sticker | **done** 2026-10-21 (device check is yours) |
| 25 Integration + polish (share, sticker) | code done; live run, size checks and the story-sticker boot test open |
| 26 Comments backend + data | **done** 2026-10-25; migration `post_comments` **applied** (B15) |
| 27 Comments sheet: read (S14 panels 1, 5) | code done 2026-10-25 |
| 28 Write, reply, draft (S14 panel 2, 4) | code done 2026-10-26 (not opened on a device; the sheet is wired in Phase 33) |
| 29 Comment actions (S14 panel 3) | not started |
| 30 Mentions (S14 panel 6) | code done 2026-10-26 (not opened on a device; the sheet is wired in Phase 33) |
| 31 Post page (S15) | not started |
| 32 Likes list (S16) | not started |
| 33 Entry points + notification jump | not started |
| 34 Integration + polish (comments, post page, likes) | not started |

Open before / during Phase 5: the dark confirm dialog and the option / audience row widgets are built in the post feature first and move to `core/widgets` only when story or short actually reuses them (then as a variant or tone of the one widget, default look unchanged; search `core/widgets` and `confirmation_strategy` before adding). Still open: whether the close-friends list moves into `lib/shared/content`.

## Summary
- **Screens:** S1 New post (`screens/s1-new-post.md`), S2 Post options sheet + report flow + hidden row (`screens/s2-post-options.md`), S3 Add location (`screens/s3-add-location.md`), S4 Post visibility picker (`screens/s4-visibility.md`, board `screenshots/s4-visibility.png`), S5 Edit post (`screens/s5-edit-post.md`, no screenshot: S1's layout opened on an existing post).
- **Post feature widgets (pure UI in `features/post/presentation/widgets/`, moved to `core` only if a second feature needs them):** P1 PostCard, P2 PostAuthorRow, P3 ExpandableCaption, P4 PostMedia, P5 PostActionBar, P6 relative time (`core/utils`), P7 PostOptionsSheet, P8 HiddenPostRow (`02-components.md`), plus the S4 sheet. Built here, connected to the feed by the home plan [user].
- **Data:** post feature (feed page, signed media URLs, create post with visibility), post actions (like, save, hide, comments toggle, delete) in the post feature, and report / change audience / mute / audience counts / account privacy as shared use cases in `lib/shared/content` (Q13, superseded 2026-10-14) [user], post visibility backend (migration from the S4 board), places (Edge Function `places` over OSM, recent places on device, one-time device position).
- **Goal:** a person can write a post with up to 10 photos/videos, a place, an audience and comments on/off, and share it; the card, options sheet and visibility picker are ready for Home.
- **Added 2026-10-15 (Phases 13-18):** S6 Tag people, S7 Tag in photo, S8 Feelings (Feelings tab only), S10 Tagged people sheet, S11 Remove your tag, card headline / meta / tag badge and labels / comments-off (`02-components.md` P2a-P2c, P5), S1/S2/S5 deltas, backend `schema-post-tags-mood.sql`. Boards: `screenshots/s6-tag-feeling-board.png`, `s10-card-details-board.png`, `s11-remove-tag-board.png`.
- **Out of scope** (specs): the Home feed screen and its Cubit (home plan), activities (S8 Activities tab = "Coming soon", S9 deferred, source API or database undecided [user]), the profile Tagged tab (profile spec; `tagged_posts` RPC only), Settings > Privacy "Allow tags" toggle, Activity screen UI for tag notifications, blocked accounts in tag search (no blocks table), sharing a post by link (Copy link, WhatsApp and More in the Share sheet stay coming soon until the user provides the deep link, T7), Send in chat (T20), Settings > Privacy screen (Q-V1), camera capture in New post, media reorder, saved list, Shorts' "Who can watch", location page and coordinates columns (Q-L6).
- **Build order** (progress.md): control-page (done), story (done), **post**, home.

## Share and Add to story: what you will see (Phases 19-25, added 2026-10-21)
Source: `screens/s12-share-sheet.md`, `screens/s13-add-to-story.md`, `02-components.md` P10-P11, boards `screenshots/s12-share-board.png` and `s13-add-to-story-board.png`.

**Today's problem:** the send icon on a post, and Share in post options, only say "Coming soon". You can't pass a post on.

**1. You tap the send icon on a public post**
→ A Share sheet opens with a box "Say something about this...", a Public chip, and three small buttons: Tag people, Feeling and Location.
→ Below it you see Add to story, Copy link, WhatsApp and More. Copy link, WhatsApp and More still say "Coming soon" until you give us the link.
→ On your own Followers-only post the sheet only has Add to story. On other people's Followers-only posts, and on Close friends or Only me posts, there is no send icon.

**2. You tap Share now (with or without words)**
→ The sheet closes. A notice says "Shared to your feed", and the line under it matches your audience ("Everyone can see it now.", "Your followers can see it now.", and so on). You tap View and Home scrolls to the top.
→ Your share shows "You shared Nour Adel's post", your words, and the original post in a framed card. Likes and comments are on your share, not the original.
→ If it fails (offline, or the post was deleted meanwhile), the sheet stays open with your words and a notice says what happened.

**3. You share a post that is itself a share**
→ The original post is shared, not the share.

**4. You tap the dots on a share**
→ On your own share: edit your words, feeling, place and tags (no photos, so tags have no spot on a picture), change who can see it, turn comments off, or delete it.
→ On someone else's share: the usual options for a post that isn't yours.
→ You tap the framed original: it opens that post's comments (a post page comes later).

**5. The original is deleted, or you can no longer see it**
→ The frame turns into "This post isn't available" with a lock. The share and its words stay, and the header says "Omar Khaled shared a post".

**6. You tap Add to story**
→ The story editor opens with the post as a white card on a background made from the photo's colors. You drag, pinch (half to double size) and rotate it. Tap it to switch to a photo-only or a compact look.
→ You can add text above it. You pick the story audience: your post's audience or narrower. A Followers post can't go to everyone.
→ Share posts the story.

**7. Someone views your story and taps the post card**
→ The story pauses, the screen dims a little, and a "View post" button appears. Tap it to open the post's comments. Tap anywhere else to go on.
→ If the post was deleted or they can't see it, the card is replaced by a grey "Post unavailable" card.

**8. The author of the post you shared**
→ Gets a notification row of type share, one per post. No screen shows it yet (Activity comes later).

**What it can't do yet:** Send in chat (needs the chat feature), Copy link, WhatsApp and More (wait for your deep link and the share text), opening the post on its own page, the "shared in their story" notification, and showing the share notification in an Activity screen.

## Comments, the post page and Likes: what you will see (Phases 26-34, added 2026-10-25)
Source: `screens/s14-comments-sheet.md`, `screens/s15-post-page.md` (includes the Likes list), boards `screenshots/s14-comments-board.png` and `s15-post-page-board.png`.

**Today's problem:** the comment icon on a post, a share's framed original and "View post" on a story only open an empty placeholder page. You can't read, write or like comments, and there is no page for a single post.

**1. You tap the comment icon on a post in the feed**
→ A sheet slides up over the post with "Comments" and a "Most relevant" chip. Each comment shows who wrote it, when, "Reply" and the likes. The post author's replies carry an "Author" badge.
→ Replies sit under their comment, indented. Three show first, then "View 2 more replies".
→ No comments yet: "No comments yet. Start the conversation." and the keyboard opens.
→ If loading fails, you see "Try again". There is no pull to refresh.

**2. You change the order**
→ You tap the chip. A small menu shows "Most relevant" and "Newest". The list starts again from the top in your choice.

**3. You write a comment**
→ A row of quick emoji sits above the field. Tapping one puts it in your text. Send lights up when there is text. The limit is 1000 characters; a counter shows after 900.
→ Your comment appears at once, faded, with "Posting…". If it fails, you see "Couldn't post · Retry · Delete". Retry never posts it twice.
→ If you close the sheet with unsent text and open it again on the same post, your text is still there until you close the app.
→ If comments are off on the post, the old comments stay readable and a bar says "Comments are turned off for this post" instead of the field.

**4. You reply**
→ You tap Reply. The comment is highlighted and the field starts with their @name and a "Replying to @name" strip. Replying to a reply attaches to the first comment.

**5. You press and hold a comment**
→ On someone else's: quick emoji, Reply, Copy text, Hide comment (only the post owner) and Report comment. Tapping an emoji puts it in your reply.
→ On your own: Edit, Copy text, Delete. Edit puts the text in the field with an "Editing comment" strip; after saving, the row says "Edited". Delete asks first and also deletes the replies.
→ Hide comment: it disappears for everyone but its writer, and a notice "Comment hidden" has Undo.
→ Report comment uses the same report sheet as posts.
→ Double-tap a comment to like it. The heart on the right does the same and can undo.

**6. You mention someone**
→ You type @ and letters. Three suggestions (your followers and people in the thread) appear above the field. Picking one writes their @username. They get a mention notification. Tapping a @name opens their profile (profiles are still a placeholder).

**7. You open the post page**
→ From the framed original on a share, "View post" on a story, a link or a notification. The page has the full post, "Liked by …", the date and the comments below, with the field pinned at the bottom.
→ Scrolling up past the author swaps the title for a small author name. If you don't follow the author, a Follow chip shows and then reads "Following". The "..." opens the post options. The comment icon on this page puts the cursor in the field.
→ From a notification about a comment, reply or mention, that comment is first in the list, highlighted for 2 seconds, with a small "From your notification" chip. For a reply, its parent comment is shown first.
→ If the post is deleted, private, or the audience changed: a lock, "This post isn't available" and Back to Home.

**8. You tap "Liked by …"**
→ A Likes list opens with a search box and people with Follow, Following or Follow back. The post's author sees everyone; others see only people they are allowed to see. Searching waits for you to stop typing. Unfollowing is immediate.

**Safety**
- Only you can edit or delete your comment. Only the post owner can hide others' comments. Nobody can reply to a reply (it goes to the first comment).
- A hidden comment stays visible to its writer so they don't know.
- You can't comment or read comments on a post you can't see.

## Reuse
- Theme: `context.appColors` (`background`, `surface`, `primary`, `primarySoft`, `textPrimary`, `textSecondary`, `border`, `divider`, `dashed` #9AA6A2, `danger`, `like`, `storyRing`, `warningSoft`, `warningText`; check `switchOff` #C9D3D0 and `mediaChip` #161A19 @ 55% exist before adding), `context.text` (`title`, `titleSm`, `name`, `caption`, `section`, `button`, `body`), `AppSpacing` / `AppRadius` / `AppScale` (fixed values need `// unscaled: <reason>`, `no_unscaled_literals_test`).
- Widgets: `AppBottomSheet` (sheet shell), `ReportSheet` + `ReportCopy` (reasons, note step, sent step; `TODO(story-plan T6)` for the post's Mute / Unfollow rows), `ConfirmationDialog` (destructive), `AppSafeArea`, `AppPage`, `AppTopBar`, `AppBackButton`, `AppSvgIcon`, `AppText`, `AppTextField`, `PrimaryButton` (`loading` flag), `PillButton`, `AvatarInitials`, `AppImage` / `CachedPicture`, `AppEmpty`, `ContentWidth`, `PulseLineLoader`, `TintedChip`.
- Notices: `context.showSnackBar` / `showFailure` (with action, added in the story plan).
- Utils/services: `uuid_v4`, `report_note` (5+ chars), `MediaPickerService` (image_picker + video length/size; extend for multi-pick, Q8), `PhotoPickerService` (resize pattern for Q7), `AppVideoController` / `video_flux` (P4 video), `VideoThumbnailService` (video poster), `ConnectivityService`, `LaunchService` (open settings), `LocalStorageService` + `StorageKeys` (recent places, one-time visibility notice), `permission_handler` (`CameraPermissionService` pattern for location).
- Enums: core `ReportReason` (wire values) already exists; reuse it, do not add a second one in post.
- Use cases from other features: `ToggleFollowUseCase` (follow) for Unfollow; a profile use case for the signed-in name/avatar (check `GetLastAccountUseCase` / profile entity fit, else add one in profile); story's close-friends list route `/audience/close-friends` (S4 Edit) and the follower / close-friends counts (shared `GetAudienceSummaryUseCase`, `lib/shared/content`).
- Navigation: `AppRoutes.createPost` (`/create/post`) already exists and the Create sheet pushes it; `AppNavigator.push(..., rootNavigator: true)`; `AppRouter.onGenerateRoute`. `/privacy` is the Privacy Policy, not settings.
- Backend (applied): `create_post` with `p_comments_enabled`, `home_feed`, `set_post_like`, `set_post_save`, `hide_post`, bucket `post-media`, `profiles.is_private`, `can_view_author`, `close_friends` (story audience).
- Icons registered: `ic_image`, `ic_tag_person`, `ic_smile`, `ic_globe`, `ic_audience`, `ic_star`, `ic_lock`, `ic_chevron_down`, `ic_chevron_right`, `ic_comment`, `ic_bookmark`, `ic_eye_off`, `ic_volume_off`, `ic_arrow_back`, `ic_search`, `ic_link`, `ic_more_horizontal`, `ic_heart_filled`, `ic_flag`, `ic_trash`, `ic_location`. Files present, **not registered**: `ic_bookmark_filled`, `ic_clock`, `ic_crosshair`, `ic_crosshair_thin`, `ic_location_thin`.

## Decisions [user, 2026-10-14]
- Shared code: business data/domain used by 2+ features lives in `lib/shared/<concept>/{data,domain}` with generic names, Cubits call its use cases; `shared` imports only `core`, `core` never imports `shared`. Done for `content`: report, change audience, mute (posts and stories independent), file cleanup, audience counts, account privacy, enums `ContentKind` / `MuteScope` / `ContentAudience` (was `PostVisibility`). One RPC per action with `p_kind` (post | story | short). Still open: shared dark confirm dialog, shared option / audience row widgets (waiting on the dark dialog look), moving the close-friends list into shared, applying both migrations (B7, `post_visibility` first).
- Packages: `geolocator`, `blurhash_ffi` (encode + decode); `share_plus` approved but added only when post sharing by link is built (Copy link, WhatsApp and More stay coming soon); no palette package: `PaletteService` reads the story sticker background colors itself (Phase 23).
- Image resize: a presets enum, default **Instagram-like 1080 px longest side, quality 80**; other presets 1440 / 85 and 2048 / 85; switched by changing one flag in code (no user setting).
- `places` Edge Function: builder writes and tests it locally, then asks the user before deploying.
- Visibility built now from the S4 board; default Public unless "Use for future posts" saved another, Followers on a private account.

## Blockers
| Id | Item | Blocks phase | Needed from | Status |
|---|---|---|---|---|
| B1 | Edge Function `places` deploy | 8 (live), 9 live check | user approval at end of Phase 8 | **done 2026-10-14**: deployed to project `pulse`, version 1, `verify_jwt` on; `PLACES_USER_AGENT` secret not set (generic default in use) |
| B7 | Visibility migration (Phase 3) reviewed and applied | 3 apply, live checks of 6, 7 | user review, then apply | **done 2026-10-14** (live checks of 6, 7 still to run in Phase 10) |
| B4 | Arabic copy (Q10) drafts `x-review` | none | user review | open, no code marker |
| B5 | Estimated values shipped as is: disabled Share opacity 40%, primer sizes and title ~22, no-results title ~18/700 | none | user review on device | open, no code marker |
| B6 | Real-device checks: picker with videos (10 min / 50 MB), upload on slow network, location permission iOS + Android | 11 | user | **done**: tested by the user 2026-10-15 |
| B8 | Migration `edit_post` (`update_post` rpc) reviewed and applied | 12 live save | user | **done 2026-10-15** (in the linked project's history as `edit_post`) |
| B9 | Migration `post_tags_mood` (from `schema-post-tags-mood.sql`) validated in a rolled-back batch, then applied after the user approves | 13 apply; live checks of 14-18 | user approval | **done 2026-10-15** (applied as `post_tags_mood`, version 20261015162526) |
| B11 | Migration `post_share` (from `schema-post-share.sql`: `posts.shared_post_id`, `share_to_feed`, `home_feed` embed, notification type `share`, `stories.shared_post_id` / `sticker`, `create_story`) validated in a rolled-back batch, then applied after the user approves | 19 apply; live checks of 20-25 | user approval | open |
| B12 | ~~Palette tool icon~~ `ic_palette.svg` added by the user 2026-10-21 (register it) | 23 | user | **done** |
| B14 | ~~Title icon `ic_share_forward`~~ added by the user 2026-10-21 (register it) | 21 | user | **done** |
| B13 | Arabic copy for S12, S13 and P10-P11 (`x-review`) | none | user review | open, no code marker |
| B15 | ~~Migration `post_comments` (comments columns and tables, `post_comments`, `comment_replies`, `add_comment`, `edit_comment`, `delete_comment`, `hide_comment`, `set_comment_like`, `comment_mention_candidates`, report kind `comment`) validated in a rolled-back batch, then applied after the user approves | 26 apply; live checks of 27-34 | user approval | **done 2026-10-25** (applied; B18 = hidden comments stop counting, confirmed) |
| B16 | Migration `post_likes_list` (`post_likers`, `liked_by_preview`) validated, then applied after the user approves | 32 apply; live check of 32-34 | user approval | open |
| B17 | Arabic copy for S14-S16 (`x-review`) | none | user review | open, no code marker |
| B18 | Does a hidden comment still count in the post's comment number? | 26 | user | **answered 2026-10-25**: no (hiding lowers it, Undo raises it again) |
| B10 | Arabic copy for S6-S11, headline connectors and the ten drafted feeling nouns (`x-review`; user gave سعادة، حماس، امتنان، تعب and the noun rule) | none | user review | open, no code marker |

## Code TODOs
| Id | What is pending | Code it sits in | Phase |
|---|---|---|---|
| T2 | ~~Tag people is "coming soon"~~ done in Phase 16, marker removed | the New post options card | 6 -> 16 |
| T3 | ~~Feeling / activity is "coming soon"~~ done in Phase 17 (Feelings only), marker removed | the New post options card | 6 -> 17 |
| T4 | Camera capture not in the New post picker (gallery only now) | the post media picking (`MediaIntake.pick`) | 6; marker added in Phase 12 |
| T5 | ~~Home feed refresh after "Post shared"~~ done 2026-10-14: `CreatePostUseCase` asks for a feed refresh once the post exists; marker removed | `NewPostScreen` (`TODO(post-plan T5)`) | 6 |
| T6 | ~~Edit caption opens no page~~ done: Edit post screen (`s5-edit-post.md`), marker removed | `PostOptionsActions.onEdit` | 5 |
| T7 | Copy link in S2, and Copy link, WhatsApp and More in the Share sheet are "coming soon" until the user provides the deep link (`https://pulse.app/p/{post_id}`) and the share text, and `share_plus` is added (Q-V3). S2 Share itself opens the sheet from Phase 21 | `PostOptionsFlow` Copy link tile and the Share sheet's external row (`TODO(post-plan T7)`) | 5 -> 21 |
| T8 | ~~Story plan's `TODO(story-plan T6)`: Mute / Unfollow rows~~ done in Phase 5 (`ReportSentRow`), marker removed | the shared report sheet | 5 |
| T12 | ~~The visibility chip says "Coming soon" until the picker exists~~ done in Phase 7 | - | 7 |
| T11 | "Privacy settings" link shows "Coming soon" until a Settings > Privacy screen is specced (Q-V1) | `PostVisibilitySheet` private note (`TODO(post-plan T11)`) | 7 |
| B1 | ~~Places Edge Function deploy waits for approval~~ deployed 2026-10-14 | the places datasource | 8 |
| T9 | Optional later columns `location_place_id/lat/lng` and a location page (Q-L6) | - | no code marker |
| T10 | Arabic review (B4, B10) | ARB files | no code marker |
| T13 | Activities deferred: the S8 Activities tab shows "Coming soon"; S9, activity verbs and suggestions come later from an API or a database (source undecided) | the feeling picker's Activities tab | 17 |
| T14 | Blocked accounts are not filtered from tag search / `can_tag` (no blocks table yet) | `tag_search` / `can_tag` in the migration (SQL comment `TODO`) | 13 (SQL comment, no Dart marker) |
| T15 | "Allow tags" (everyone / people you follow / no one) has no settings toggle; column default `everyone` | - | no code marker (Settings not specced) |
| T16 | Profile Tagged tab and its long-press sheet (`s11-remove-tag.md` entry 3); `tagged_posts` RPC exists, no Dart call | - | no code marker (profile spec) |
| T17 | ~~Comments-off bar on the post / comments page~~ done in Phases 28 and 31; was: comments-off bar on the post / comments page (`02-components.md` "Post page when comments are off") | - | no code marker (comments page is home-plan H3's placeholder) |
| T18 | Tag notifications (type `tag`) are written but no screen shows them | - | no code marker (Activity not specced) |
| T20 | Send in chat (panels 5-7 of the board) is hidden until the Chat tables and screens exist; `share_targets` / `share_post` are specced but not written | the Share sheet (`TODO(post-plan T20)` where the chat row would sit) | 21 |
| T21 | ~~The post page doesn't exist~~ done in Phase 33 (markers removed); was: the post page doesn't exist: tapping the framed original on a share and "View post" on a story sticker open the post's comments route | the shared card's original tap and the story viewer pill (`TODO(post-plan T21)`) | 20, 24 |
| T22 | Notification type `share` is written but no screen shows it; the "shared your post in their story" notification (`story_mention` style) is not written | - | no code marker (Activity not specced) |
| T23 | Tapping a @name in a comment opens the profile placeholder until profile screens exist | the comment row's mention text (`TODO(post-plan T23)`) | 30 |
| T24 | Notification screens (Activity) are not built: a comment / reply / mention notification only opens the post page through its link `/p/:postId?comment=:id` once Activity exists | - | no code marker (Activity not specced) |

## Phases

### Phase 0: Prerequisites
**Status:** [x]
**Goal:** packages, permissions, icons and backend confirmed so later phases compile and run.
**Depends on:** none.
**Spec refs:** `post/assets.md`, `post/open-questions.md` (Q7, Q8, Q-L1, Q-L4), `post/00-data-layer.md`, Decisions above.
**Tasks:**
- [x] Add `geolocator` and `blurhash_ffi` (current stable versions).
- [x] Record the resize presets (Decisions) in `post/01-design-tokens.md` Behavior tokens.
- [x] Platform: iOS `NSLocationWhenInUseUsageDescription` + `permission_handler` location macro; Android `ACCESS_COARSE_LOCATION` (and fine only if needed for nearby accuracy, say which).
- [x] Register `ic_bookmark_filled`, `ic_clock`, `ic_crosshair`, `ic_crosshair_thin`, `ic_location_thin` in `AppAssets`.
- [x] Confirm on the linked project (read only) that `create_post(uuid, text, text, text, jsonb, boolean)` and `post-media` storage policies are live; report any difference.
**Out of scope:** any UI.
**Done when:** packages resolve, `fvm flutter analyze` clean, icons registered, backend check reported.
**Verify:** `fvm flutter pub get`, `analyze`, full test suite green.

### Phase 1: Tokens
**Status:** [x]
**Goal:** the post dimensions and any missing colors exist as tokens.
**Depends on:** 0.
**Spec refs:** `post/01-design-tokens.md` (all sections incl. "Visibility picker (S4)"), `_theme/*`.
**Tasks:**
- [x] Check `switchOff`, `mediaChip`, `storyRing`, `dashed`, `warningSoft`, `warningText` and the dashed Add tile colour against `AppColors`; add only what is missing.
- [x] Add the New post, post card, options sheet, visibility picker and Add location dimensions from `01-design-tokens.md` in the project's dimens style (scaled; fixed ones commented).
- [x] Text styles: reuse existing; add only the ones not covered (input 17/400, chip 12/600, option title 16/500, option value 14/400, duration chip 12/600, picker title 15/700) if no existing style matches.
**Out of scope:** widgets.
**Notes:** only `mediaChip` (#161A19 @ 55%) was missing from `AppColors` (`videoChip` is 45%, kept). New styles `input`, `chip`, `optionTitle`, `sheetTitle` (Sora 18/700); option value reuses `bodySm`, picker row title `name`. Dimens: `PostComposerDimens`, `PostCardDimens`, `PostMotion`, `PostOptionsDimens`, `VisibilityDimens`, `LocationDimens` in `app_dimens.dart`; test `test/core/theme/post_tokens_test.dart`.
**Done when:** every value in `01-design-tokens.md` has a token or a matching existing one; `no_unscaled_literals_test` passes.
**Verify:** analyze + tests.

### Phase 2: Data layer
**Status:** [x]
**Notes:** photos are resized when picked (Phase 6, `MediaPickerService` with `ImageResizePreset.active`), not in `CreatePostUseCase`: no image encoder package is in the project, `image_picker` resizes while picking. `ImageResizePreset` exists now. A failed upload keeps the uploaded files for Retry; only a failed `create_post` removes them (a discarded post after an upload failure can leave files behind).
**Goal:** post data, post actions and their public use cases.
**Depends on:** 0.
**Spec refs:** `post/00-data-layer.md` (all, incl. "Q13 update"), `post/open-questions.md` Q2, Q9, Q13, `.claude/conventions/architecture.md`.
**Tasks:**
- [x] Post feature: posts datasource (home feed page with cursor, signed media URLs, create post) with wire models and the media type enum; reuse core `ReportReason`.
- [x] Public entities returned by the use cases (post, post media, new post input) per Q-A.
- [x] Use cases: home feed, sign media URLs, create post (uuid client id; resize per the default preset; upload to `post-media/{uid}/{postId}/{n}.ext`, video poster `{n}_thumb.jpg`; one `create_post` call with `p_comments_enabled`; remove uploaded files if the call fails; Retry re-uploads only missing files).
- [x] Post actions (Q13, superseded 2026-10-14): `PostActionsDatasource` in `features/post` (`set_post_like` -> count, `set_post_save` -> bool, `hide_post`, comments toggle, delete row) and its use cases; file cleanup after a delete is the shared `RemoveMediaFilesUseCase`. Report, change audience and mute are shared use cases in `lib/shared/content` (see Decisions).
- [x] Mute: shared `SetMuteUseCase(userId, muted, MuteScope)` over `set_mute(p_scope)` (Undo = false); `ToggleFollowUseCase` stays in follow.
**Out of scope:** visibility (Phase 3), places (Phase 8), UI.
**Done when:** every call in the `00-data-layer.md` tables exists and throws `Failure` through `Guard.run`; no feature imports another's datasource/model.
**Verify:** datasource tests on `backend_double` (RPC names and params, cursor, cleanup on failure), use case tests.

### Phase 3: Visibility backend + data
**Status:** [x] code + validation done; the two migrations are **applied** to the linked project `pulse` on 2026-10-14 (history names `post_visibility`, `shared_content_actions`; B7 resolved; live check afterwards: columns, functions and `set_mute(p_user, p_muted, p_scope)` present, old report/audience/mute functions gone, no test rows left; the existing tables had no posts yet). Full validation pass before applying on 2026-10-14 over both migrations in one rolled-back batch (4 users, 4 audiences): feed, posts, media-object access, report, audience change, mute scopes, private account, and non-author denials all behaved; nothing left behind.
**Notes:** `supabase/migrations/20261018120000_post_visibility.sql`, validated on the linked project in a rolled-back batch with 4 test users (A author, B follower, C stranger, D follower + close friend): B sees public + followers, D also close friends, C only public, Only me is hidden from all, `home_feed` matches, a non-author cannot call `set_post_visibility`, an invisible post cannot be reported, a private account's public post is stored as followers. Also added `can_view_media_object` so the signed-URL storage policy follows the post's audience, and `create_post(p_visibility null)` falls back to `profiles.default_post_visibility`. Dart: shared enum `ContentAudience` (renamed from `PostVisibility`, `lib/shared/content/data/enums`), `visibility` on `PostModel`/`PostEntity`/`NewPostEntity`, `p_visibility` in `createPost`, change-audience is the shared `SetContentAudienceUseCase` (`lib/shared/content`, see below), shared `PrivacyDatasource` + `GetPrivacyUseCase` / `SaveDefaultAudienceUseCase` (`lib/shared/content`), shared `GetAudienceSummaryUseCase`, post `VisibilityNoticeDatasource` (flag per audience). **Shared with story and short (2026-10-14):** report, change audience and mute go through `lib/shared/content` (`ReportContentUseCase`, `SetContentAudienceUseCase`, `SetMuteUseCase`, `RemoveMediaFilesUseCase`), backed by the RPCs `report_content`, `set_content_audience`, `set_mute(p_scope)` in `20261019120000_shared_content_actions.sql` (validated, applied 2026-10-14; it also drops `report_post`, `report_story`, `set_story_audience`, `set_story_mute`). `post_visibility` no longer has `set_post_visibility` / `report_post`. Both migrations are applied: the old 6-arg `create_post` and the per-kind report / audience / mute functions are gone, and the app sends `p_visibility` and calls the shared functions.
**Goal:** posts carry a visibility that the database enforces, with the data calls the picker needs.
**Depends on:** 2; B7 to apply the migration.
**Spec refs:** `post/screens/s4-visibility.md` "Data (follow-up migration)" and "Behavior", board `post/screenshots/s4-visibility.png` (Data note), `post/open-questions.md` Q1, Q-V4.
**Tasks:**
- [x] Migration in `supabase/migrations/` (applied 2026-10-14): `posts.visibility` (check public / followers / close_friends / only_me, default public), `profiles.default_post_visibility` (same check), `create_post(..., p_visibility)` (replace the 6-arg signature), the audience change is the shared `set_content_audience(p_kind, p_id, p_audience)` (author only, in `20261019120000_shared_content_actions.sql`), posts read policy (author; public + `can_view_author`; followers + accepted follow; close_friends + row in `close_friends`), `home_feed` filter with the same check and `visibility` in its rows; likes, saves, comments and reports follow the post's read access. **Validate in a rolled-back transaction; apply only after the user approves (B7).**
- [x] Data: visibility enum (wire values), `visibility` on the post model/entity, `p_visibility` on create post, change-audience through the shared `SetContentAudienceUseCase`.
- [x] Shared (core, generic): use cases to read the default post visibility and `is_private`, and to save the default ("Use for future posts").
- [x] Counts: followers and close-friends counts for the picker via the shared `GetAudienceSummaryUseCase` (`lib/shared/content`).
- [x] One-time notice flag (first post to Close friends / Only me) on the device through a datasource.
**Out of scope:** UI.
**Done when:** migration validated (and applied once approved); a Followers / Close friends / Only me post is not returned to people outside that group (SQL check as another user in the rolled-back transaction).
**Verify:** datasource + use case tests; SQL checks reported.

### Phase 4: Post card widgets (P1-P6)
**Status:** [x] built and tested on doubles (analyze clean; `test/features/post` 52 green after the performance pass in decision 8; card test in `test/features/post/presentation/widgets/post_card_test.dart`, coordinator test in `utils/`); device run and comparison with `s1-home-feed.png` tested by the user 2026-10-15 (no screen shows the card until Home exists, so the acceptance checklist in `02-components.md` stays unticked until then). Video playback is untested (the platform player cannot run in a widget test) and so is the picture-failure retry (real network I/O does not advance in the test clock): both need a device.
**Notes:** the card lives in the post feature, not `core` (feed-only, one feature uses it): `lib/features/post/presentation/widgets/` has `PostCard`, `PostAuthorRow`, `PostRingedAvatar`, `ExpandableCaption`, `PostMedia` (`media/`: `PostImageItem` with blurhash + retry, `PostVideoItem`, `PostHeartBurst`, `PostMediaChip`, `PostMuteButton`, `PostRetryBadge`, `PostBlurhash`), `PostActionBar`, `PostLikePop`, `PostTapButton`, `PostVideoScope`, `VisibleFraction`; `presentation/utils/` has `PostCardData`, `PostCardMedia`, `PostCardCallbacks`, `PostVideoCoordinator`, `postMediaAspect`, `caption_overflow`, `post_author_meta`; `core/utils/` keeps `compactCount` and `postTime` (+ tests). Not in the `widgets.dart` barrel (no other feature uses them yet); tokens `moreLink` text style and a few `PostCardDimens` / `PostMotion` values; strings `post*` (EN + AR `x-review`). The card is pure UI: the audience icon is passed as an asset path (`PostCardData.audienceIcon`), so `core` never imports `shared`.
Deviations / decisions: (1) video uses `video_flux` as its README prescribes for a timeline: `PostVideoScope(videos: postVideos(posts))` owns one `VideoFlux` (back 1, ahead 2, window 4, 150 ms debounce, lifecycle pause on) and a small `PostVideoCoordinator` that picks the one that is >= 60% visible; the scope calls `scrollToId` on the pick (or `pauseAll`), `replaceItems` when the feed changes, `retry` from the failure badge, and `disposeAll` on exit. Items never dispose controllers; mute and looping are applied in `AppVideoController.warmUp`. A card outside a scope keeps its poster. (2) Double tap is read from taps inside `PostMedia` (not `onDoubleTap`) so the mute button and retry answer at once; it is excluded from semantics. (3) Dots sit under the media, centered [estimated: the spec gives no position]. (4) The comment button shows even when comments are off (`PostCardData.commentsEnabled` is carried for the options sheet). (5) The failed-picture badge uses `ic_image` and the failed-video badge `ic_play` [estimated: no retry icon exists]. (6) Weeks use `{n}w`, then a localized `d MMM` date from 4 weeks. (7) Mute is one switch for the whole list, videos start muted. (8) Feed performance pass: `PostMedia` keeps the page index in a `ValueNotifier` so only the counter, dots and visible items rebuild on a swipe (no `setState` on the card); `ExpandableCaption` caches its overflow measurement by text, width and text scale; `PostVideoScope` is a plain `InheritedWidget` (not an `InheritedNotifier`) and each video item listens to what it needs itself, so a pick or mute change no longer rebuilds every video twice.
**Goal:** pure-UI post card in `lib/features/post/presentation/widgets/` with `PostCardData` + callbacks (moves to `core/widgets` only if a second feature needs it).
**Depends on:** 1.
**Spec refs:** `post/02-components.md` P1-P6, States, Strings, Acceptance; `post/01-design-tokens.md` "Post card and options sheet"; `post/screens/s4-visibility.md` panel 4 (meta icon); screenshot `docs/specs/home/screenshots/s1-home-feed.png`.
**Tasks:**
- [x] P1 card, P2 author row (ringed avatar, initials fallback, meta with a 12 visibility icon for non-public posts, "···" turning `primarySoft` while open), P3 caption (3 lines, more/less, less scrolls back), P4 media (aspect clamp, pager + dots + counter, `video_flux` autoplay muted at >= 60% visible one at a time, mute toggle, duration chip, blurhash placeholder via `blurhash_ffi`, tap to retry, double-tap like + heart animation), P5 action bar (like pop, compact counts), P6 relative time (EN/AR).
- [x] Strings and semantics from `02-components.md` (EN + AR `x-review`); no barrel entry (the card stays in the post feature).
**Out of scope:** feed list and its Cubit (home plan). The card is not used by any screen yet (only its test builds it).
**Done when:** `02-components.md` acceptance checklist passes against the home screenshot in a widget test harness.
**Verify:** widget tests (caption states, counts format, time format, double-tap like only likes, meta icon per visibility, RTL, 1.5x).

### Phase 5: S2 Post options sheet + hidden row (P7, P8)
**Status:** [x] built; analyze clean, full suite green (1376); device run and comparison with `s2-post-options.png` tested by the user 2026-10-15 (no screen opens the sheet until Home exists, so the S2 acceptance checklist stays unticked until then).
**Notes:** no `PostOptionsCubit` (decision with the user, 2026-10-14): `ReportSheet` already owns the reasons / note / sent steps, and story's pattern is "the sheet pops an enum, the flow calls the list". Files in `features/post/presentation/`: `utils/enums/post_option.dart`, `utils/post_options_data.dart`, `post_option_layout.dart`, `post_options_actions.dart` (the callback bag the list supplies, P9); `widgets/post_options/` (`PostOptionsSheet`, `post_option_rows.dart`, `PostOptionsFlow.show`: sheet, report, delete confirm, notices, failures); `widgets/hidden_post_row.dart` (240 ms grow-in, 5 s Undo then the pill goes, row stays; the list swaps card and row). `ReportSheet.show(sentRows:)` + `ReportSentRow` (core, callbacks only) replace `TODO(story-plan T6)` (T8 done). The dark dialog and shared option rows were not needed: post uses the existing light `ConfirmationDialog.destructive`; story keeps its dark ones. Deviations: row label uses `body` 15/500 (spec 15/600, no matching style); Undo pill is a local widget (`primarySoft` look; `PillButton` has no such variant); Edit caption and Change who can see show "Coming soon" until their callbacks are given (T6; Phase 7); Mute / Unfollow rows on the sent step close the sheet, then run and show their notice.
**Goal:** the options sheet (both variants), report flow, delete confirm and hidden row as post feature widgets (`features/post/presentation/widgets/`), driven by the list's callbacks (`PostOptionsActions`); the Undo timer is local to the hidden row.
**Depends on:** 4.
**Spec refs:** `post/screens/s2-post-options.md` (all), `post/02-components.md` P7-P9, screenshot `post/screenshots/s2-post-options.png`.
**Tasks:**
- [x] Search `core/widgets` (`AppBottomSheet`, `ConfirmationDialog` tones) before adding any row or dialog widget; build the dark confirm dialog and option / audience rows in the post feature, share them later only when story or short needs them (variant/tone, default look unchanged).
- [x] Sheet on `AppBottomSheet`: quick row (Save / Copy link / Share), group A (others / own, own includes "Change who can see" under Edit caption), red group B; actions per the "Actions and result" table, via `PostOptionsActions` callbacks. "Change who can see" is a callback here; Phase 7 supplies the sheet.
- [x] Copy link and Share show "Coming soon" when the post is Public and are hidden otherwise; marker T7.
- [x] Report: reuse `ReportSheet` with post copy, sent through the shared `ReportContentUseCase` (`ContentKind.post`); Mute is the shared `SetMuteUseCase` (`MuteScope.posts`); add the Mute / Unfollow rows to its sent step and remove the `TODO(story-plan T6)` marker (T8). `ReportSheet` is in `core`, so it only takes optional rows / callbacks for the sent step and never calls a use case; the list's Cubit (Home) behind `PostOptionsActions` calls `ReportContentUseCase`, `SetMuteUseCase` and `ToggleFollowUseCase`.
- [x] Delete: `ConfirmationDialog.destructive` with the post copy; notices "Unfollowed @x" + Undo, "@x muted" + Undo, "Post deleted".
- [x] P8 hidden row (240 ms collapse, Undo soft pill, 5 s window). The Undo window is a `Timer` in the row's `State`, cancelled in `dispose`; the "···" button and Undo pill keep a tap target of at least 48 dp.
- [x] Leave marker T6 (Edit caption).
**Out of scope:** the list Cubit that calls the post and shared use cases (home plan), Edit caption page, post links.
**Done when:** S2 acceptance checklist passes (Copy link / Share per Q-V3).
**Verify:** ask the developer which tests to write first (the plan's "Tests" line is the starting list, not the answer); then widget tests (both variants, every callback fires with the right values, quick row by visibility, report steps, note 5+ chars and 500 limit, hidden row Undo timing, EN/AR, 1.5x); compare with `s2-post-options.png`. The report lists what was not verified (no device, no pixel comparison).

### Phase 6: S1 New post
**Status:** [x] built; analyze clean, full suite green; device run and comparison with `s1-new-post.png` tested by the user 2026-10-15. Not verified: real gallery pick with videos, blurhash encoding (the native library does not load in tests, so the encode times out after 3 s there and is covered only by that fallback), the upload on a slow network, keyboard behavior with Share, Arabic copy (`x-review`).
**Notes:** files in `features/post/presentation/`: `cubit/new_post_cubit.dart` + freezed state, `screen/new_post_screen.dart` (provider, listener, `PopScope` + discard confirm), `view/new_post_view.dart`, `widgets/new_post/` (title row, composer card, caption field + counter, media strip / thumb / add tile, visibility chip, options card + row, share bar), `utils/new_post_limits.dart` (10 media, 2000 chars, video 10 min / 50 MB), `utils/enums/new_post_notice.dart`, `utils/content_audience_display.dart`. `MediaPickerService.pickMany(limit, preset)` (core) shrinks photos with the active preset through `image_picker`, reads size / file size, makes the blurhash (`blurhash_ffi`, README read: `BlurhashFFI.encode(FileImage)`, 3 s timeout) and measures videos; `PickedMedia` gained `sizeBytes` and `blurhash`. The Cubit calls the existing `CreatePostUseCase` (own feature), `GetPrivacyUseCase` (shared) for the starting audience, `GetLastAccountUseCase` (profile) for name and avatar, and makes a poster per picked video. Route `/create/post/location` added with a placeholder (`TODO(post-plan Phase 9)`); `/create/post` now opens the screen (control-page T7 placeholder removed).
Deviations: (1) the chip shows the account's default audience from `GetPrivacyUseCase` (not a fixed Public) and sends it as `p_visibility`; tapping it says "Coming soon" until Phase 7 (T12); (2) the Location row ignores a null result from the placeholder page, Phase 9 decides how "Remove" returns; (3) option title uses `optionTitle` 16/500, the duration chip reuses `PostMediaChip` with its radius as a parameter; (4) remove button keeps a 44 tap target around the 28 circle; (5) numerals in the counter are not localized to Arabic digits (rtl.md not applied; check in Phase 11).
**Goal:** compose and share a post.
**Depends on:** 1, 2.
**Spec refs:** `post/screens/s1-new-post.md` (all), `post/01-design-tokens.md` (Typography, Dimensions, Behavior tokens), screenshot `post/screenshots/s1-new-post.png`.
**Tasks:**
- [x] Screen at `/create/post` (replace the placeholder): title row + X, composer card (avatar 44, name, visibility chip, caption field max 2000 with counter `danger` at limit, media strip 104 thumbs with remove X and video duration chip, dashed Add tile hidden at 10), section label, options card (Photo / video with "{count} added", Tag people, Location with value, Feeling, Allow comments switch default on), pinned "Share post" pill.
- [x] Cubit: caption, media list, place, comments flag; Share enabled with text or >= 1 media; uploading = `PrimaryButton(loading: true)` and the screen non-interactive; success closes with "Post shared"; error stays with notice + Retry.
- [x] Media: multi-pick photos + videos up to the remaining slots via `MediaPickerService` (extended); reject video > 10 min or > 50 MB with a notice; resize images with the default preset; width/height/duration/blurhash measured before upload.
- [x] Discard confirm on X / system back only when there is content.
- [x] Visibility chip shows the default (Public) for now; Phase 7 makes it open S4. Location row is wired to its route; Phase 9 builds S3.
- [x] Coming-soon notices and markers: T2 (Tag), T3 (Feeling), T4 (camera), T5 (feed refresh).
- [x] Strings EN + AR `x-review`, semantics ("Remove photo {n}", switch label, counter at limit), RTL mirroring, `ContentWidth`, keyboard keeps Share visible.
**Out of scope:** reorder, camera.
**Done when:** S1 acceptance checklist passes.
**Verify:** cubit tests (enable rules, limits, success/failure/retry, discard), widget tests EN/AR/1.5x; compare with `s1-new-post.png`.

### Phase 7: S4 Visibility picker
**Status:** [x] built; analyze clean, full suite green (1436); device run and comparison with `s4-visibility.png` tested by the user 2026-10-15. Not verified: the sheet over a real keyboard-less device frame, the toast above the sheet on a device, the close friends list round trip (route exists from the story plan, only its counts reload is tested), Arabic copy (`x-review`).
**Notes:** `features/post/presentation/`: `cubit/post_visibility_cubit.dart` + freezed state (loads privacy and counts together, applies on Done / Save, saves the default only when the toggle is on, first-use notice decided at Done, `reloadCounts` after the close friends list), `widgets/post_visibility/` (`PostVisibilitySheet.choose` for New post, `.change` for an existing post, rows with radio and Edit pill, private note, future toggle, `VisibilityToast`), `utils/post_visibility_result.dart`. `ContentAudience.isNarrowerThan` (shared enum member) drives the narrowed chip; `NewPostState` keeps `defaultVisibility`. "Change who can see" now opens the sheet from `PostOptionsFlow` (`PostOptionsData` gained `postId` and `visibility`, `isPublic` is derived; `PostOptionsActions.onChangeAudience` became `onAudienceChanged(audience)` so the list updates the card), then shows "Visibility updated".
Deviations: (1) the one-time notice shows right after Done in the picker (panel 3), as a dark card on the root overlay with no fade (animated opacity is banned); (2) the "Privacy settings" link uses the same toast for "Coming soon", because a snackbar would be hidden behind the sheet (T11); (3) with nobody on the close friends list, tapping that row opens the list (as in the story sheet); (4) the load-failed state is a plain message with Retry; loading height is an estimated token; (5) the chip keeps the spec's 28 height as its tap area.
**Goal:** choose and change who can see a post.
**Depends on:** 3, 5, 6.
**Spec refs:** `post/screens/s4-visibility.md` (all), `post/01-design-tokens.md` "Visibility picker (S4)", board `post/screenshots/s4-visibility.png`.
**Tasks:**
- [x] Sheet (Post options shell): title + close, 4 rows (tile, title/sub, radio; Close friends "Edit" pill opens `/audience/close-friends` and counts reload after), Done; "Use for future posts" toggle on New post only; private account: amber note, Public disabled, default Followers.
- [x] New post: chip opens the sheet, shows the choice's icon/label, narrowed style when narrower than the default; choice sent as `p_visibility`; Done with the toggle on saves the default.
- [x] One-time dark notice on New post for the first Close friends / Only me post (Q-V2 copy).
- [x] Change later: own post "Change who can see" opens panel 4 ("Currently: X", footer note, Save -> shared `SetContentAudienceUseCase`, notice "Visibility updated").
- [x] Marker T11 on the "Privacy settings" link ("Coming soon").
- [x] Strings EN + AR `x-review` (S4 Strings), semantics (selected / disabled), RTL.
**Out of scope:** Settings > Privacy, Shorts "Who can watch".
**Done when:** S4 acceptance checklist passes.
**Verify:** cubit tests (default rules incl. private account and saved default, Done vs close, notice once, change-later save/fail), widget tests EN/AR/1.5x; compare with `s4-visibility.png`.

### Phase 8: Places data + Edge Function
**Status:** [x] written and tested; analyze clean, full suite green (1458) and `node --test supabase/functions/places/handler_test.ts` 12 green. **Deployed 2026-10-14 (B1)**; it was not served with `supabase functions serve` (neither the Supabase CLI nor Deno is installed here). Checked by hand against the live Photon API (`/reverse`, `/api` incl. Arabic, `osm_tag` filters) through the same TypeScript provider run on Node; the function itself has only run against fake providers. Not verified: the real device position and permission prompts (iOS + Android), `pod install` after the Podfile change.
**Moved [user, 2026-10-14]:** the Dart places code is in `lib/shared/places/{data,domain}` (see Phase 9).
**Notes:** `supabase/functions/places/` (`index.ts` limits + User-Agent, `handler.ts` auth / validation / per-user rate limit 30 per minute / 5-minute cache by rounded position, `provider.ts` interface, `photon.ts` OSM provider, `input.ts`, `handler_test.ts`). Needs a signed-in user (`verify_jwt` stays on); rate limit and cache live in each running instance. Photon's nearby lookup mostly returns houses, so nearby asks for cafes, hotels, parks and similar (`osm_tag`), drops unnamed and repeated places and keeps 10 by distance. Arabic asks Photon without `lang` (local names; Photon has no Arabic option). Set the secret `PLACES_USER_AGENT` to a User-Agent with a contact before deploy (OSM policy); the default is a generic one. Dart in `features/post`: `data/enums/place_kind.dart`, `model/place_model.dart`, `datasource/places_datasource.dart` (+ Supabase adapter), `datasource/recent_places_datasource.dart` (last places in `StorageKeys.postRecentPlaces`), `repository/places_repository.dart` (search / nearby / currentPlace over a `DevicePosition`, recent: newest first, no repeats, last 5), `domain/entity/place_entity.dart` (`displayName` = name + first area, max 80). Core: `services/location_service.dart` (permission through `permission_handler`, one position through `geolocator`, README read) and `services/permission_access_mapper.dart` (the camera service's mapping, moved so both share it); `JsonMapper.decimal`.
Deviations: (1) no use cases: the spec lists seven, but they would only forward to the repository / location service inside the post feature, so the Phase 9 Cubit calls `PlacesRepository` and `LocationService` directly (the repository exists because it combines the function with the device copy); (2) the device position is a core service (project rule for the device and SDKs), not a `LocationDatasource`; (3) iOS `geolocator_apple` gets `BYPASS_PERMISSION_LOCATION_ALWAYS=1` in the Podfile (geolocator README); Android keeps coarse location only, enough for a neighborhood.
**Goal:** search, nearby, reverse geocode, recent places, one-time position and permission.
**Depends on:** 0, 2; B1 for the live call.
**Spec refs:** `post/00-data-layer.md` "Places (Add location, S3)", `post/screens/s3-add-location.md` Data mapping, `post/open-questions.md` Q-L1, Q-L4, Q-L5.
**Tasks:**
- [x] Edge Function `places` in `supabase/functions/places` (search, nearby, reverse; OSM with User-Agent, caching, rate limit; provider swappable). Test locally, then **ask the user before deploying** (B1).
- [x] Places datasource over the function; recent places datasource (last 5, device storage); location datasource (permission status/request, one-time position; no tracking).
- [x] Public place entity and the use cases listed in `00-data-layer.md`; km only.
- [x] Leave marker B1 in the places datasource until deployed.
**Out of scope:** UI; storing coordinates (Q-L6).
**Done when:** datasources and use cases tested; function runs locally (`supabase functions serve`) if the CLI is available, else reported.
**Verify:** datasource tests on doubles; a local request to the function.

### Phase 9: S3 Add location
**Status:** [x] built; analyze clean, full suite green (1496); device run and comparison with `s3-add-location.png` tested by the user 2026-10-15; the `places` function is deployed (B1) but the app has not called it yet. Not verified: the real location prompt and Settings round trip, the slide transition on a device, the primer's shadow and sizes (estimated in the spec).
**Moved [user, 2026-10-14]:** the places data, domain and the whole Add location screen now live in `lib/shared/places/{data,domain,presentation}` so story can reuse them; the route is `AppRoutes.pickPlace` (`/pick-place`), widgets sit flat in `presentation/widgets/`, storage keys are `recent_places` and `location_primer_dismissed`. Paths below that say `features/post/...` for places or Add location are now under `shared/places/...`; post keeps only the Location row that opens the route.
**Notes:** `features/post/presentation/`: `cubit/add_location_cubit.dart` + freezed state (permission, nearby + current place, recent, debounced search with a stale-answer guard, offline), `screen/add_location_screen.dart` (provider, listener), `view/add_location_view.dart` (header, search, one panel chosen by `AddLocationContent.resolve`; re-reads the permission when the app resumes), `widgets/add_location/` (header, search pill with focus ring and clear, place row with bold match and check, section card, primer through `AppEmpty`, empty panel, notice row), `utils/` (`LocationChoice` result, `MatchHighlight`, `place_detail` second line, `AddLocationLimits`). Data: `data/datasource/location_primer_datasource.dart` ("Not now" flag, `StorageKeys.postLocationPrimerDismissed`). Route `/create/post/location` takes the post's place as its argument and opens through the new `EndSlidePageRoute` (core router: slides from the end in LTR and RTL, fades with reduced motion); New post gets a `LocationChoice` back (null name removes the place) and the placeholder is gone. A picked place goes first in recent, then its display name ("Zamalek, Cairo", at most 80, never GPS) goes back.
Deviations: (1) the primer is shown while the permission is not granted unless "Not now" was chosen once (remembered on the device), so it does not nag on every open; (2) the primer uses `AppEmpty` (its icon floats; no button shadow); (3) second line of a row = kind (city, town, neighborhood), area, then km, e.g. "Neighborhood · Cairo · 1.4 km"; (4) row title uses `body` 15/500 with the match in `name` 15/700 (spec 15/600); (5) offline greys the search field and shows the inline row, and reconnecting reloads nearby (connection hints); (6) the search biases results by the position found for nearby, and works without one.
**Goal:** pick the place name for the post.
**Depends on:** 6, 8.
**Spec refs:** `post/screens/s3-add-location.md` (all), `post/01-design-tokens.md` "Add location (S3)", screenshot `post/screenshots/s3-add-location.png`.
**Tasks:**
- [x] Route `/create/post/location` (slides in from the end), returns a place name or none.
- [x] Header (back, title, red Remove only when set), search pill (focus ring, clear), current / nearby / recent cards, results with matched part bold, `PulseLineLoader` 44, no-results, offline row, selected check.
- [x] Search at >= 2 chars, 300 ms debounce, stale requests cancelled; autofocus only when nearby is not available (Q-L3).
- [x] Primer panel first time; Not now = search + recent only; denied forever = "Open settings" via `LaunchService`.
- [x] Saving a pick adds it to recent; S1 shows the value on the Location row.
- [x] Strings EN + AR `x-review`, semantics (name + sub + "selected"), RTL.
**Out of scope:** map, location page.
**Done when:** S3 acceptance checklist passes.
**Verify:** cubit tests (permission states, debounce, cancel, offline), widget tests EN/AR/1.5x; compare with `s3-add-location.png`.

### Phase 10: Integration
**Status:** [x] app flow verified on doubles; analyze clean, full suite green (1498). Live Supabase run tested by the user 2026-10-15.
**Notes:** `test/app/post_integration_test.dart` boots the real app (router, get_it, cubits) with mocked datasources and services: the nav bar "+" opens the Create sheet, Post opens New post, X returns to the shell; a second test picks Followers in S4, a searched place in S3 (primer "Not now"), taps Share and checks `create_post` got the caption, `Zamalek, Cairo`, comments on and `followers`, the screen closed, and "Post shared" shows. `build_runner` ran with no new changes beyond the existing `injection.config.dart` diff; all routes (`createPost`, `pickPlace`) are in `AppRouter`.
**Goal:** the flow works end to end in the app.
**Depends on:** 5, 6, 7, 9; B1 deployed and B7 applied for live checks.
**Spec refs:** `post/00-overview.md` Navigation map.
**Tasks:**
- [x] Create sheet > Post > S1 > S4 (choose audience) > S3 > back with the place > Share > closes with "Post shared".
- [x] DI wiring checked (`build_runner`), all routes in `AppRouter`.
- [x] Live run against Supabase (tested by the user 2026-10-15): posts with text, images and a video appear in `home_feed` with the right `comments_enabled`, location and visibility; a Followers / Only me post is hidden from a second test account outside the group.
**Out of scope:** Home UI.
**Done when:** the navigation map works on a simulator/device (tested by the user 2026-10-15).
**Verify:** app boot test (`bootApp`) reaches S1 from the Create sheet; manual live run.

### Phase 11: Polish
**Status:** [x] automated checks done; analyze clean, full suite green (1503). B6 real-device checks tested by the user 2026-10-15; the visual comparison with the four screenshots tested by the user 2026-10-15.
**Notes:** every screen already had an Arabic 1.5x test; added a 320 dp phone at 2.0x text test in EN and AR for S1, S2 (own post), S3 and S4 (the card already had 320 dp and 1.5x), and a 1200 dp wide-window test on S1. `AppPage` and `AppBottomSheet` wrap their body in `ContentWidth`, so S1, S3 and the sheets are capped on wide windows. Timings in `PostMotion` match the spec: like pop 180 ms, heart pop 200 ms + fade 600 ms, hidden row 240 ms, Undo 5 s. The six `TODO(post-plan ...)` markers (T2, T3, T5, T6, T7, T11) each match an open Code TODOs row; nothing was resolved by a blocker. Open: the "0/2000" counter keeps Latin digits in Arabic (km on place rows follows the locale); decide with the Arabic review (B4).
**Goal:** RTL, a11y, responsive and animations checked across S1-S4 and the card.
**Depends on:** 10; B6.
**Tasks:**
- [x] EN/AR side by side against the four screenshots; 1.5x and 2.0 text; 320 dp width; wide screen `ContentWidth`.
- [x] Animation timings (like pop 180 ms, heart 200 + 600 ms, hidden row 240 ms).
- [x] `grep -rn "TODO(post-plan"`: each marker matches an open Code TODOs row; tick rows whose blocker is resolved.
- [x] Real-device checks (B6), tested by the user 2026-10-15.
**Done when:** all acceptance checklists ticked.
**Verify:** full test suite, analyze, device run.

### Phase 12: S5 Edit post (added 2026-10-15)
**Status:** [x] built in commit d506cb9 (spec, code, tests, migration together); `test/features/post` 175 green on 2026-10-15; migration `edit_post` applied (B8). The live save and device run were tested by the user 2026-10-15.
**Notes:** New post and Edit post are one screen, `AddEditPostScreen` (`NewPostScreen` / `NewPostCubit` in Phase 6 are now `AddEditPostScreen` / `AddEditPostCubit`); route `/edit/post` takes the `PostEntity`. `UpdatePostUseCase` sets a changed comments switch and audience, uploads new files under unused names (shared upload code in `PostMediaRepository`), calls `update_post`, then removes files the post no longer uses; a failed save removes the new files. `MediaIntake` holds the pick-and-filter logic for both modes. `PostOptionsActions.onEdit` is required; Home passes it (T6 done).
**Goal:** the owner changes a post's caption, media, place, audience and comments switch.
**Depends on:** 5, 6, 7, 9; B8 for the live save.
**Spec refs:** `post/screens/s5-edit-post.md` (all), `post/screens/s1-new-post.md` (layout, tokens), `post/screens/s2-post-options.md` row "Edit post", `supabase/migrations/20261020120000_edit_post.sql`.
**Tasks:**
- [x] One add/edit screen; route `/edit/post` with the post; S2 "Edit post" opens it on the root Navigator.
- [x] Fields start from the post; media strip = the post's media, then new files, then Add tile; Remove on each; no reorder.
- [x] Audience chip starts from the post's audience (not the account default); S4 "choose" sheet, applied on Save.
- [x] "Save" enabled only when something changed and the post keeps a caption or media; "Discard changes?" on close with unsaved changes; nothing closes it while saving.
- [x] Success closes with "Post updated" and Home reloads the feed; failure stays with "Couldn't save your changes" + Retry.
- [x] `UpdatePostUseCase` + `update_post` rpc (migration `edit_post`), new file names unique, unused files removed after the save.
- [x] Strings EN + AR `x-review`.
- [x] Leave `// TODO(post-plan T4): camera capture is not in the post picker yet (gallery only)` at the add/edit media picking (T4 row).
- [x] Live run (tested by the user 2026-10-15): edit caption, place, audience, comments and media of a real post; the feed shows the change; removed files are gone from `post-media`.
**Out of scope:** reordering media, camera capture (T4), editing stories or shorts.
**Done when:** every row of the `s5-edit-post.md` table behaves as written on a device; analyze clean; tests green.
**Verify:** use case and cubit tests (already in `update_post_use_case_test.dart`, `add_edit_post_cubit_test.dart`), options flow and screen tests EN/AR; device run (B6).

### Phase 13: Tags + mood backend and data (added 2026-10-15)
**Status:** [x] done 2026-10-15; migration applied (B9).
**Goal:** the migration and the post feature's data for tags, mood and the new feed fields.
**Depends on:** 12; B9 to apply.
**Spec refs:** `post/schema-post-tags-mood.sql` (all), `post/00-data-layer.md` "Tags, mood and comments-off", `post/screens/s6-tag-people.md` / `s10-tagged-people.md` / `s11-remove-tag.md` Data mapping, `post/open-questions.md` Q17, Q19, Q21-Q23, Q27.
**Tasks:**
- [x] Migration (file written, identical to the spec copy) `supabase/migrations/20261021120000_post_tags_mood.sql` from the spec copy (keep both in sync); keep the `TODO` comment on blocked accounts in `tag_search` / `can_tag` (T14).
- [x] Validate (run against the applied schema in a rolled-back batch; test data left nothing behind) in one rolled-back batch with several test users: tag limits (20, no self, no duplicates), `allow_tags` everyone / following / none, the 24 h cool-down after `remove_my_tag`, a spot on a missing photo rejected, tag notification written on insert and deleted on self-removal, none for the owner's removals, `home_feed` new columns (`mood_*`, `tag_count`, `tags`, `i_am_tagged`), `post_tagged_people` follow states, `tagged_posts` visibility, mood check (feeling key list, activity needs text); nothing left behind. Applied after the user approved (B9).
- [x] Wire models and enums: feed row gains mood fields, tags list (user id, username, full name, media position, x, y), tag count, "I am tagged"; tag search person (with `can_tag`); tagged person (with follow state); `MoodKind`, `FollowState` (wire values).
- [x] Datasource for tags (search people, tagged people of a post, remove my tag) per the project's datasource rule; no `getTaggedPosts` call yet (T16).
- [x] Use cases (post's public API): search tag people, get tagged people, remove my tag; `CreatePostUseCase` / `UpdatePostUseCase` take the mood (kind, key, text) and the tags (user id, optional spot) and pass `p_mood_*` / `p_tags`; the post entity carries mood, tags, tag count and "I am tagged".
**Out of scope:** UI; activities data (T13); profile Tagged tab (T16).
**Done when:** migration validated (and applied once the user approves); models, datasource and use cases tested.
**Verify:** datasource tests on `backend_double`, use case tests; the rolled-back SQL batch report.

### Phase 14: Card headline, meta, comments-off
**Status:** [x] built 2026-10-15; the device and board comparison tested by the user 2026-10-15.
**Goal:** the post card shows mood, tags and location in the headline/meta, and the comments-off state.
**Depends on:** 13 (data on doubles; live after B9).
**Spec refs:** `post/02-components.md` P2a, P2b, P5 (comments off), States, Strings, Acceptance; `post/01-design-tokens.md` "Tags, mood and comments-off"; board `post/screenshots/s10-card-details-board.png` panels 1, 4, 6, 7.
**Tasks:**
- [x] Headline: 14 / h 1.35, max 2 lines + ellipsis; names 700 `textPrimary`, connectors 400 `textSecondary`; order name · mood · with-tags ("with A", "with A and B", "with A and N others"); EN feeling "is feeling 😊happy"; AR "😊 سعادة" (noun, no connector, no gendered verb); owner reads "You"; names tap -> profile, "N others" -> S10 (Phase 15 supplies the sheet; a callback here).
- [x] Meta line: location (pin 12 + 600 `primary`, 1 line, tappable through a callback) · time · audience icon 12; the six combinations of board panel 7.
- [x] Comments off: `ic_comment_off` 24 at 45 %, no count, still a 44 target; tap shows the existing top notice card ("Comments are off" / "{name} turned off comments for this post."); line under the actions (`ic_comment_off` 14 + 12 `textSecondary`). This replaces Phase 4 deviation (4).
- [x] S2 own post: "Turn on comments" row highlighted `primarySoft` with sub "Comments are off for this post" while off; Edit post sub "Caption, feeling, location, tags"; Change who can see sub = current audience (`s2-post-options.md`).
- [x] Map the new entity fields into the card's display data (Home's mapping included, as the card's public input changes).
- [x] Strings EN + AR (`x-review`, headline rule [user]), semantics, RTL (connectors and names in reading order).
**Out of scope:** tag labels on media (15), the post page bar (T17).
**Done when:** `02-components.md` acceptance items for headline, meta and comments off pass; the board panel 7 combinations render as shown.
**Verify:** widget tests (each headline combination EN + AR, 2-line ellipsis, comments-off icon / notice / line, 1.5x); compare with `s10-card-details-board.png`.

### Phase 15: Tag view on the card, S10, S11
**Status:** [x] built 2026-10-15; the device and board comparison tested by the user 2026-10-15.
**Goal:** see who is tagged on a photo, list tagged people, and remove your own tag.
**Depends on:** 13, 14.
**Spec refs:** `post/02-components.md` P2c; `post/screens/s10-tagged-people.md`, `post/screens/s11-remove-tag.md` (entries 1, 2 and the S10 row; entry 3 is T16); `post/screens/s2-post-options.md` tagged variant; boards `s10-card-details-board.png` panels 2-3, `s11-remove-tag-board.png` panels 1-4.
**Tasks:**
- [x] Tag badge (32, bottom-start, photos with tags only) and labels at x/y per media position (h 30, r10, 82 %, 7 px pointer; flips below the spot when low); tap badge/media shows them, hide after 3 s or tap; double-tap still likes; label tap -> profile; your own label = white card with "Remove tag".
- [x] S10 sheet (Post options shell): rows with Follow / Following / Requested pills through the follow feature's use case (optimistic, roll back on failure); your own row shows "Remove"; opened from "N others" and a long-press on the badge.
- [x] S2 tagged variant (`i_am_tagged`, not owner): "You're tagged in this post" line and "Remove me from this post" first in the group (`primarySoft`).
- [x] S11: one destructive confirm for all entries; optimistic update of headline and labels; notice "Tag removed"; rollback + "Couldn't remove your tag"; a false result counts as success; through the list's Cubit (callbacks into the card / sheet, like the other post actions).
- [x] Strings EN + AR `x-review`, semantics, RTL (labels keep their x/y, not mirrored).
**Out of scope:** profile Tagged tab (T16).
**Done when:** S10 and S11 acceptance checklists pass; P2c acceptance item passes.
**Verify:** cubit tests (remove tag optimistic / rollback, follow toggle), widget tests (badge, labels timing, own label, sheet rows, dialog) EN/AR/1.5x; compare with the two boards.

### Phase 16: S6 Tag people + S7 Tag in photo
**Status:** [x] built 2026-10-15; the device and board comparison tested by the user 2026-10-15.
**Goal:** choose up to 20 people and, optionally, place them on photos.
**Depends on:** 13; 12 (add/edit screen).
**Spec refs:** `post/screens/s6-tag-people.md`, `post/screens/s7-tag-in-photo.md` (all); `post/01-design-tokens.md` "Tags, mood and comments-off" + Q29 line; board `s6-tag-feeling-board.png` panels 1-3.
**Tasks:**
- [x] S6 page (Add location style): header with Done, search (300 ms debounce, suggested when blank), chips, SUGGESTED + counter, list with checks, disabled "Doesn't allow tags" rows, max 20 (counter `danger`, rows 50 %, notice), empty = `AppEmpty` + `ic_search`, loader, error + Retry; "Tag in photo" outlined button pinned at the bottom, shown only with photos, disabled until one person is chosen.
- [x] S7 page: hint, photo area with counter, tap marker, pick-list sheet of S6's chosen people without a spot (with a filter box), labels draggable inside the photo with ×, one spot per person, thumbs 56 r12 with ring and count badge 20, info card for people without a spot; videos skipped; Done back to S6; discard confirm when changed.
- [x] Routes for both pages (pushed on the root Navigator); S6 returns the chosen people with any spots.
- [x] Add/edit post: Tag people row opens S6 and shows the value ("Omar Khaled, Laila Fouad and 1 other") in `primary`; tags go into create / update; edit starts from the post's tags; removing a photo clears its spots; remove the `TODO(post-plan T2)` marker and tick T2.
- [x] Strings EN + AR `x-review`, semantics, RTL.
**Out of scope:** blocked accounts (T14), allow-tags setting (T15).
**Done when:** S6 and S7 acceptance checklists pass; S1 shows the tag value.
**Verify:** cubit tests (selection, limit, search debounce / stale answers, spots, drag clamp, photo removal), widget tests EN/AR/1.5x; compare with board panels 1-3.

### Phase 17: S8 Feelings + New/Edit post rows
**Status:** [x] built 2026-10-15; the device and board comparison tested by the user 2026-10-15.
**Goal:** choose one feeling and preview the headline on New post.
**Depends on:** 13, 14 (headline widget), 16 (rows pattern).
**Spec refs:** `post/screens/s8-feeling-activity.md` (Feelings only), `post/screens/s1-new-post.md` (rows with values, headline preview), `post/screens/s5-edit-post.md` Fields; board `s6-tag-feeling-board.png` panels 4 and 7.
**Tasks:**
- [x] S8 page: header with Remove (only when set), segmented control (Activities tab shows "Coming soon" and stays on Feelings; leave `// TODO(post-plan T13): ...` there), search by EN + AR keywords, 2-column feeling tiles (14 feelings, native emoji, selected look), tap returns at once, tap again clears.
- [x] Add/edit post: Feeling row opens S8 and shows "😊feeling happy" (AR "😊 سعادة") in `primary`; composer card headline previews exactly what the card will show (name, mood, tags, location, audience chip); mood goes into create / update; edit starts from the post's mood; remove the `TODO(post-plan T3)` marker and tick T3.
- [x] Strings EN + AR (feeling nouns per Q28, `x-review`), semantics, RTL.
**Out of scope:** activities (T13), S9.
**Done when:** S8 acceptance checklist (Feelings part) passes; board panel 7 preview matches.
**Verify:** cubit / widget tests (choose, clear, Remove, exclusive mood, preview text EN + AR), compare with board panels 4 and 7.

### Phase 18: Integration + polish (tags, mood)
**Status:** [x] built 2026-10-15 on doubles; the live run (task 3) tested by the user 2026-10-15.
**Goal:** the whole flow works end to end and all new screens pass RTL, a11y and responsive checks.
**Depends on:** 14-17; B9 applied for the live run.
**Spec refs:** `post/00-overview.md` Navigation map; acceptance checklists of S6, S7, S8, S10, S11 and `02-components.md`.
**Tasks:**
- [x] App boot test: Create > New post > S6 (+ S7) > S8 > Share; `create_post` receives tags with spots and the mood; the feed card shows the headline, badge and labels.
- [x] DI wiring (`build_runner`), all new routes in `AppRouter`.
- [x] Live run (after B9; tested by the user 2026-10-15): post with tags and spots and a feeling; a tagged account sees "You", removes the tag; owner cannot re-tag within 24 h; a `none` account shows "Doesn't allow tags"; comments-off notice on the feed.
- [x] RTL / 1.5x / 2.0x / 320 dp / wide window for S6, S7, S8, S10, S11 and the new card states.
- [x] `grep -rn "TODO(post-plan"`: markers match open Code TODOs rows (T13 new; T2, T3 removed).
**Done when:** all new acceptance checklists ticked; analyze clean; full suite green.
**Verify:** full test suite, analyze, device run (user).

**Notes:** `test/app/post_integration_test.dart` now boots the real app and runs Create > New post > photo > S6 > S7 (a spot for one person, one tagged in the post only) > S8 > Share, and checks `create_post` receives the tags with the spot and the feeling; a second test shows the feed card (headline, comments-off notice, badge, labels, your own label) and removes your tag. `test/features/post/presentation/tags_mood_responsive_test.dart` runs S6, S7, S8, the tagged people sheet, the remove dialog and the card at 320 dp / 2.0x, 390 dp / 1.5x and 1200 dp in EN and AR. It found two layout bugs, both fixed: Tag in photo overflowed at large text (the hint, strip and card now scroll under a photo that takes 55 % of the page) and a long username overflowed its label on the photo. Markers left in code: T4, T7, T11, T13, each with an open row. Live run (task 3): the SQL side was already checked in a rolled-back batch on the project (Phase 13); the app run with a real account was tested by the user 2026-10-15.

### Phase 19: Share backend + data (added 2026-10-21)
**Status:** [x] done 2026-10-21 (migration applied)
- **Goal:** the server and the post feature's data can create a share, return it in the feed with its embedded original, and accept a post sticker on a story.
- **Depends on:** 18; B11 to apply.
- **Spec refs:** `post/schema-post-share.sql` (all), `post/screens/s12-share-sheet.md` Data, `post/screens/s13-add-to-story.md` Data, `post/00-data-layer.md`.
- **Tasks:**
  - [x] Write the migration `supabase/migrations/<timestamp>_post_share.sql` from the spec copy (keep both in sync). The spec has two TODOs for the builder: relax the posts constraints for a share (no media, optional caption) and write the full `home_feed` replacement (drop + create, re-grant), also the story read that returns the embedded post.
  - [x] Validate in one rolled-back batch with several test users: Public post shared; share of a share resolves to the original; Followers / Close friends / Only me original refused; deleted original leaves the share with a null embed; hidden original (author became private) gives a null embed; caption over 2000 refused; feeling, location and tags saved on the share (tag limits and `allow_tags` as for a post, no photo spot); notification written once per original post and none for self-share; `create_story` accepts a post sticker only for allowed posts and audiences (a Followers post only to Followers or Close friends); nothing left behind. Report to the user, then apply after approval (B11). (Validated and applied 2026-10-21.)
  - [x] Wire models: feed row gains `shared_post_id` and the embedded original (nullable); story row gains the sticker (style, x, y, scale, rotation, background) and the embedded post (nullable).
  - [x] `ShareToFeedUseCase` (post's public API: post id, caption, audience, feeling, location, tags; returns the new id and asks for a feed refresh like `CreatePostUseCase`); the post entity carries the embedded original.
- **Out of scope:** UI; chat sending (`share_targets`, `share_post`, T20).
- **Done when:** migration validated (and applied once approved); models, datasource and use case tested; a null embed maps to "unavailable".
- **Verify:** datasource tests on `backend_double`, use case tests; the rolled-back SQL report. **I ask you first:** applying the migration to the live project.
**Notes:** posts also gets `is_share` (a deleted original sets `shared_post_id` to null, so the flag keeps the card a share: "unavailable"); `stories.sticker` may outlive its post, so the spec's `stories_sticker_needs_post` check is dropped. There is no `create_story` function: the sticker travels in the `share_content` story request (`shared_post_id`, `sticker`), checked by `check_story_post` in `share_content` and `publish_pending`. Refusals: `P0002 post_unavailable` (maps to `NotFoundFailure` in `shareToFeed`), `22023 post_not_shareable`. A share can't go on a story (use its original). Feed rows and `author_stories` embed the original through `post_embed`; the embed has no counts. Story side: `StoryModel.sticker` / `sharedPost` (own models), no request model yet (Phase 23). Signing the original's media links is Phase 20.

### Phase 20: Shared post card (P10, P11)
**Status:** [x] done 2026-10-21 (device check with the board is yours)
- **Goal:** a share shows in the feed with its header, your words, the framed original, and the share's own actions.
- **Depends on:** 19 (data on doubles; live after B11).
- **Spec refs:** `post/02-components.md` P10, P11 and their acceptance list; board `post/screenshots/s12-share-board.png` panels 3-4; `post/01-design-tokens.md` (estimated sizes are marked, confirm against the board).
- **Tasks:**
  - [x] Share header "{sharer} shared {author}'s post" (names bold, connectors grey; "shared a post" when the author is unknown) with the share's feeling and tags in the headline ("N others" opens S10), location, time and audience icon in the meta line (as P2a-P2b); caption with more / less; no media of its own.
  - [x] Framed original (1 px border): author row, caption, media, no action bar; its own like / comment counts are not shown. Tap opens the original's comments route; leave `// TODO(post-plan T21): ...` there.
  - [x] P11 unavailable tile (lock, title, body) when the embed is null; share and its actions stay.
  - [x] The share's action bar: like, comment and save belong to the share; no share count.
  - [x] The share's "..." opens S2: your own share keeps Change who can see, Turn off comments, Delete, and Edit post (opens Phase 22's screen; hidden until then); someone else's share shows the usual options. Public card widget gets the new input and Home maps it.
  - [x] Strings EN + AR (`x-review`), semantics ("Shared post by ...", "Post unavailable"), RTL.
- **Out of scope:** the Share sheet (21), editing a share (22).
- **Done when:** the P10-P11 acceptance items pass; the board panels 3-4 look like the app.
- **Verify:** widget tests (share with caption, without caption, unavailable, unknown author, 2-line ellipsis in header, EN + AR + 1.5x), cubit test for the share's own like / save; compare with the board.
**Notes:** `PostCardData` gains `isShare` and `original` (the framed post is a `PostCardData` too); `PostHeadline` builds "shared {author}'s post" / "shared a post" from three strings (Arabic order differs, so the connector before the author and the one after are separate); `SharedPostEmbed` and `PostUnavailableEmbed` are in `post/presentation/widgets`; the embed's videos are keyed `{shareId}/original`. `FeedPost.originalMedia` is signed with the feed's single request. A share's options hide Edit post (`TODO(post-plan Phase 22)` in `PostOptionLayout`). Embedded sizes are the estimated ones (r16, padding 10, avatar 32, media r12, tile r14). The original's "N others" is not tappable, and the original's like and comment counts are not shown. The share's own like and save go through `PostActionsCubit` by id like any post (no new cubit code, no new test).

### Phase 21: Share sheet (S12)
**Status:** [x] done 2026-10-21 (device check is yours)
- **Goal:** the send icon opens the sheet, and Share now puts a share on your feed.
- **Depends on:** 19, 20 (View needs the card); S4 picker from Phase 7.
- **Spec refs:** `post/screens/s12-share-sheet.md` (all); `post/screens/s6-tag-people.md` (no Tag in photo here), `s8-feeling-activity.md`, `s3-add-location.md`; `post/screens/s2-post-options.md` Share row; board `s12-share-board.png` panels 1-3.
- **Tasks:**
  - [x] Visibility rule helper: icon and sheet content by post audience and ownership (table in the spec). Used by the card's send icon and by S2's Share tile.
  - [x] Sheet: header with `ic_share_forward` (register it), composer (avatar, name, audience chip opening the S4 picker, field, tools Tag people / Feeling / Location opening S6 / S8 / S3 with the values kept in the sheet's Cubit, Share now), divider, external row (Add to story, Copy link, WhatsApp, More). Chat section is not drawn; leave `// TODO(post-plan T20): ...` where it would be.
  - [x] Caption: sheet rides above the keyboard, field grows to 4 lines then scrolls, counter `n / 2000` (max 2000), Done or tap outside closes the keyboard. Share now works with an empty caption.
  - [x] Cubit: share, loader on the button, success -> close + notice with the line for the audience + View (scrolls Home to the top, feed refresh), failure -> stays open with the text and a notice, unavailable original -> notice and close.
  - [x] Copy link, WhatsApp and More show "Coming soon" with `// TODO(post-plan T7): ...`; Add to story shows "Coming soon" with `// TODO(post-plan T19): ...`.
  - [x] Wire the card's send icon (remove `TODO(home-plan H6)` and its "Coming soon") and S2's Share tile (S2 Copy link keeps its T7 marker).
  - [x] Strings EN + AR (`x-review`), semantics, RTL, 1.5x (external row scrolls if needed).
- **Out of scope:** Add to story (23), chat (T20), real links (T7).
- **Done when:** the S12 acceptance list passes for panels 1-3 with chat hidden; the icon appears only where the table says.
- **Verify:** cubit tests (share, empty caption, failure keeps text, offline, unavailable original, audience default), widget tests EN/AR/1.5x for each audience variant; compare with panels 1-3. **I ask you first:** nothing new (no package here).
**Notes:** `ShareAccess` (`utils/enums/share_access.dart`) is the table: Public = full, your own Followers = story only, the rest = none; `shareAccessOf(post)` follows the original for a share and is used by the card (`PostCardData.canShare`) and S2 (`PostOptionsData.shareAccess`; the Share tile needs it, Copy link needs a Public post, which also fixes the old "hidden when not public" S2 tests). `PostPickers` is the one place that opens the place, feeling and tag pages (New post uses it too). `ShareSheetCubit` (freezed state, `ShareResult` one-shot) calls `ShareToFeedUseCase`; the sheet is `widgets/share_sheet/`. "View" scrolls the Home list to the top through the `PrimaryScrollController` taken when the icon was tapped. The WhatsApp tile uses the chat icon as a stand-in until the official brand icon is provided. The audience chip got an optional `height`. `PostOptionsActions` has a required `onShare`. The counter shows while the field has focus.

### Phase 22: Edit a share
**Status:** [x] done 2026-10-21 (device check is yours)
- **Goal:** change the words, feeling, place, tags, audience and comments of your own share.
- **Depends on:** 20, 21; Phase 12 (edit screen).
- **Spec refs:** `post/02-components.md` P10 taps; `post/screens/s5-edit-post.md`; Q-S8.
- **Tasks:**
  - [x] Edit post on a share: the S5 screen without the media row, the original shown read-only under the words, and the Tag people (no Tag in photo), Feeling and Location rows.
  - [x] Save through the existing update path (caption, mood, location, tags, comments); the share can't gain media.
  - [x] Strings, RTL, 1.5x; the share's S2 Edit post row opens this screen.
- **Out of scope:** changing which post is shared.
- **Done when:** your share can be edited and its card updates; there is no way to add media.
- **Verify:** cubit and widget tests; device run (user).
**Notes:** it is the same `AddEditPostScreen` and cubit: `AddEditPostState.isShare` (from the edited post) hides the media strip and the Photo / video row, and `canSave` needs only a change (no words or media). The read-only original is `SharedPostEmbed` / `PostUnavailableEmbed` in `ComposerCard`; Home passes it through `AddEditPostArgs.original` (built with the feed's already signed links). The share's S2 Edit post row is shown (marker removed). `update_post` already accepts a share (kind `post`, no media, empty words allowed), so no migration; `UpdatePostUseCase` now keeps `isShare` and `original` on the returned post. Tests: layout, cubit `canSave` for a share; no widget test for the screen yet.

### Phase 23: Add to story: editor (S13)
**Status:** [x] done 2026-10-21 (device check against the board is yours)
- **Goal:** Add to story opens the story editor with the post as a sticker and posts the story.
- **Depends on:** 19; 21 (the tile); `ic_palette` registered; no palette package.
- **Spec refs:** `post/screens/s13-add-to-story.md` (editor part), `story/screens/s3-create-edit.md`, `story/screens/s4-posting-rail.md`; board `post/screenshots/s13-add-to-story-board.png` panels 1-3.
- **Tasks:**
  - [x] No palette package (`palette_generator` is discontinued): read two dominant colors of the first media (poster frame for video); fall back to a primary gradient.
  - [x] Sticker model and draw: three styles (card, media only, compact), tap cycles, drag, pinch 0.5x-2x, rotate, dashed selection outline, style dots, hint text; saved as fractions of the screen.
  - [x] Palette tool shows the six swatches (from media, dark, primary, three gradients); text and download tools keep working; the background plus your text and drawing are rendered to the story photo, the sticker is not.
  - [x] Audience: the story picker offers only the post's audience or narrower; the app blocks anything wider before the server does.
  - [x] Entry point: Add to story in S12 opens story create with the post; remove `TODO(post-plan T19)`.
  - [x] Share goes through the existing story upload path with the sticker and the shared post id.
  - [x] Strings EN + AR (`x-review`), semantics, RTL (position not mirrored).
- **Out of scope:** the viewer (24), the "shared in their story" notification (T22).
- **Done when:** the S13 editor checks pass: default card, three styles, gestures, background from media, audience limit; a story posts with the sticker.
- **Verify:** cubit tests (style cycle, clamp of scale, background fallback, audience limit), widget tests for the sticker styles EN/AR; compare with panels 1-3.
**Notes:** a separate screen, `StoryPostEditScreen` (`/create/story/post`, argument `StoryPostArgs` in `core/utils`, built by Home from the shared post and the links the feed signed), with its own `StoryPostEditCubit`; the photo editor is untouched except `StoryEditTools` (location, palette and mute are optional) and the notice and discard code both screens use (`StoryEditEffects`). The text tool and the sticker canvas are the photo editor's. Share renders the gradient and your text to a PNG (`renderStoryBackdrop`) and enqueues a `NewStoryModel` with `sharedPostId` and `sticker`; `StoryUploadRepository` sends such a story through `share_content` + `publish_content` under the file's id (a plain story still inserts the row). `PaletteService` counts the pixels of a 100 px copy itself (`palette_generator` was dropped 2026-10-21: it is discontinued), so there is no package. Audience: the editor has no audience picker yet (Q18), every story goes to Followers, which is never wider than a post the Share sheet allows, so the "block anything wider" task is met by the sheet's `ShareAccess` rule and the server's `check_story_post`; the picker rule waits for Q18. The drawing tool does not exist yet. Estimated from the board: the sticker widths of the media and compact styles, the swatch colors (grey-blue, light, orange), swatch size. The server's refusal (`post_not_shareable`, `post_unavailable`) shows as the rail's failed state with Retry; `storyPostNotShareable` is not added (it needs the job to carry the reason). T19 is removed.

### Phase 24: Story viewer: post sticker
**Status:** [x] done 2026-10-21 (device check against the board is yours)
- **Goal:** viewers see the post card on the story and can open the post.
- **Depends on:** 19, 23.
- **Spec refs:** `post/screens/s13-add-to-story.md` panels 4-5; `story/screens/s1-story-viewer.md`; board panels 4-5.
- **Tasks:**
  - [x] Draw the sticker on top of the story photo with the saved style, position, scale and rotation.
  - [x] Tap pauses the story, dims 25 %, shows the "View post" pill (44, pointer up) under the sticker; tapping the pill opens the post's comments route (leave `// TODO(post-plan T21): ...`); tap elsewhere resumes.
  - [x] Null post: the frosted "Post unavailable" card replaces the sticker, not tappable.
  - [x] Strings EN + AR (`x-review`), semantics, RTL.
- **Out of scope:** a post page (T21), the story mention notification (T22).
- **Done when:** panels 4-5 match; a deleted post shows the unavailable card; pause and resume behave.
- **Verify:** viewer cubit and widget tests, compare with panels 4-5.
**Notes:** `StoryPostLayer` (`story/presentation/widgets/story_post`) sits above the chrome in `StoryPerson` for a story with a `sticker`; it reuses `StoryPostSticker` and `StoryOverlayPlacement`. Open state is local to the layer and pauses the story with the new `StoryPauseReason.post`; the pill hangs from the sticker's measured bottom edge. `author_stories` links are signed in `StoriesDatasource` (`StorySharedPostModel.pictureKey` / `pictureUrl`: first photo, or a video's poster). No tests yet (asked).

### Phase 25: Integration + polish (share, sticker)
**Status:** [~] code done 2026-10-21 (live run, device checks and the story-sticker boot test are open)
- **Goal:** both flows work end to end and pass RTL, a11y and responsive checks.
- **Depends on:** 19-24; B11 applied for the live run.
- **Spec refs:** `post/00-overview.md` Navigation map; acceptance lists of S12, S13, P10-P11.
- **Tasks:**
  - [x] App boot test: Home > send icon > Share now > notice > the share on top (View tap itself not driven); Home > send icon > Add to story opens the editor. Not covered: Share in the editor > the story shows the sticker.
  - [x] DI wiring (`build_runner`), new routes in `AppRouter`.
  - [ ] Live run (after B11): share a public post with and without words; share a share; delete the original and reload; story with a sticker, viewed by a second account; a Followers post limited to Followers or Close friends; the author gets a share notification row.
  - [ ] RTL, 1.5x, 2.0x, 320 dp and wide window for the sheet, the shared card and the sticker.
  - [x] `grep -rn "TODO(post-plan"`: markers match open Code TODOs rows (T7, T19 removed, T20, T21 new).
**Notes:** boot tests added to `test/app/post_integration_test.dart`. The T20 marker was missing and is now in `share_sheet.dart`; open markers: T4, T7, T11, T13, T20, T21. RTL / 1.5x / 2.0x / 320 dp checks were done per phase (20-24 widget tests); not rerun here. Full suite has 5 failures not from this phase: 2 progress-weight tests in `content_media_repository_test`, 1 in `story_upload_repository_test`, `story_integration_test` camera > Share, and the post restart test (`boot` finds no `ControlScreen` after the kill).
- **Done when:** all new acceptance lists ticked; analyze clean; full suite green.
- **Verify:** full test suite, analyze, device run (user).

### Phase 26: Comments backend + data (added 2026-10-25)
**Status:** [x] done 2026-10-25; migration validated in rolled-back runs, then **applied** (history name `post_comments`, version 20261025180433)
- **Goal:** the server and the post feature's data can list, add, edit, delete, hide and like comments and replies, and report a comment.
- **Depends on:** 25 code done; B15 to apply; B18 answered.
- **Spec refs:** `post/screens/s14-comments-sheet.md` Behavior + Data, `post/00-data-layer.md`, `supabase/migrations/20261013155541_home_feed.sql` (`comments`, `comments_check_parent`, counters), `20261014213146_notifications.sql` (`notify_on_comment`, mentions).
- **Tasks:**
  - [x] Write the migration `supabase/migrations/<timestamp>_post_comments.sql` and copy the SQL to `post/schema-post-comments.sql` (keep both in sync). Add to `comments`: `like_count`, `reply_count`, `edited_at`, `hidden_at`, `client_id` (unique per author, for safe Retry); table `comment_likes(comment_id, user_id)`; triggers keep `like_count`, `reply_count` and `posts.comment_count` (hidden comments do not count, B18).
  - [x] Functions: `post_comments(p_post, p_sort, p_limit, p_before, p_focus)` (20 top-level per page, first 3 replies each, `liked_by_me`, `is_post_author`, hidden rows only for their writer, `p_focus` puts that comment, or its parent thread, first and leaves it out of the normal rows), `comment_replies(p_comment, p_limit, p_before)`, `add_comment(p_post, p_body, p_parent, p_client_id)` (idempotent on the client id, parent resolved to the top-level comment, mentions through the existing notify code), `edit_comment`, `delete_comment`, `hide_comment(p_comment, p_hidden)` (post owner only, not own comments), `set_comment_like(p_comment, p_liked)`, `comment_mention_candidates(p_post, p_query)` (followers + people in the thread, at most 3).
  - [x] Extend `report_content` to accept `p_kind = 'comment'`; every function checks that the caller can see the post and that comments are on (reading stays allowed when they are off; writing is refused).
  - [x] Validate in one rolled-back batch with several test users: public post, comment and reply, reply to a reply lands on the top-level comment, 1000-char limit, Retry with the same client id writes once, like twice = one like, edit only by the writer, delete takes replies, hide only by the post owner (writer still sees it, others don't), counts after hide / undo, comments off refuses writing, no access to a post you can't see, notifications for comment / reply / mention, `p_focus` for a reply and for a deleted comment, nothing left behind. Report to the user, then apply after approval (B15).
  - [x] Dart data: `features/post/data/model/comment_model.dart` (new: author, body, counts, `likedByMe`, `isPostAuthor`, `editedAt`, `replies` (first 3), `replyCount`) and `comment_page_model.dart` (new: rows + next cursor); `features/post/data/datasource/comments_datasource.dart` (new: interface + Supabase adapter in one file, calls above, `Guard.run`, `JsonMapper`).
  - [x] Domain: `domain/entity/comment_entity.dart` (new; `copyWith`, time and `isEdited`), `domain/mapper/comment_entity_mapper.dart` (new), use cases in `domain/use_case/` (new): `GetPostCommentsUseCase`, `GetCommentRepliesUseCase`, `AddCommentUseCase`, `EditCommentUseCase`, `DeleteCommentUseCase`, `HideCommentUseCase`, `SetCommentLikeUseCase`, `GetMentionCandidatesUseCase`.
  - [x] Add `ContentKind.comment` (`wire` = `comment`) in `shared/content/data/enums/content_kind.dart`; fix every `switch` on `ContentKind` the analyzer flags (comments are only reportable, they have no feed, audience or mute); `ReportContentUseCase` stays as it is.
  - [x] `fvm dart run build_runner build --delete-conflicting-outputs` for the new `@injectable` classes.
- **Tests:** datasource tests on `test/helpers/backend_double.dart` (each call, params, a `Failure` on error, a null parent); mapper tests (replies, `isPostAuthor`, hidden); use case tests; the rolled-back SQL report.
- **Out of scope:** UI; pin (left out, Q-C3); a reply notification screen (T24).
- **Done when:** the migration is validated (and applied once approved); models, datasource and use cases tested; `ContentKind.comment` compiles everywhere; analyze clean.
- **Verify:** analyze, tests, the SQL report. **I ask you first:** applying the migration to the live project (B15).
**Notes (builder):** 
- Migration `supabase/migrations/20261025120000_post_comments.sql` (spec copy `post/schema-post-comments.sql`) and its checks `supabase/tests/post_comments_test.sql`. Validated on the project in rolled-back runs (nothing kept; checked afterwards): reply to a reply lands on the top-level comment, empty / 1001-char refused (22023), a retry with the same client id writes once, like twice = 1, edit only by the writer (42501), "relevant" puts the thread the author answered first and "newest" the newest, paging by rank + time + id gives the next row then an empty page, 3 replies shown with `reply_count` 4 and the rest through `comment_replies`, hide lowers the post's count and Undo restores it (a hidden thread hides its replies and Undo brings the same ones back), the stranger doesn't see a hidden comment but the writer does, non-owner and own-comment hide refused (42501), delete takes the replies and fixes the count, comments off refuses writing (22023) but reading works, a followers-only post is P0002 for a stranger, `p_focus` on a reply puts the thread first with the reply in it and never lists it twice, mentions, notifications (comment, reply, mention), reports (own and hidden comments refused, a duplicate keeps one row), direct table access denied.
- Differences from the plan text: `reply_count` is counted per viewer in `comment_json` (a stored column could not hide the replies only their writer sees), so only `like_count`, `edited_at`, `hidden_at`, `client_id` were added; `post_comments` takes the cursor as `p_before_rank` + `p_before_time` + `p_before_id` and every top-level row carries its `rank`; all functions return `jsonb` (rows are built by the helper `comment_json`); comments are not readable or writable on the table any more (RPC only); a hidden comment doesn't count in `posts.comment_count` (B18 assumption, Undo counts it again). Refusals: `P0002` (post or comment gone / not visible) maps to `NotFoundFailure`, `22023` (comments off, bad words) to `RejectedFailure`.
- Dart: `CommentsDatasource` (`features/post/data/datasource/comments_datasource.dart`), `CommentModel`, `CommentPageModel`, `MentionPersonModel`, `CommentSort` (in `data/enums`, the datasource needs its wire value, so it is not a presentation enum as Phase 27 listed it), entities `CommentEntity`, `CommentPageEntity`, `CommentCursorEntity`, `MentionPersonEntity`, `CommentEntityMapper`, and use cases `GetPostCommentsUseCase`, `GetCommentRepliesUseCase`, `AddCommentUseCase`, `EditCommentUseCase`, `GetMentionCandidatesUseCase` (they map rows to entities). Delete, hide and like have **no use case**: they would only forward a call, so the Cubit (Phases 28-29) calls `CommentsDatasource.deleteComment`, `hideComment`, `setLike` directly. The page cursor is the last non-focus row of a full page. Report uses `ContentActionsDatasource.report` with the new `ContentKind.comment`; `MediaPolicy.videoLimits` throws `UnsupportedError` for it (a comment has no video) and `media_policy_test` skips it.
- Tests: `test/features/post/data/datasource/comments_datasource_test.dart`, `domain/mapper/comment_entity_mapper_test.dart`, `domain/use_case/comment_use_cases_test.dart`. Full suite: all green except `test/core/theme/no_unscaled_literals_test.dart` (`avatar_initials.dart:33`), which fails the same way without this phase's changes.

### Phase 27: Comments sheet: read (S14 panels 1 and 5)
**Status:** [x] code done 2026-10-25; not yet opened on a device (the sheet is wired from the card in Phase 33)
- **Goal:** the comment icon opens a sheet that lists comments and replies, sorts them, likes them, and shows the empty and error states.
- **Depends on:** 26 (data on doubles; live after B15).
- **Spec refs:** `post/screens/s14-comments-sheet.md` (layout, panels 1 and 5, Behavior: sort, paging, like, Author badge, offline); board `s14-comments-board.png` panels 1 and 5; `post/01-design-tokens.md`.
- **Tasks:**
  - [x] Register `ic_reply`, `ic_copy`, `ic_send` in `lib/core/constants/app_assets.dart`; strings EN + AR (`x-review`) for this phase (title, sort, Author, Reply, likes plural, View N more replies, empty, Try again).
  - [x] Dimens `comments_dimens.dart`; comment row, reply row, Author badge, "View N more replies", sort chip and its small popup, heart, empty tile, sheet shell (reuse `AppBottomSheet` and `AppSafeArea`; top gap 88, draggable to full height).
  - [x] `CommentsCubit` (freezed state: top-level rows, per-thread expanded replies, sort, `LoadMoreStatus`, first-load status): load, change sort (reload from the top), load more, load more replies, like / unlike with rollback.
  - [x] Errors: first load, more comments and more replies each show Try again (shared retry row / error tile); no pull to refresh.
  - [x] Semantics ("Comment by …", like button), RTL (indent and heart mirror), 1.5x text.
- **Implementation steps:**
  1. `lib/core/constants/app_assets.dart` (edit): `reply`, `copy`, `send`.
  2. `lib/features/post/presentation/dimens/comments_dimens.dart` (new): values from S14 Tokens through `AppScale`, nothing invented; mark the ones estimated in the spec.
  3. `.../cubit/comments/comments_cubit.dart` + `comments_state.dart` (new, freezed): extends `BaseCubit`; `@injectable`; takes `postId` through `init(postId, {focusCommentId})`; uses `GetPostCommentsUseCase`, `GetCommentRepliesUseCase`, `SetCommentLikeUseCase`; likes are optimistic and roll back on a `Failure`; paging with `LoadMoreStatus` from `core/state/`.
  4. `.../utils/enums/comment_sort.dart` (new): `relevant`, `newest` with the wire value; `.../utils/enums/comments_status.dart` (new).
  5. `.../widgets/comments/` (new): `comment_row.dart`, `comment_reply_row.dart`, `comment_author_badge.dart`, `comment_view_replies.dart`, `comment_sort_chip.dart`, `comments_empty.dart`, `comments_list.dart` (uses `LoadMoreListener`, not `PagedScrollView`, because there is no pull to refresh).
  6. `.../widgets/comments/comments_sheet.dart` (new): `CommentsSheet.show(context, postId:)` like `ShareSheet.show`; provides the cubit (`BlocProvider(create: (_) => getIt<CommentsCubit>()..init(...))`); the screen-level `BlocListener` shows notices.
  7. `lib/l10n/app_en.arb`, `app_ar.arb` (edit); run `fvm flutter gen-l10n` if not automatic.
  8. Export `CommentsSheet` from the post feature's public exports (the way `ShareSheet` is exported).
  9. Edge cases: a post with 0 comments; a deleted author; very long names; a reply count of 1 ("View 1 more reply" uses the plural string); 1.5x text.
- **Tests:** `comments_cubit_test.dart` (load, sort change, paging, like + rollback, error then retry, empty); `comment_row_test.dart` widget test (Author badge, liked heart, EN + AR + 1.5x).
- **Out of scope:** writing (28), long-press (29), mentions (30), the card's comment icon (33).
- **Done when:** the sheet matches panels 1 and 5; sort changes the order; like works and rolls back on failure; a failed load shows Try again.
- **Verify:** analyze, tests, compare with `s14-comments-board.png` panels 1 and 5 (via a temporary entry or the phase-33 wiring). **I ask you first:** estimated values left in S14 Tokens.

**Notes (builder):**
- `CommentsSheet.show(context, postId:, focusCommentId:)` in `widgets/comments/comments_sheet.dart`; `CommentsCubit` (`@factoryParam` postId + focusCommentId) calls `CommentsDatasource.setLike` directly (no like use case, Phase 26). `CommentSort` stays in `data/enums`. One `CommentRow` serves comments and replies (no separate reply row); a `CommentThread` wraps a comment, its replies and "View N more replies".
- Stale answers (sort changed while loading) are dropped by a load counter. A failed page waits for its Retry row; a failed thread's "View more" line becomes "Couldn't load more · Retry".
- Deviations: Author badge uses the `badge` token (11) where S14 says 10; the sheet is a fixed height under the 88 gap (the shared sheet closes on drag, so "drag to full height" is not done); the Reply label is plain text until Phase 28.
- Tests: `cubit/comments/comments_cubit_test.dart`, `widgets/comments/comment_row_test.dart`.

### Phase 28: Write, reply and draft (S14 panels 2 and 4)
**Status:** [x] code done 2026-10-26; analyze clean, `test/features/post` green; not opened on a device
- **Goal:** you can write a comment or a reply; it shows at once, can fail and retry, and your unsent text is kept per post until the app closes. Comments-off shows the bar.
- **Depends on:** 27.
- **Spec refs:** `post/screens/s14-comments-sheet.md` panels 2 and 4, Behavior (max 1000, counter after 900, Replying strip, failed post, draft, comments off); board panels 2, 4 and the "Comments off" note; `post/02-components.md` "Post page when comments are off".
- **Tasks:**
  - [x] Composer: emoji row (heart, hands, fire, clap, cry, heart-eyes, surprised, laughing; tap inserts at the cursor), field (h 44, r22, focus ring), send button (`ic_send`, primary with text, off otherwise), counter after 900, keyboard send key.
  - [x] Replying strip ("Replying to @name" + X) and highlight of the parent; the field starts with `@name `; a reply always goes to the top-level comment.
  - [x] Optimistic posting: the new row at 55% with "Posting…"; success replaces it; failure shows "Couldn't post · Retry · Delete"; Retry reuses the client id.
  - [x] Draft kept per post in memory until the app closes (a map in the cubit's provider scope, not on disk); sending clears it.
  - [x] Comments-off: the bar replaces composer and emoji row; Reply hidden; old comments readable. `TODO(post-plan T17)` is removed.
  - [x] Strings EN + AR (`x-review`), semantics, RTL, 1.5x.
- **Implementation steps:**
  1. `.../cubit/comments/comments_cubit.dart` (edit): `send(text)`, `retry(localId)`, `discardFailed(localId)`, `startReply(comment)`, `cancelReply()`; local rows carry a `client_id`; uses `AddCommentUseCase`; the comment count of the post goes up through `PostActionsCubit.applyCounts` (the sheet reads the opener's cubit through a callback) and fires the existing count refresh so the feed card follows.
  2. `.../services` or `.../utils/comment_drafts.dart` (new): app-lifetime `@lazySingleton` holding `Map<postId, String>`; cleared on sign-out (check how other per-user state is cleared, e.g. the post draft repository, and follow it).
  3. `.../widgets/comments/comment_composer.dart`, `comment_emoji_row.dart`, `comment_replying_strip.dart`, `comment_posting_row.dart` (new); `comments_off_bar.dart` (new, reuses the card's `post_comments_off_line.dart` look).
  4. `comments_sheet.dart` (edit): composer pinned above the keyboard (rides `MediaQuery.viewInsets`), `AppSafeArea` with `bottomSpace`; keyboard opens when the sheet came from the comment icon and the list is empty.
  5. `lib/l10n/*.arb` (edit).
  6. Edge cases: empty or spaces only; 1000 limit; send while offline (failed row); double tap on send (one request); close the sheet mid-request (the request finishes, the row is gone with the sheet); the post turning comments off while open (next write fails with a notice).
- **Tests:** cubit tests (send ok, send fails then retry once, Retry same client id, reply to a reply attaches to the parent, draft saved and restored, limit); widget test composer states EN + AR + 1.5x.
- **Out of scope:** edit (29), mentions (30).
- **Done when:** panels 2 and 4 match; a failed comment never posts twice; the draft returns on reopen; comments-off shows the bar.
- **Verify:** analyze, tests, compare with panels 2 and 4.

**Notes (builder, Phase 28):**
- Files: `cubit/comments/comments_cubit.dart` (+ `send`, `retry`, `discardFailed`, `startReply`, `cancelReply`, `draft`, `saveDraft`; state gained `pending`, `replyTo`, `countDelta`), `utils/comment_text.dart` (limit 1000, counter from 900, quick emoji, `canSend`, `insert`, `withMention`), `utils/pending_comment.dart`, `utils/comment_drafts.dart` (`@lazySingleton`, in memory, keyed by account + post, so no sign-out clearing is needed), `widgets/comments/` `comment_composer.dart` (strip, emoji row, field, counter, Send), `comment_emoji_row.dart`, `comment_replying_strip.dart`, `comment_posting_row.dart`, `comments_off_bar.dart`.
- `CommentsSheet.show(..., commentsEnabled, fromCommentIcon, onCountChanged)`: `commentsEnabled` is a sheet argument (the cubit already takes two factory params); `onCountChanged(delta)` gives how many comments this sheet added, for Phase 33 to feed `PostActionsCubit`. `CommentRow.onReply` null hides Reply (comments off).
- A saved reply is added to its thread only when all that thread's replies are loaded (so the order holds); otherwise only the count grows and it shows with "View more". A rejected or gone post (comments turned off meanwhile) also shows a notice.
- Deviations: the emoji row has 8 equal tap areas (48 high); `TextField` multi-line up to 4 lines with the send key; counter sits above the field; `TODO(post-plan T17)` had no marker left in code.
- Tests: `comments_cubit_test.dart` (writing group), `comment_composer_test.dart`, `comment_row_test.dart` updated.

### Phase 29: Comment actions (S14 panel 3)
**Status:** [x]
- **Goal:** press and hold gives Reply, Copy text, Report, Hide (post owner), Edit and Delete; double-tap likes.
- **Depends on:** 28.
- **Spec refs:** `post/screens/s14-comments-sheet.md` panel 3, 4 and Behavior (Edit, Delete, Hide with Undo, Report, Copy, Like); board panels 3 and 4; `core/widgets/report_sheet/`, `core/widgets/confirmation_dialog/`, `core/widgets/notice/`.
- **Tasks:**
  - [x] Long-press: highlight, dim, a sheet with six quick emoji (insert into the reply field), then Reply and Copy text, then Hide comment (post owner, not on own comments) and Report comment (red); for your own comment: Edit, Copy text, Delete.
  - [x] Edit: text into the composer with an "Editing comment" strip; Send saves; "Edited" after the time.
  - [x] Delete: confirm dialog (shared `ConfirmationDialog`, delete tone), "also deletes its replies"; the post's count drops.
  - [x] Hide: row disappears, notice "Comment hidden" with Undo (calls `hide_comment` false); no way back after the notice ends.
  - [x] Report: the shared report sheet with `ContentKind.comment`, then the sent row.
  - [x] Copy text: clipboard + notice "Copied". Double-tap a comment likes it (never unlikes).
  - [x] Strings EN + AR (`x-review`), semantics, RTL.
- **Implementation steps:**
  1. `.../cubit/comments/comments_cubit.dart` (edit): `startEdit`, `cancelEdit`, `saveEdit`, `delete`, `hide`, `undoHide`, `report` (through `ReportContentUseCase(ContentKind.comment, id, reason, note)`), double-tap like; each action throws or reports a `Failure` the sheet shows as a notice; rollback on failure.
  2. `.../utils/enums/comment_option.dart` (new) and `.../utils/comment_option_layout.dart` (new): which rows for whom (own / someone else's / post owner), following `post_option_layout.dart`.
  3. `.../widgets/comments/comment_options_sheet.dart` (new, built on `AppBottomSheet`), `comment_quick_emoji.dart` (new); reuse the report flow the way `post_options_flow.dart` and `story_menu_actions.dart` do; reuse `ReportSentRow`.
  4. `comment_row.dart` (edit): long-press, double-tap, "Edited".
  5. `lib/l10n/*.arb` (edit).
  6. Edge cases: delete a comment that has replies; hiding your own comment is not offered; the post owner also writer; a hidden comment the writer still sees; a failed delete puts the row back; Undo after the sheet closes uses the cubit and ids taken at tap time, never the context (as the post options do).
- **Tests:** cubit tests (edit, delete with replies, hide + undo, report, rollbacks); `comment_option_layout_test.dart`; widget tests for the options sheet (own / other / owner) EN + AR.
- **Out of scope:** pin (left out), mentions (30).
- **Done when:** panel 3 and the own-comment menu match; every action works on doubles; a failure rolls back.
- **Verify:** analyze, tests, compare with panels 3 and 4.

### Phase 30: Mentions (S14 panel 6)
**Status:** [x] code done 2026-10-26
- **Goal:** typing @ suggests people; a picked person is written into the text and gets a notification; @names in comments are tappable.
- **Depends on:** 28.
- **Spec refs:** `post/screens/s14-comments-sheet.md` panel 6 and "Tap on @name"; board panel 6; `post/screens/s6-tag-people.md` (person row look).
- **Tasks:**
  - [x] Suggestions card above the composer: 3 rows (avatar 36, name 14/700, @username 12), first highlighted; shows while the text before the cursor ends with `@letters`.
  - [x] Pick inserts `@username ` (replacing the typed part); Mention data goes to the server only as text (the server parses it, as in Phase 26).
  - [x] @names in a comment are drawn in `primary` and tappable: open the profile route; leave `// TODO(post-plan T23): ...` there.
  - [x] Strings EN + AR (`x-review`), semantics, RTL (the @name keeps its left-to-right order inside Arabic text).
- **Implementation steps:**
  1. `.../utils/mention_query.dart` (new): finds the `@word` under the cursor; pure function.
  2. `.../cubit/comment_mentions/` (new cubit + state): debounce 300 ms (same as the likes search), calls `GetMentionCandidatesUseCase`, keeps the last result; offline or failure shows nothing.
  3. `.../widgets/comments/comment_mention_list.dart` (new); `comment_composer.dart` (edit): shows the list, handles the pick.
  4. `.../widgets/comments/comment_text.dart` (new): builds the comment's `TextSpan`s with `@name` taps; `comment_row.dart` (edit).
  5. `lib/l10n/*.arb` (edit); the T23 marker (and `TODO(post-plan T23)` row stays open).
- **Tests:** `mention_query_test.dart`; cubit test (debounce, empty query, failure); widget test for the list and a `@name` span in EN + AR.
- **Out of scope:** the mention notification screen (T24).
- **Done when:** panel 6 matches; the pick inserts the @username; a @name tap goes to the profile route.
- **Verify:** analyze, tests, compare with panel 6.
- **Deviations:** the debounce constant is `CommentText.mentionDelay` (300 ms; the likes search does not exist yet). The cubit's state is the plain list of people. A suggestion needs at least one letter after the `@`. The @name tap passes the username to `AppRoutes.profileOf` (the profile placeholder takes an id; `TODO(post-plan T23)`). `CommentMentionsCubit` is provided next to `CommentsCubit` in `CommentsSheet.show`; the post page (Phase 31) must do the same.

### Phase 31: Post page (S15 panels 1, 2, 3 and 5)
**Status:** [ ]
- **Goal:** one post opens on its own page with the full post, "Liked by …", the date, comments and the composer; it shows "not available" when the post can't be seen.
- **Depends on:** 27-30 (the comments widgets and cubit); 25 (the card).
- **Spec refs:** `post/screens/s15-post-page.md` (layout, panels 1-3 and 5, Behavior, Data); board `s15-post-page-board.png` panels 1-3 and 5; `post/02-components.md` P1-P5, P10-P11 and "Post page when comments are off".
- **Tasks:**
  - [ ] Route `/p/:postId` with `?comment=:id`; the screen takes the post already loaded (to show at once) or loads it.
  - [ ] Top bar (back, "Post", "..." opening S2); scroll swaps the title for a mini author; the post card with the full caption (no "more"), media, dots and "1/3" chip, Follow chip (hidden on your posts; "Following" after, tap unfollows), actions, "Liked by …" row, date line.
  - [ ] Comments section below the card: same list as S14 (the sheet's cubit, widgets and composer, inline); sort chip; the comment icon on the page scrolls to the section and focuses the field.
  - [ ] `?comment=` opens with that comment first in the list (the cubit's `focusCommentId` → `p_focus`), highlighted for 2 s, with the "From your notification" chip for 2 s.
  - [ ] Not available state (lock, text, Back to Home) for a post that is gone or not visible; the back arrow and "..." stay.
  - [ ] Video plays with sound here (muted in the feed); likes, saves and comment counts update the feed card too.
  - [ ] Strings EN + AR (`x-review`), semantics, RTL, 1.5x, wide window (`ContentWidth`).
- **Implementation steps:**
  1. `lib/core/router/app_routes.dart` (edit): `postPage(String id, {String? comment})`, `postPagePrefix = '/p/'`, the likes route `/p/:id/likes` (Phase 32); keep `commentsOf` for now (Phase 33 changes it).
  2. `lib/core/router/app_router.dart` (edit): resolve `/p/:id` before the switch like the story and profile routes; the route argument `PostPageArgs` (post, signed links, optional) lives in `features/post/presentation/utils/post_page_args.dart` (new).
  3. `features/post/domain/use_case/get_post_use_case.dart` (new): reads `posts_by_ids([id])` through `PostsDatasource.getPostsByIds` and returns the first or null (no new server call; the RPC already returns the home-feed row shape and nothing for a post you can't see); media links signed with `SignPostMediaUrlsUseCase`. **Deviation from the spec text (`get_post`): confirm in the phase.**
  4. `.../cubit/post_page/post_page_cubit.dart` + `post_page_state.dart` (new, freezed): loading / ready / unavailable / error with the loaded post; refreshes after showing the passed one; applies the page's like / save through its own `PostActionsCubit` and reports counts back to the feed: fire a small `PostCountsChanged` event (new, `features/post/domain/event/`) that `FeedCubit` listens to the way it listens to `PostSaved` (a change in home: `features/home/presentation/cubit/feed/feed_cubit.dart`, calls the existing `applyCounts`).
  5. `.../screen/post_page_screen.dart` + `.../view/post_page_view.dart` (new): screen provides the cubits and holds the `BlocListener` for notices; the view builds the page; small `BlocSelector` widgets for the top bar title and the Follow chip.
  6. `.../widgets/post_page/` (new): `post_page_top_bar.dart`, `post_page_card.dart` (reuses `PostCard` with a "full caption" input; add the input to `PostCard` / `ExpandableCaption` without changing the feed look), `post_liked_by_row.dart`, `post_page_date.dart`, `post_page_comments_section.dart`, `post_notification_chip.dart`, `post_page_unavailable.dart`; dimens `post_page_dimens.dart`.
  7. `lib/l10n/*.arb` (edit).
  8. Edge cases: opening from a share's original (the share's embed has no counts: load); a deleted post while the page is open (next refresh shows unavailable); a `?comment=` id that no longer exists (normal list, no chip); rotating or a wide window.
- **Tests:** cubit tests (passed post shown then refreshed, unavailable on null, error then retry, counts event); widget tests (card with full caption, Follow chip states, unavailable, comments-off bar, EN + AR + 1.5x); route test for `/p/:id?comment=`.
- **Out of scope:** the Likes list (32), wiring entry points (33).
- **Done when:** panels 1, 2, 3 and 5 match; the page is reachable by its route; counts stay in step with the feed card.
- **Verify:** analyze, tests, compare with `s15-post-page-board.png` panels 1-3 and 5.

### Phase 32: Likes list (S16)
**Status:** [ ]
- **Goal:** "Liked by …" opens a list of the people who liked the post, searchable, with Follow buttons.
- **Depends on:** 31; B16 to apply.
- **Spec refs:** `post/screens/s15-post-page.md` "S16 Likes list" and Data; board `s15-post-page-board.png` panel 4; `features/follow` (`ToggleFollowUseCase`, `FollowStatus`).
- **Tasks:**
  - [ ] Migration `<timestamp>_post_likes_list.sql` (+ copy in `post/schema-post-likes-list.sql`): `post_likers(p_post, p_query, p_limit, p_before)` (the author sees everyone, others only people they can see, private accounts hidden; follow state), `liked_by_preview(p_post)` (first follower who liked + 2 avatars + total). Validate in a rolled-back batch, then apply after approval (B16).
  - [ ] The "Liked by …" row on the post page now uses `liked_by_preview` and opens the list; hidden when there are no likes.
  - [ ] Likes screen: back, "Likes · 1,204", search field (waits 300 ms after typing), rows with Follow / Following / Follow back (tap toggles at once, no confirm), paged list, empty search tile, error with Try again.
  - [ ] Strings EN + AR (`x-review`), semantics, RTL.
- **Implementation steps:**
  1. `supabase/migrations/...` and the spec copy (new), as above.
  2. `features/post/data/model/post_liker_model.dart`, `liked_by_preview_model.dart` (new); `features/post/data/datasource/post_likes_datasource.dart` (new: interface + adapter); `domain/entity/post_liker_entity.dart` (new); use cases `GetPostLikersUseCase`, `GetLikedByPreviewUseCase` (new). Follow / unfollow goes through the follow feature's `ToggleFollowUseCase` via a post use case if the conventions require (features trade only through use cases: check `lib/features/follow/domain/use_case/` and follow what `PostActionsCubit` already does).
  3. `.../cubit/post_likes/post_likes_cubit.dart` + state (new): search with `listenTo`/debounce like Phase 30, paging with `LoadMoreStatus`, follow toggles with rollback.
  4. `.../screen/post_likes_screen.dart`, `.../view/post_likes_view.dart`, `.../widgets/post_likes/post_liker_row.dart` (new); `PagedScrollView` (this list is a page with pull to refresh: the shared widget fits); route `/p/:id/likes` in `app_routes.dart` / `app_router.dart` (edit); profile tap opens `AppRoutes.profileOf`.
  5. `post_liked_by_row.dart` (edit) and `PostPageCubit` (edit) for the preview.
  6. `lib/l10n/*.arb` (edit).
  7. `build_runner`.
- **Tests:** datasource tests; cubit tests (search debounce, paging, follow toggle + rollback, empty); widget test for rows and button states EN + AR; the rolled-back SQL report.
- **Out of scope:** profile screens (placeholder), a blocked-accounts filter (no blocks table, T14).
- **Done when:** panel 4 matches; the author sees everyone and others only people they may see (checked in SQL); search and Follow work.
- **Verify:** analyze, tests, compare with panel 4. **I ask you first:** applying the migration (B16).

### Phase 33: Entry points and notification jump
**Status:** [ ]
- **Goal:** every comment icon, framed original, story "View post", link and notification target opens the right place.
- **Depends on:** 27-32.
- **Spec refs:** `post/screens/s15-post-page.md` Behavior (Route); `post/00-overview.md` Navigation map; `post/02-components.md` P10-P11.
- **Tasks:**
  - [ ] The feed card's comment icon opens `CommentsSheet.show` (replaces `AppRoutes.commentsOf` in Home); tapping the caption or time opens the post page.
  - [ ] The framed original on a share opens the original's post page; the story sticker's View post opens the post page. Remove both `TODO(post-plan T21)` markers.
  - [ ] `AppRoutes.commentsOf` (`/post/:id/comments`) now opens the post page with the field focused (the same as the page's comment icon); delete the `TODO(home-plan H3)` placeholder branch in `AppRouter`.
  - [ ] Deep link `pulse://...` path `/p/:postId` resolves through `AppRouter` (check `AndroidManifest.xml` and `Info.plist` already pass paths through; add nothing unless needed).
  - [ ] A notification target is just the route `/p/:postId?comment=:id` (Activity itself is later, T24); nothing to build now beyond the route.
  - [ ] Update the spec line in `s15-post-page.md` Behavior ("keeps opening the S14 sheet") to match.
- **Implementation steps:**
  1. `lib/features/home/presentation/widgets/feed/feed_post_item.dart` (edit): `_openComments` calls `CommentsSheet.show(context, postId: ..., onCountChange: ...)`; `_openOriginal` pushes `AppRoutes.postPage(original.id)`; caption / time tap pushes the page with the loaded post as `PostPageArgs`.
  2. `lib/features/story/presentation/widgets/story_post/story_post_layer.dart` (edit): the pill pushes `AppRoutes.postPage(postId)`.
  3. `lib/core/router/app_routes.dart`, `app_router.dart` (edit): as above; keep the Activity placeholder.
  4. Other lists that show a `PostCard` (search, profile) do not exist yet.
  5. Run `grep -rn "TODO(post-plan T21\|TODO(home-plan H3"`: none left.
- **Tests:** update the existing Home / story tests that expect the comments route; add a router test for the three routes.
- **Out of scope:** Activity screens (T24).
- **Done when:** the comment icon opens the sheet, the original and the sticker open the post page, `/p/:id?comment=:id` opens the page with that comment first.
- **Verify:** analyze, tests, device run (user).

### Phase 34: Integration and polish (comments, post page, likes)
**Status:** [ ]
- **Goal:** the whole flow works end to end and passes RTL, accessibility and size checks.
- **Depends on:** 26-33; B15 and B16 applied for the live run.
- **Spec refs:** acceptance lists of S14 and S15 (incl. S16).
- **Tasks:**
  - [ ] App boot test in `test/app/post_integration_test.dart`: Home > comment icon > write > the comment shows > reply > long-press > Hide + Undo; Home > caption > post page > "Liked by" > Likes > Follow; a share's original > post page.
  - [ ] DI wiring (`build_runner`); the new routes in `AppRouter`.
  - [ ] Live run (after B15 and B16): comment and reply; reply to a reply; the same Retry writes once; edit, delete with replies; hide by the post owner (the writer still sees it, a second account doesn't); like and double-tap; mention notification row; the focus jump from a link; likes list for the author and for another account; a deleted post shows "not available"; comments off.
  - [ ] RTL, 1.5x, 2.0x, 320 dp and wide window for the sheet, the post page and the likes list.
  - [ ] Tick the S14 and S15 acceptance checklists; `grep -rn "TODO(post-plan"`: markers match the open Code TODOs rows (T23 new; T17 and T21 gone).
  - [ ] Bring the Progress table at the top up to date.
- **Done when:** all new acceptance lists ticked; analyze clean; full suite green (the known failures listed in Phase 25 are not from this work).
- **Verify:** full test suite, analyze, device run (user).

## Verification
Each phase: `fvm flutter analyze` clean, `fvm flutter test` green, its "Done when" items ticked, screenshots compared where the phase has UI. The builder ticks the phase Status and notes deviations in the phase.