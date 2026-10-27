# "Liked by" on feed posts — what the user will see

Status: draft 2026-10-27. Phases: [x] 0 · [ ] 1 · [ ] 2 · [ ] 3 · [ ] 4 · [ ] 5
Mode: one-by-one

## Today's problem
The post page says "Liked by salma.ash and 3 others". A post in the feed shows only a like count, so you can't see who liked it without opening it.

## The new story
**1. You scroll the feed**
→ Under the buttons of each post that has likes, a line appears: "Liked by salma.ash and 3 others", with up to two small faces.
→ The posts show first and the line fills in a moment later. The feed never waits for it.
→ If the line can't be loaded, it stays hidden. Nothing else breaks.
→ A post nobody liked has no line.

**2. You tap the line**
→ The list of people who liked the post opens.

**3. You like a post in the feed**
→ The heart and the count change at once, as today.
→ The line updates after the like is saved: "Liked by you" or the new names, as the server decides.

**4. You take your like back**
→ If you were the only one, the line disappears at once.
→ Otherwise it updates after the change is saved.

**5. You open the app again**
→ The saved feed shows without lines. They fill in once the feed is up to date, so old names never show.

## Safety
- You only see people you are allowed to see. The server decides, as on the post page.
- You are never named in the line unless you are the only one who liked it.

## Waiting on you
- Applying the new database change — blocks Phase 1 — needed from you (I ask first).

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan
**Status:** [x]
- **Goal:** the plan is saved.
- **Tasks:**
  - [x] Save this plan.
- **Done when:** the file is saved.

### Phase 1: The server answers for many posts at once
**Status:** [ ]
- **Goal:** one request returns the "Liked by" lines of up to 50 posts.
- **Depends on:** your yes to apply the change.
- **Spec refs:** `docs/specs/post/schema-liked-by-you.sql`, `supabase/migrations/20261027140000_liked_by_you.sql`.
- **Tasks:**
  - [ ] Write the new database function and its copy in the specs folder.
  - [ ] Check it in a rolled-back run, then apply after your yes.
- **Implementation steps:**
  1. `supabase/migrations/<ts>_liked_by_previews.sql` (new): `liked_by_previews(p_posts uuid[])` returns the columns of `liked_by_preview` plus `post_id`; at most 50 ids (same limit and error as `posts_by_ids`); same visibility rules as `liked_by_preview` (author sees all, others see who they may see, you are named only when you are the only liker). Posts the caller can't see, or with no likers, are left out, not an error. Grant to `authenticated` only.
  2. `docs/specs/post/schema-liked-by-previews.sql` (new): a copy of the function.
- **Out of scope:** the app side.
- **Done when:** the rolled-back check passes for the author, another viewer, only-me, an invisible post, more than 50 ids (refused) and `anon` (denied).
- **Verify:** SQL checks. **I ask you first:** before applying the migration to the live database.

### Phase 2: The app can ask for many lines
**Status:** [ ]
- **Goal:** the post feature can fetch the lines of a list of posts.
- **Depends on:** Phase 1.
- **Tasks:**
  - [ ] Model field, datasource call and use case.
- **Implementation steps:**
  1. `lib/features/post/data/model/liked_by_preview_model.dart` (edit): add `postId` read from `post_id` (null for the single-post call).
  2. `lib/features/post/data/datasource/post_likes_datasource.dart` (edit): `getPreviews(List<String> ids)` → `Map<String, LikedByPreviewModel>` through the existing `_call` helper on `liked_by_previews`; empty ids returns an empty map without a request.
  3. `lib/features/post/domain/use_case/get_liked_by_previews_use_case.dart` (new): returns `Map<String, LikedByPreviewEntity>`. Reuse the mapping of `GetLikedByPreviewUseCase` (move it to one function both use, no copy). Home calls it, so it is the post feature's public API.
  4. Run `fvm dart run build_runner build --delete-conflicting-outputs` (DI).
- **Tests:** datasource test for `getPreviews` (map by post id, empty ids); use case test (a row without a username is dropped).
- **Done when:** analyze is clean and the tests pass.
- **Verify:** analyze, tests.

