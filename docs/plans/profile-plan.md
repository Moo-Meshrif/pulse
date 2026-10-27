# Profile and Settings — what the user will see

Source specs: docs/specs/profile/, docs/specs/_theme/
Status: approved 2026-10-28. Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [x] 4 · [ ] 5 · [ ] 6 · [ ] 7 · [ ] 8 · [ ] 9 · [ ] 10 · [ ] 11 · [ ] 12 · [ ] 13 · [ ] 14
Mode: one-by-one

## Today's problem
Tapping a name or avatar anywhere opens an empty placeholder page. The Profile tab is empty. There is no Settings at all, so nobody can change their name, photo, password, privacy or language, block someone, or send a problem report.

## The new story

**1. You open the Profile tab**
→ You see your cover, photo, name (with a tick if verified), @name, bio and place.
→ A card shows your posts, followers and following. Below it, tabs for Posts, Shorts and Saved, then a grid of your pictures.
→ While it loads you see grey placeholders. With no posts you see a friendly empty message. Offline, you still see your saved header.
→ Shorts says it is coming soon. Saved shows only what you saved, and only you can see it.

**2. You tap your photo, the share button or the numbers**
→ Your photo opens large. You can zoom and close it. With no photo, nothing happens.
→ Share opens the phone's share sheet with your profile link.
→ Followers or Following open a list of people, each with a Follow button.

**3. You tap the sliders button and open Settings**
→ Three groups: Account, Preferences, Support, then Log out, Delete account and the app version.
→ Autoplay and Data saver switches work and are remembered on this phone.
→ Dark mode says it is coming soon.
→ Log out asks first, then takes you to Sign in. Delete account asks for your password first.

**4. You edit your personal info**
→ You change your photo, cover, name, @name, bio, place, phone and birthday. Email is shown but cannot be changed.
→ The @name shows a green tick when it is free and an error when taken.
→ The place field opens the place picker. Save is on only when something changed and everything is valid.
→ Leaving with unsaved edits asks "Discard changes?".

**5. You change your password and log other devices out**
→ You type the current password, a new one and the confirmation. Update works only when they are valid.
→ "Forgot password?" sends the usual reset email.
→ "Log out of all other devices" asks first, then signs the others out.
→ Two-factor, login alerts and the list of devices say they are coming soon.

**6. You set your privacy**
→ Private account, who can message you, who can comment, show activity status and appear in search all save at once.
→ If a change fails the switch goes back and you see an error.
→ Turning Private off leaves pending follow requests waiting for you.
→ Blocked accounts opens the blocked list: you see who, when, and you can Unblock with one tap.

**7. You choose notifications and language**
→ Each notification switch saves at once and is remembered on your account.
→ Language lists English and Arabic. Choosing one changes the whole app straight away. Arabic flips the app to right-to-left.

**8. You open someone else's profile**
→ You see their cover, photo, name, bio, "Follows you" chip, "Followed by" people and their numbers.
→ Public account: Follow works at once and the number goes up. If something fails it goes back and shows an error.
→ Private account: Follow sends a request and the button says "Requested". Tap it to cancel after a question. The page shows "This account is private" until they accept.
→ Following opens a sheet: close friends, post notifications, mute and Unfollow. Unfollowing a private account asks first.
→ Message says it is coming soon.
→ The "..." button offers Share profile, Copy link, Mute, Block and Report.
→ Block asks first. After it, you see "You blocked this account" with an Unblock button. If they blocked you, the page says "User not found".
→ Tagged shows posts they are tagged in. Shorts says it is coming soon.

**9. You get help**
→ Help center shows four topics and common questions you can open and close. A topic opens its own list of questions.
→ "Chat with us" says it is coming soon. "Report a problem" opens the report page.
→ In the report page you pick what is wrong, write up to 500 characters, add up to 3 screenshots and choose whether to include device info. Send is on once a category is chosen and you wrote at least 10 characters.
→ A failed send keeps what you wrote. Leaving with text asks "Discard?".
→ Terms & policies opens the five legal pages. Download your data and Ad preferences say they are coming soon.

## Safety
- Private accounts hide posts, shorts and stories from people who don't follow them.
- Blocking works both ways and removes the follows between the two people. Unblocking does not bring them back.
- Someone who blocked you cannot be told apart from someone who does not exist.
- The "who can comment" choice is enforced by the server, not only by the screen.
- Phone, birthday and email are never shown on a profile.
- Deleting an account needs the password and cannot be undone.
- Screenshots in problem reports are private and only the team can read them.

## Waiting on you (the blockers, in plain words)
- Share-link web address — blocks nothing; placeholder used (T1) — needed from you.
- Company name for the Terms page footer — blocks nothing; placeholder used (T2) — needed from you.
- Design of the photo viewer — blocks nothing; a simple black full-screen viewer is used (T11) — needed from you.
- Arabic text review — blocks nothing; all Arabic is draft until you approve it — needed from you.
- Live database changes — blocks Phases 1 and 2 — I ask you before applying them.

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan
**Status:** [ ]
- **Goal:** the plan is saved.
- **Tasks:**
  - [x] Save this plan.
- **Done when:** this file exists in docs/plans.

### Phase 1: Server for profiles and people lists
**Status:** [x] written and passing locally; live database not applied yet (waiting for approval)
- **Goal:** the server can answer everything the profile pages and people lists need.
- **Depends on:** Phase 0.
- **Spec refs:** docs/specs/profile/00-overview.md ("Known gaps"), screens/s1-profile.md, s12-other-profile.md (Data mapping), s13-people-list.md.
- **Tasks:**
  - [x] Add the profile columns (cover, verified).
  - [x] Add the profile page functions (own and other), the "followed by" preview, the posts grid, saved posts and tagged posts.
  - [x] Add the followers, following and mutual lists.
  - [x] Add the username lookup used by @mentions.
  - [x] Write the SQL tests.