### Phase 3: The feed holds the lines
**Status:** [ ]
- **Goal:** the feed loads the lines behind the posts and keeps them right after a like.
- **Depends on:** Phase 2.
- **Tasks:**
  - [ ] Load lines for new posts.
  - [ ] Refresh a post's line after its like request ends.
- **Implementation steps:**
  1. `lib/features/home/presentation/cubit/feed/feed_state.dart` (edit): `@Default(<String, LikedByPreviewEntity>{}) Map<String, LikedByPreviewEntity> likedBy`; run `build_runner` for the freezed file.
  2. `lib/features/home/presentation/cubit/feed/feed_cubit.dart` (edit): new constructor argument `GetLikedByPreviewsUseCase`. After a page loads (first load, refresh, load more) and after a change check adds posts (`_readChanged`), fetch for the new post ids only and merge into `likedBy`; a refresh replaces the map. Failures are swallowed (the row stays hidden). Not read from or saved to the Hive snapshot. Ignore an answer that arrives after a newer refresh (`generation`).
  3. Same file, `_countsChanged` (the `PostCountsChanged` path): when `likedByMe` changed for a post on screen, drop its entry at once if it is `isOnlyMe` and the like was taken back, then refetch that one post after `PostActionsCubit.likeSettled(postId)` ends (already added for the post page). Fetching on the tap would return the old likes.
- **Tests:** `FeedCubit` test: fills after a page; refetch after the like request ends; only-me unlike clears the row at once; failure hides the row; a stale answer is ignored. Update `test/features/home/home_doubles.dart`, `feed_cubit_test.dart` and `home_screen_test.dart` for the new argument.
- **Done when:** the state holds lines for the posts on screen and the tests pass.
- **Verify:** analyze, `fvm flutter test test/features/home`.

### Phase 4: The line shows on each post
**Status:** [ ]
- **Goal:** the feed shows the line and a tap opens the likes list.
- **Depends on:** Phase 3.
- **Tasks:**
  - [ ] Share the row between the post page and the feed.
  - [ ] Show it under each feed post that has likes.
- **Implementation steps:**
  1. `lib/features/post/presentation/widgets/post_page/post_liked_by_row.dart` (edit): make the private `_Row` a public `LikedByRow(likedBy, onTap)` with no Cubit; `PostLikedByRow` keeps its `BlocSelector` over `PostPageCubit` and uses it. Export `LikedByRow` from the post presentation barrel that Home already imports.
  2. `lib/features/home/presentation/widgets/feed/feed_post_item.dart` (edit): a small `BlocSelector<FeedCubit, FeedState, LikedByPreviewEntity?>` for the post id; draws `LikedByRow` as the card footer only when the entry exists and the like count is above 0; the tap pushes `AppRoutes.postLikes(id)` with `rootNavigator: true`.
  3. No new strings (the row already has them, EN and AR).
- **Tests:** widget test of the row in a feed card (EN and AR; hidden without an entry or without likes).
- **Done when:** the line appears after the cards, stays hidden when unavailable, a tap opens the likes list, and it reads correctly in Arabic.
- **Verify:** analyze, tests, run the app (yours).

### Phase 5: Check and note
**Status:** [ ]
- **Goal:** everything works together and the docs match.
- **Depends on:** Phase 4.
- **Tasks:**
  - [ ] Add a note about the feed line to the Phase 32 entry in `docs/plans/post-plan.md`.
  - [ ] Try like, unlike, only-me unlike, offline, refresh and restart.
- **Done when:** all of it behaves as the story says.
- **Verify:** `fvm flutter analyze`, `fvm flutter test test/features/home test/features/post`, device run (yours).

## What it can't do
- It does not show lines on the saved feed at launch; they come once the feed is up to date.
- The line for a post you just liked waits for the server, so it appears a moment after the heart.

## For the builder
### Reuse
- `GetLikedByPreviewUseCase` mapping, `PostLikedByRow`, `PostActionsCubit.likeSettled`, `PostPageCubit.youUnliked` (same idea), `AppRoutes.postLikes`.
### Blockers
| Item | Blocks phase | Needed from | Status |
|---|---|---|---|
| Apply the new database change | 1 | you | open |
### Code TODOs
None.
### Verification
- Per phase as listed; the SQL check runs rolled back before anything is applied.