- **Implementation steps:**
  1. `supabase/migrations/<timestamp>_profile_pages.sql` (new, follow the style of `20261027102442_post_likes_list.sql` and `20261010033816_follow_requests.sql`): `alter table public.profiles add column cover_url text, add column is_verified boolean not null default false`; no client grant on `is_verified` (admin-set); grant update on `cover_url` only. Add a public `covers` Storage bucket and the owner-only policies, copying the `avatars` bucket policies.
  2. Same file, `profile_by_id(p_user uuid)` (security definer, `search_path` set): returns the profile fields the page shows, posts/followers (accepted only)/following counts, `i_follow` (none | pending | accepted), `follows_me`, `can_message`, `is_private`, `blocked_by_me` (always false until Phase 2 adds blocking, which then replaces this function with `create or replace` to return no row when the target blocked the caller; the app shows "User not found").
  3. Same file, `profile_id_by_username(p_username text)` returns the id, or null; used by the @mention tap in `lib/features/post/presentation/widgets/comments/comment_body.dart`.
  4. Same file, `mutual_followers_preview(p_user uuid)`: two names, up to three avatars, total count.
  5. Same file, `user_posts(p_user uuid, p_kind text, p_before timestamptz)`: `p_kind` is `posts` or `tagged` (shorts later); respects `can_view_post` style visibility used by the feed and RLS (private accounts hide posts from non-followers); paged by `p_before`. `saved_posts(p_before)`: the caller's `post_saves` joined to posts they may still see.
  6. Same file, `followers_of`, `following_of`, `mutual_followers` (each `p_user`, `p_q`, `p_before`, limit 20) returning id, username, full name, avatar, `is_verified`, `i_follow`; a private account that the caller does not follow returns no rows.
  7. `supabase/tests/profile_pages_test.sql` (new) and `supabase/tests/profile_pages_rpc.sh` (new), copying how `update_post_settings_test.sql` / `update_post_settings_rpc.sh` run: public vs private visibility, pending vs accepted counts, tagged respects visibility, own saved only.
- **Tests:** the two SQL test files above.
- **Out of scope:** blocks (Phase 2), Shorts content.
- **Done when:** the SQL tests pass; a public profile returns counts and `i_follow`; a private profile's grid returns nothing for a non-follower.
- **Verify:** run the SQL tests. **I ask you first:** applying the migration to the live database.

### Phase 2: Server for settings, blocking and help
**Status:** [x] written and passing locally; live database not applied yet (waiting for approval)
- **Goal:** the server can store privacy choices, blocks, help content and problem reports, and can delete an account.
- **Depends on:** Phase 1.
- **Spec refs:** screens/s5-privacy.md, s6-blocked-accounts.md, s9-help-center.md, s10-report-problem.md, s12-other-profile.md, s2-settings.md (Delete account).
- **Tasks:**
  - [x] Privacy columns and enforcement in the comment functions.
  - [x] Blocks table and block / unblock / list functions; hide blocked people in the profile, posts, stories and search functions.
  - [x] Post-notifications table; close friends and mute stay as they are.
  - [x] Help tables and problem reports table with the screenshots bucket.
  - [x] Profile reporting; account delete.
- **Implementation steps:**
  1. `supabase/migrations/<timestamp>_profile_privacy.sql` (new): `alter table public.profiles add column who_can_message text not null default 'everyone' check (in 'everyone','following','none'), who_can_comment text not null default 'everyone' check (in 'everyone','followers','none'), show_activity boolean not null default true, appear_in_search boolean not null default true`; `grant update (...)` for these columns and `is_private` like `20261014135126_post_visibility.sql` does for its column.
  2. Same file: make the comment create function from `20261025180433_post_comments.sql` refuse when the author's `who_can_comment` forbids the caller (followers only: caller must be an accepted follower; none: nobody); keep the post-level comments switch.
  3. Same file: when `is_private` goes from true to false, pending requests stay pending (no change in follows).
  4. `supabase/migrations/<timestamp>_blocks.sql` (new): `public.blocks(blocker_id, blocked_id, created_at)`, primary key pair, not-self check, RLS select for the blocker only, grants revoked then granted like `20261013205633_story_audience.sql`; `block_user(p_user)` (inserts, deletes follows and pending requests both ways, removes close-friends / mutes rows both ways), `unblock_user(p_user)`, `blocked_users(p_before)` with the block time. Extend the existing visibility helpers (`can_view_story`, post visibility, search) so a blocked pair sees nothing of each other; make `profile_by_id` return no row when the caller is blocked by the target and `blocked_by_me` true when the caller blocked them.
  5. `supabase/migrations/<timestamp>_post_subscriptions.sql` (new): `post_subscriptions(user_id, author_id, created_at)` owner-only, select/insert/delete grants; the notification function from `20261014213146_notifications.sql` notifies subscribers when the author posts.
  6. `supabase/migrations/<timestamp>_help_and_reports.sql` (new): `help_topics(id, slug, icon, title_en, title_ar, position)`, `help_articles(id, topic_id, question_en, question_ar, answer_en, answer_ar, position, is_common)`, read-only select for authenticated, seed the four topics and the four questions seen in S9; `problem_reports(id, user_id, category, message 1-500, screenshot_paths text[], device_info jsonb, logs text, created_at)` insert-only for the owner; private `problem-reports` bucket, owner-only upload under `<user_id>/`, 5 MB limit; `submit_problem_report(...)` checks category list and max 3 screenshots.
  7. Same file: extend `reports` (from `20261013155610_post_options.sql`) with `reported_user_id` so a row can be about a profile instead of a post (post_id nullable, check exactly one of the two); `report_user(p_user, p_reason, p_note)`.
  8. `supabase/migrations/<timestamp>_delete_account.sql` (new): `delete_my_account()` deletes the caller's `auth.users` row (cascade does the rest) and the Storage files under their folders; callable by the signed-in user only.
  9. `supabase/tests/profile_settings_test.sql` (new) and `.sh` runner: comment rules, block both ways (follows removed, profile hidden), unblock keeps follows removed, private-off keeps requests, report check, delete removes rows.
- **Tests:** the new SQL test file.
- **Out of scope:** message enforcement (needs Chat, T9).
- **Done when:** SQL tests pass; a blocked person's profile returns no row; a "followers only" account refuses a stranger's comment.
- **Verify:** SQL tests, Supabase advisors check for the new tables. **I ask you first:** applying migrations to the live database.

### Phase 3: Shared pieces for the new pages
**Status:** [x] written; analyze clean; not yet run in the app (widgets first appear in Phase 4+)
- **Goal:** the building blocks (rows, switches, cards, accordion) exist and can be seen.
- **Depends on:** Phase 0.
- **Spec refs:** 01-design-tokens.md, 02-components.md, assets.md.
- **Tasks:**
  - [x] Register the new icons and the default cover.
  - [x] Add the profile and settings dimens.
  - [x] Build the shared rows and cards used by several pages.
  - [x] Add the first batch of text for English and Arabic.
- **Implementation steps:**
  1. `lib/core/constants/app_assets.dart` (edit): add `icSliders`, `icGrid`, `icStateBlocked` and the default cover path (`assets/images/profile/cover_default.png`). Check `pubspec.yaml` already lists `assets/icons/` and add `assets/images/profile/` if missing.
  2. `lib/features/profile/presentation/dimens/profile_dimens.dart` (new): values from 01-design-tokens.md for the header, stats card, tabs, grid and locked card; scaled like `StoryDimens`.
  3. `lib/core/theme/dimens/settings_dimens.dart` (new, exported from `dimens/app_dimens.dart`): group card, row, switch, radio, accordion, outline pill, because Settings pages, Privacy and Help all use them (more than one screen). Mark each value `[estimated]` in a comment only where the spec says so; confirm against the screenshots.
  4. `lib/core/widgets/` (new files, export in `widgets.dart`): `settings_group.dart` (section label + white card), `settings_row.dart` (icon tile, title, value, chevron), `switch_row.dart`, `radio_row.dart`, `outline_pill_button.dart`, `danger_button_card.dart`, `person_row.dart`, `faq_accordion.dart`. Reuse `AppSvgIcon`, `AppText`, `AvatarInitials`. Switch and radio drawn with the theme tokens (`primary`, `switchOff`, `dashed`), 40% opacity when disabled.
  5. `lib/core/widgets/app_top_bar.dart` (edit only if it cannot show a Sora title with the back arrow; check first).
  6. `lib/l10n/app_en.arb` and `app_ar.arb` (edit): add the strings from the specs for this phase's widgets only; keep Arabic tagged `x-review`. Run `fvm flutter gen-l10n`.
  7. A small preview is not added to the app; check the widgets in the screens of later phases.
- **Tests:** none (visual widgets; checked in later phases).
- **Done when:** `fvm flutter analyze` is clean and the app still runs.
- **Verify:** analyze; run the app.

### Phase 4: Your profile
**Status:** [x] written; analyze clean; cubit test passes; not yet run on a device (needs the Phase 1 migration applied to the live database)
- **Goal:** the Profile tab shows your real profile: header, numbers, tabs and the Posts and Saved grids.
- **Depends on:** Phases 1, 3.
- **Spec refs:** screens/s1-profile.md, 02-components.md (ProfileHeader, StatsCard, ProfileTabs, PostGrid).
- **Tasks:**
  - [x] Data for the profile page, the grid and saved posts.
  - [x] Header, stats card, tabs, grid, empty/loading/offline states.
  - [x] Share, photo viewer, sliders button.
  - [x] Replace the Profile tab placeholder.
  - [x] TODO markers T1, T3, T11.
- **Implementation steps:**
  1. `lib/features/profile/data/model/profile_page_model.dart` (new): wire model of `profile_by_id` (profile fields, counts, `iFollow`, `followsMe`, `canMessage`, `isPrivate`, `blockedByMe`, `isVerified`, `coverUrl`); `profile_grid_item_model.dart` (new): post id, first media thumbnail, blurhash, kind (photo, video, multi). Use `JsonMapper` and the style of `profile_model.dart`.
  2. `lib/features/profile/data/datasource/profile_page_datasource.dart` (new, interface + Supabase adapter in one file, like `follows_datasource.dart`): `getProfilePage(userId)` (null when the row is missing), `getPosts(userId, {before})`, `getSavedPosts({before})`, `getTagged(userId, {before})`; all through `Guard.run`.
  3. `lib/features/profile/domain/entity/profile_page_entity.dart` (new) only if the screen needs a different shape than the model (counts formatting stays in the view with `lib/core/utils/compact_count.dart`); otherwise use the model directly.
  4. `lib/features/profile/presentation/cubit/profile/profile_cubit.dart` + `profile_state.dart` (new, freezed state with data, like `SignInState`): `load()`, `refresh()`, `loadMore()`, `selectTab(...)`; `BaseCubit.run`; the header comes from `ProfileRepository` (existing, has the device copy) for offline, the grid from the new datasource. One cubit per tab list is not needed: the state holds the active tab's `LoadMoreStatus` (`lib/core/state/`).
  5. `lib/features/profile/presentation/screen/profile_screen.dart` (new): provides the cubit with `getIt`; `view/profile_view.dart` (new) uses `PagedScrollView`; bottom padding includes `NavClearance.of(context)`; `AppSafeArea(bottomSpace: ...)`.
  6. `lib/features/profile/presentation/widgets/` (new): `profile_header.dart` (cover with `AppImage` or the default cover, avatar with ring via `AvatarInitials`, name + `ic_verified`, handle, bio 3 lines, place row), `stats_card.dart`, `profile_tabs.dart`, `post_grid.dart` (3 columns, square, radius 10, uses `AppBlurhash`), small `BlocSelector` widgets for each part; the header and stats are shared with Phase 11 (one `ProfileHeader` with an `isOwn` flag).
  7. Share: `lib/core/services/launch_service.dart` (edit if it has no share method; otherwise reuse) to open the system share sheet with the link; add `// TODO(profile-plan T1): placeholder share-link domain, replace with the real one` where the link is built (`profile_link.dart` (new) in `lib/features/profile/presentation/utils/`).
  8. Photo viewer: `lib/features/profile/presentation/widgets/photo_viewer.dart` (new): black background, `InteractiveViewer`, close button; add `// TODO(profile-plan T11): photo viewer design not given`.
  9. Shorts tab: show `AppEmpty` with "Shorts are coming soon" and `// TODO(profile-plan T3): Shorts need the shorts feature`.
  10. `lib/features/control/presentation/widgets/tab_navigator.dart` (edit): the Profile tab root becomes `ProfileScreen` instead of `TabPlaceholder`; sliders button pushes `AppRoutes.settings` with the nearest Navigator.
  11. `lib/core/router/app_routes.dart` (edit): add `settings = '/settings'` and the sub routes used in later phases (`settingsPersonalInfo`, `settingsSecurity`, `settingsPrivacy`, `settingsBlocked`, `settingsNotifications`, `settingsLanguage`, `settingsHelp`, `settingsHelpTopic`, `settingsReport`, `settingsTerms`, `people`); `lib/core/router/app_router.dart` (edit): add the cases (settings pages stay `PlaceholderScreen` until their phase).
  12. `lib/core/di/injection.config.dart`: run `fvm dart run build_runner build --delete-conflicting-outputs`.
  13. Strings for this screen in both ARB files; `fvm flutter gen-l10n`.
- **Tests:** `test/features/profile/presentation/cubit/profile/profile_cubit_test.dart` (new, bloc_test + mocktail): load success, empty, failure, refresh, load more, tab switch.
- **Out of scope:** the people lists (Phase 5), real Settings (Phase 6).
- **Done when:** the Profile tab shows the header and grids; empty state, loading and an error with retry work; tapping the photo opens the viewer; Share opens the sheet.
- **Verify:** analyze, cubit test, compare with `docs/specs/profile/screenshots/s1-profile.png`. **I ask you first:** the plus sign (new package) for sharing, if `share_plus` is not already in `pubspec.yaml`.

### Phase 5: People lists
**Status:** [ ]
- **Goal:** Followers, Following and "Followed by" lists open from the numbers.
- **Depends on:** Phases 1, 3, 4.
- **Spec refs:** screens/s13-people-list.md, screens/s6-blocked-accounts.md (row look).
- **Tasks:**
  - [ ] List data, screen with search, follow pill on each row.
  - [ ] Wire stats taps and the route.
- **Implementation steps:**
  1. `lib/features/profile/data/datasource/people_datasource.dart` (new): `followers(userId, {query, before})`, `following(...)`, `mutual(...)` using the RPCs from Phase 1; model `person_model.dart` (new).
  2. Follow actions: call the existing use cases of `features/follow` (`toggle_follow_use_case.dart`, `get_follow_status_use_case.dart`); the screen never touches the follow datasource (features trade through use cases). If a list-row follow needs a status-returning use case that does not exist, add `follow_person_use_case.dart` (new) in `features/follow/domain/use_case/`.
  3. `lib/features/profile/presentation/cubit/people/people_cubit.dart` + `people_state.dart` (new): kind, query (debounced), rows, per-row follow status, `LoadMoreStatus`; private-not-followed case from the server returns empty and the state shows the private text.
  4. `lib/features/profile/presentation/screen/people_screen.dart` + `view/people_view.dart` (new): `SearchPillField` (hidden for mutual), `PagedScrollView`, `PersonRow` with the follow pill (`OutlinePillButton`); row tap goes to `AppRoutes.profileOf(id)` (own id -> Profile tab is not pushed; use the own-profile check in Phase 11).
  5. `lib/core/router/app_routes.dart` / `app_router.dart` (edit): `people` route takes `kind` and `userId` query values; Profile stats and (Phase 11) "Followed by" push it.
  6. Strings in both ARB files; gen-l10n.
- **Tests:** `test/features/profile/presentation/cubit/people/people_cubit_test.dart` (new): paging, search filter, follow toggle rollback on failure.
- **Done when:** tapping Followers opens the list; a public Follow flips at once; an error rolls it back with a notice; empty list shows the message.
- **Verify:** analyze, cubit test, run the app. Compare with `s6-blocked-accounts.png` for row look.

### Phase 6: Settings home, log out and delete account
**Status:** [ ]
- **Goal:** Settings opens with all groups; Autoplay and Data saver work; Log out and Delete account work.
- **Depends on:** Phases 2, 3.
- **Spec refs:** screens/s2-settings.md.
- **Tasks:**
  - [ ] Settings screen with values (Privacy, Blocked count, Notifications, Language).
  - [ ] Device-saved switches.
  - [ ] Log out and Delete account with their dialogs.
  - [ ] TODO marker for Dark mode (T5) and company/version footer where shared.
- **Implementation steps:**
  1. `lib/core/services/storage/storage_keys.dart` (edit): add `autoplayShorts`, `dataSaver`, `appLocale`; `lib/features/profile/data/datasource/app_preferences_datasource.dart` (new, like `onboarding_datasource.dart`): getters and setters over `LocalStorageService`; failed writes are reported, never thrown.
  2. `lib/features/profile/data/datasource/settings_datasource.dart` (new): `getSummary()` (privacy value, blocked count, push on/off), `deleteAccount(password)` (re-sign-in with the password, then `delete_my_account`), reusing the auth sign-in call through a use case from `features/auth` (add `verify_password_use_case.dart` (new) there if none exists; profile never imports auth's datasource).
  3. Log out: reuse the existing sign-out use case in `features/auth/domain/use_case/`; after it, `AppNavigator.resetTo` sign in; also run `ClearLocalProfileUseCase` (existing).
  4. `lib/features/profile/presentation/cubit/settings/settings_cubit.dart` + state (new): summary, switches, `logOut()`, `deleteAccount(password)`; one-shot effects handled by the screen's `BlocListener`.
  5. `screen/settings_screen.dart`, `view/settings_view.dart` (new): groups per spec using the Phase 3 widgets; footer version from `package_info_plus` (ask before adding the package if not present); Dark mode: disabled switch, tap shows a notice, with `// TODO(profile-plan T5): dark mode needs a dark theme`.
  6. Dialogs: `ConfirmationDialog.destructive` for Log out; for Delete account, a dialog with a password field (build with `AppDialogShell`, `AppTextField`) in `widgets/delete_account_dialog.dart` (new); wrong password = inline error, success clears local data and resets to sign in.
  7. Router: replace the Settings placeholder case with `SettingsScreen`.
  8. Strings; gen-l10n; build_runner.
- **Tests:** `test/features/profile/presentation/cubit/settings/settings_cubit_test.dart` (new): summary load, switch persistence, log out, delete wrong password, delete success.
- **Done when:** values show; switches survive a restart; Log out asks then signs out; Delete with a wrong password shows the error.
- **Verify:** analyze, cubit test, compare with `s2-settings.png`. **I ask you first:** adding `package_info_plus` if it is missing.

### Phase 7: Personal info
**Status:** [ ]
- **Goal:** you can edit your profile, photo and cover.
- **Depends on:** Phases 2, 3, 6.
- **Spec refs:** screens/s3-personal-info.md.
- **Tasks:**
  - [ ] Form with validation, username check, counter, Save rules, discard dialog.
  - [ ] Avatar and cover change with crop; place picker for Location.
- **Implementation steps:**
  1. `lib/features/profile/data/model/profile_update_model.dart` (edit): add `coverUrl`; `profile_datasource.dart` (edit): `uploadCover(bytes, contentType)` / `removeCover()` to the `covers` bucket (one file per user, same pattern as the avatar), `isUsernameAvailable` already exists (own current username counts as free: handle in the cubit); `profile_model.dart` (edit): add `coverUrl`, `isVerified`.
  2. `profile_repository.dart` (edit): include cover in the saved device copy; phone and birthday stay off the device copy (existing rule).
  3. `lib/features/profile/domain/use_case/` (new): `save_personal_info_use_case.dart` only if validation beyond the repository is needed; otherwise the cubit calls the repository (profile is one feature; no use case needed).
  4. `lib/features/profile/presentation/cubit/personal_info/personal_info_cubit.dart` + state (new): fields, `isDirty`, `isValid`, username check with debounce, photo picks (`PhotoPickerService`, crop), location from the place picker result (`LocationChoice`), `save()`; reuse the validators in `features/auth/presentation/utils/` by moving shared ones (`username_format`, `phone_format`, `birthday`) to `lib/core/utils/` if profile may not import auth (check `.claude/conventions/architecture.md`; move with their tests).
  5. `screen/personal_info_screen.dart` + `view/personal_info_view.dart` (new): fields with `AppTextField`, phone with `PhoneField`, bio counter, the camera badge and "Change cover photo" using `PhotoSourceSheet`; Location field pushes `AppRoutes.pickPlace` with the current value and reads the `LocationChoice`; Save pinned with `PrimaryButton` and `AppSafeArea`; back / system back with edits shows `ConfirmationDialog.primary` "Discard changes?" (`PopScope`).
  6. Strings; gen-l10n.
- **Tests:** `personal_info_cubit_test.dart` (new): dirty/valid rules, username taken, save success and failure, discard.
- **Done when:** Save is off until you change something valid; a taken username shows the error; photo and cover update; leaving with edits asks.
- **Verify:** analyze, cubit test, compare with `s3-personal-info.png`.

### Phase 8: Notifications and language
**Status:** [ ]
- **Goal:** notification switches save to your account; the app language changes at once.
- **Depends on:** Phases 3, 6.
- **Spec refs:** screens/s7-notifications.md, s8-language.md.
- **Tasks:**
  - [ ] Notifications page.
  - [ ] Language page and app-wide language switch.
- **Implementation steps:**
  1. `lib/features/profile/data/datasource/notification_prefs_datasource.dart` (new): read the caller's `notification_prefs` row (missing row = defaults); `set(Map<String, bool>)` calls `set_notification_prefs`; model `notification_prefs_model.dart` (new).
  2. `lib/features/profile/presentation/cubit/notifications/notifications_cubit.dart` + state (new): optimistic toggle with rollback and error notice; Push switch turning on asks the OS permission through the existing notification setup (check `lib/core/services` for it; if none exists leave `// TODO(profile-plan T12): ask the OS permission when push is wired` and keep the server flag only).
  3. `screen/notifications_screen.dart` + view (new) with `SettingsGroup` and `SwitchRow`.
  4. `lib/core/services/locale_service.dart` (new, interface + impl): holds `ValueNotifier<Locale?>` (null = device), reads/writes `StorageKeys.appLocale` through `LocalStorageService`; registered in DI.
  5. `lib/app/app.dart` (edit): wrap `MaterialApp` with a `ValueListenableBuilder` on the service's notifier and pass `locale:`; keep `_resolveLocale` for the device case.
  6. `lib/features/profile/presentation/cubit/language/language_cubit.dart` (new, flat, small) or a `ValueNotifier` in the screen: only English and Arabic rows; search filters by native or English name; choosing sets the locale and stays on the page.
  7. `screen/language_screen.dart` + view (new): `SearchPillField`, `SettingsGroup` with two rows and the check, the footnote.
  8. Strings (the language names are not translated); gen-l10n.
- **Tests:** `notifications_cubit_test.dart` (new): load defaults, toggle, rollback; `locale_service_test.dart` (new): save and read.
- **Done when:** a switch survives a restart; choosing Arabic flips the whole app to right-to-left at once and stays after restart.
- **Verify:** analyze, tests, run the app in both languages; compare with `s7-notifications.png`, `s8-language.png`.

### Phase 9: Privacy and blocked accounts
**Status:** [ ]
- **Goal:** your privacy choices save at once; you can see and unblock blocked accounts.
- **Depends on:** Phases 2, 3, 6.
- **Spec refs:** screens/s5-privacy.md, s6-blocked-accounts.md.
- **Tasks:**
  - [ ] Privacy page with 4 cards.
  - [ ] Blocked accounts list with Unblock.
  - [ ] TODO marker for message enforcement (T9).
- **Implementation steps:**
  1. `lib/features/profile/data/datasource/privacy_settings_datasource.dart` (new, name differs from `shared/content` `privacy_datasource.dart`, which handles post audience): read and update `is_private`, `who_can_message`, `who_can_comment`, `show_activity`, `appear_in_search` on `profiles`; enums `message_audience.dart`, `comment_audience.dart` (new) in `data/enums/` with wire values.
  2. `lib/features/profile/data/datasource/blocks_datasource.dart` (new): `list({before})` -> `blocked_users`, `block(userId)`, `unblock(userId)`, `count()`; model `blocked_person_model.dart` (new). Used again by Phase 12.
  3. `cubit/privacy/privacy_cubit.dart` + state (new): optimistic updates with rollback; `cubit/blocked/blocked_cubit.dart` + state (new): paged list, unblock removes the row, notice "Unblocked @name".
  4. `screen/privacy_screen.dart`, `screen/blocked_screen.dart` + views (new): `SwitchRow`, `RadioRow`, `PersonRow` with relative time ("Blocked 2 weeks ago") using `lib/core/utils/post_time.dart` if it fits, otherwise a new small formatter next to it; empty state with `ic_state_blocked`.
  5. Where `who_can_message` is stored add `// TODO(profile-plan T9): enforce when Chat exists`.
  6. Strings; gen-l10n.
- **Tests:** `privacy_cubit_test.dart`, `blocked_cubit_test.dart` (new): optimistic change and rollback, unblock.
- **Done when:** each change survives a restart; a failed save goes back with an error; Unblock removes the row; empty list shows the message.
- **Verify:** analyze, tests, compare with `s5-privacy.png`, `s6-blocked-accounts.png`.

### Phase 10: Password and security
**Status:** [ ]
- **Goal:** you can change your password and log out of other devices.
- **Depends on:** Phases 3, 6.
- **Spec refs:** screens/s4-password-security.md.
- **Tasks:**
  - [ ] Change password with the same rules as sign-up.
  - [ ] Forgot password, Log out of all other devices.
  - [ ] Coming soon items with TODO markers (T4).
- **Implementation steps:**
  1. `features/auth/domain/use_case/` (edit/new, check what exists): `change_password_use_case.dart` (verify current password, then update), `sign_out_others_use_case.dart`, reuse the forgot-password use case; add them in `features/auth` and call them from the profile cubit (features trade through use cases).
  2. `cubit/security/security_cubit.dart` + state (new): fields, rules check (reuse the password rules and strength from sign-up/reset), `update()`, `logOutOthers()`.
  3. `screen/security_screen.dart` + view (new): fields on `surfaceMuted` with the eye toggle, Update pill, Forgot password link (existing reset email flow), switch rows disabled for 2FA and Login alerts, one "This device" row from the device name (`device_info_plus`, ask before adding if missing), `DangerButtonCard` with `ConfirmationDialog.destructive`.
  4. `// TODO(profile-plan T4): two-factor, login alerts and the device list need server work` at the three places.
  5. Strings; gen-l10n.
- **Tests:** `security_cubit_test.dart` (new): rules, wrong current password, success, log out others.
- **Done when:** a wrong current password shows the error; a valid change shows the notice and clears the fields; "coming soon" items show the notice.
- **Verify:** analyze, test, compare with `s4-password-security.png`. **I ask you first:** adding `device_info_plus` if missing.

### Phase 11: Someone else's profile
**Status:** [ ]
- **Goal:** `/profile/:id` opens a real profile with follow, private, requested and blocked states.
- **Depends on:** Phases 1, 2, 4, 5.
- **Spec refs:** screens/s12-other-profile.md (states 1-5 and 7).
- **Tasks:**
  - [ ] Other-profile screen using the shared header and grid.
  - [ ] Follow buttons and states, locked card, blocked card, user-not-found.
  - [ ] Tagged tab, "Followed by" row, own id opens the Profile tab page.
  - [ ] Router: replace the placeholder.
- **Implementation steps:**
  1. `lib/core/router/app_router.dart` (edit): remove the placeholder branch marked `TODO(story-plan T3)`; `/profile/:idOrUsername` opens `OtherProfileScreen(userId)`; when the id is the signed-in user (compare with `GetCurrentUserIdUseCase`) show `ProfileScreen` pushed inside the nearest Navigator without the sliders-first assumption; `AppRoutes.profileOf` stays.
  2. `lib/features/post/presentation/widgets/comments/comment_body.dart` (edit): the mention tap resolves the username to an id with the `profile_id_by_username` RPC (via a `GetProfileIdByUsernameUseCase` (new) in `features/profile/domain/use_case/`) and then calls `profileOf(id)`; unknown name = notice "User not found".
  3. `cubit/other_profile/other_profile_cubit.dart` + state (new): loads `profile_by_id`; no row = `notFound`; follow button states (none, followBack, following, requested) derived from `iFollow` and `followsMe`; optimistic follow/unfollow through `ToggleFollowUseCase`; cancel request; mutual preview; tabs Posts / Shorts / Tagged.
  4. `screen/other_profile_screen.dart`, `view/other_profile_view.dart` (new): reuse `ProfileHeader` (other variant: back button and "..." button), `StatsCard`, `PostGrid`, new `follow_buttons.dart`, `locked_card.dart` (ic_lock_closed, private text and requested text), blocked state card (`ic_state_blocked`, Unblock pill), `followed_by_row.dart` (3 avatars + text, tap -> people mutual).
  5. Message button: shown unless `canMessage` is false; tap shows "Messages are coming soon" with `// TODO(profile-plan T6): open Chat when it exists`.
  6. Cancel request and private-unfollow use `ConfirmationDialog.destructive` / `.primary`; notice "Follow request sent" with the hint.
  7. Strings; gen-l10n; build_runner.
- **Tests:** `other_profile_cubit_test.dart` (new): each follow state, optimistic rollback, private request and cancel, not found, blocked.
- **Out of scope:** the Following sheet and Options sheet (Phase 12).
- **Done when:** the five board states (1, 2, 4, 5, 7) match; a failed follow rolls back; own id shows your own profile; a blocked-me profile says "User not found".
- **Verify:** analyze, test, run with two accounts, compare with the S12 board in the spec.

### Phase 12: Following sheet, options sheet, block and report
**Status:** [ ]
- **Goal:** the Following sheet and the "..." sheet work.
- **Depends on:** Phases 2, 9, 11.
- **Spec refs:** screens/s12-other-profile.md (Sheets).
- **Tasks:**
  - [ ] Following sheet: close friends, post notifications, mute, unfollow.
  - [ ] Options sheet: share, copy link, mute, block with confirm, report.
- **Implementation steps:**
  1. `lib/features/profile/data/datasource/author_prefs_datasource.dart` (new): close-friend on/off (`close_friends` table; if `features/story` already has a use case for it, call that use case instead of the table), post notifications on/off (`post_subscriptions`), read current values together with the profile load.
  2. Mute: reuse `SetMuteUseCase` in `lib/shared/content/domain/use_case/set_mute_use_case.dart` (existing; check its scope enum covers a whole person, else extend `mute_scope.dart` there).
  3. Block: `BlocksDatasource.block` (Phase 9) through `block_user_use_case.dart` (new, in `features/profile/domain/use_case/`); success moves the page to the blocked state and shows the notice.
  4. Report: `ReportContentUseCase` in `shared/content` extended for a profile target, or a new `report_user_use_case.dart` (new) that calls `report_user`; reuse the existing `ReportSheet` from `lib/core/widgets/report_sheet/` (check it can say "profile").
  5. `widgets/following_sheet.dart`, `widgets/profile_options_sheet.dart` (new): built with `AppBottomSheet`, rows with `SwitchRow`-style tiles; Share profile uses the link builder from Phase 4; Copy link uses the clipboard and shows "Profile link copied".
  6. Strings; gen-l10n.
- **Tests:** extend `other_profile_cubit_test.dart` for the sheet toggles (optimistic and rollback), block and unblock.
- **Done when:** each toggle saves and shows the new value next time; Block asks first and turns the page into state 7; Report sends and shows the thanks.
- **Verify:** analyze, tests, compare with board panels 3 and 6.

### Phase 13: Help center, report a problem and terms
**Status:** [ ]
- **Goal:** Help center, topic pages, the report form and Terms & policies work.
- **Depends on:** Phases 2, 3, 6.
- **Spec refs:** screens/s9-help-center.md, s10-report-problem.md, s11-terms-policies.md, s14-help-topic.md.
- **Tasks:**
  - [ ] Help center and topic page from the server.
  - [ ] Report form with screenshots and device info.
  - [ ] Terms & policies page.
  - [ ] TODO markers T2, T7, T8.
- **Implementation steps:**
  1. `lib/features/profile/data/datasource/help_datasource.dart` (new): topics, common questions, questions of a topic; language picked by the app's locale (`title_en` / `title_ar`); models `help_topic_model.dart`, `help_article_model.dart` (new).
  2. `cubit/help/help_cubit.dart` + state (new) for S9 and S14 (topic slug optional); accordion open state stays in the view (`ValueNotifier`).
  3. `screen/help_screen.dart`, `screen/help_topic_screen.dart` + views (new): topic cards (tap -> topic route), `FaqAccordion`, "Chat with us" notice with `// TODO(profile-plan T7): chat support`, "Report a problem" -> report route.
  4. `lib/features/profile/data/datasource/problem_report_datasource.dart` (new): upload up to 3 images (5 MB each, compressed with the existing media services) to `problem-reports/<uid>/`, then `submit_problem_report`; device info from the device plugin (Phase 10), logs = last 50 error lines: add a small ring buffer to `lib/core/error/error_reporter.dart` (edit) that keeps the last 50 reports.
  5. `cubit/report/report_cubit.dart` + state (new): category, text (1-500 with the 10-character rule), photos, include-logs, send with progress; keeps the form on failure.
  6. `screen/report_screen.dart` + view (new): chips with `SelectableChip` (selected = dark fill), field with counter, `PhotoSourceSheet` (gallery, up to 3), dashed add tile, checkbox, pinned `PrimaryButton`; discard dialog when text exists.
  7. `screen/terms_screen.dart` + view (new): five rows push the existing legal routes; "Last updated" from `legal_documents` through a small `LegalDatasource` call (extend `lib/features/legal/data/datasource/legal_datasource.dart` with `getUpdatedDates()` if missing); Download your data and Ad preferences show the notice with `// TODO(profile-plan T8): data export and ad preferences are not built`; footer company with `// TODO(profile-plan T2): placeholder company name`.
  8. Strings; gen-l10n; build_runner.
- **Tests:** `help_cubit_test.dart`, `report_cubit_test.dart` (new): rules for Send, failure keeps the form, success.
- **Done when:** topics and questions load; a topic opens its list; a report with 3 screenshots sends; a failed send keeps text; the five legal rows open.
- **Verify:** analyze, tests, compare with `s9-help-center.png`, `s10-report-problem.png`, `s11-terms-policies.png`.

### Phase 14: Polish
**Status:** [ ]
- **Goal:** everything matches the screenshots in English and Arabic and works with big text.
- **Depends on:** Phases 4-13.
- **Tasks:**
  - [ ] Check every screen against its acceptance checklist and screenshot.
  - [ ] Check right-to-left, text scale 1.5 and screen-reader labels on each screen.
  - [ ] Confirm the `[estimated]` sizes with you and fix them.
  - [ ] List the remaining `TODO(profile-plan` markers and check each against the Code TODOs table.
- **Implementation steps:**
  1. `grep -rn "TODO(profile-plan" lib` and compare to the table; remove markers whose blocker is resolved.
  2. Walk each screen in both languages; fix overflow and mirroring in the affected files.
  3. Update `docs/specs/profile/open-questions.md` and the spec values the user corrected.
  4. `CLAUDE.md` "Known state": add a short line for the profile and settings features.
- **Tests:** run the full suite.
- **Done when:** `fvm flutter analyze` and `fvm flutter test` pass and every acceptance checklist is ticked.
- **Verify:** run the app on a device in EN and AR.

## What it can't do
- Shorts content, Chat and messaging, two-factor, login alerts, device list, dark mode, data download and ad preferences are not built; they say "coming soon".
- Only English and Arabic exist.
- Email cannot be changed here.
- Messaging rules are saved but only take effect when Chat exists.

## For the builder

### Reuse (existing widgets/theme/services to use)
`ProfileRepository`, `ProfileDatasource` (avatar upload), `FollowsDatasource` through `features/follow` use cases, `SetMuteUseCase`, `ReportContentUseCase`, `ConfirmationDialog`, `AppBottomSheet`, `PhotoSourceSheet`, `PhotoPickerService`, `PagedScrollView`, `SearchPillField`, `SelectableChip`, `AppEmpty`, `AvatarInitials`, `NoticeHost`, `LocalStorageService` / `StorageKeys`, `LegalScreen` routes, `AppRoutes.pickPlace` + `LocationChoice`, `compact_count.dart`, `post_time.dart`, `NavClearance`, `AppSafeArea`.

### Blockers (item | blocks phase | needed from | status)
| id | item | blocks | needed from | status |
|---|---|---|---|---|
| B1 | Live database changes approval | 1, 2 | you | open |
| B2 | New packages if missing (share, package info, device info) | 4, 6, 10 | you | share_plus added (Phase 4); package_info_plus still to ask (6); device_info_plus already present |

### Code TODOs (id | what is pending | the code it sits in | phase)
| id | what is pending | code | phase |
|---|---|---|---|
| T1 | Real share-link web address | the profile link builder | 4 |
| T2 | Real company name | the Terms footer | 13 |
| T3 | Shorts tab content (needs the shorts feature) | the Shorts tab on both profiles | 4, 11 |
| T4 | Two-factor, login alerts, device sessions | the Password & security page | 10 |
| T5 | Dark mode (needs a dark theme) | the Dark mode row in Settings | 6 |
| T6 | Message button opens Chat | the Message button | 11 |
| T7 | Chat with us | the Help center button | 13 |
| T8 | Data export and ad preferences | the Terms page rows | 13 |
| T9 | Enforce "who can message you" when Chat exists | the Privacy page save | 9 |
| T11 | Photo viewer design not given | the photo viewer | 4 |
| T12 | OS permission for push | the Push switch | 8 |
| T10 | Arabic text review | no code marker (ARB `x-review`) | all |

### Verification
Each phase: `fvm flutter analyze`, the listed tests, and for screens a comparison with `docs/specs/profile/screenshots/`. Server phases: the SQL tests and the Supabase advisors. Final: run EN and AR on a device.
