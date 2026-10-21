# Changed posts, stories and shorts — what the user will see

Status: draft 2026-10-21. Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [x] 4 · [x] 5 · [ ] 6
Mode: one-by-one

## Today's problem
When a post, story or short changes on the server (edited, deleted, shared by you, liked by others), the feed learns about it only on a full load or a pull to refresh. A full reload also moves the list under your thumb. Sharing a post no longer refreshes the feed (2026-10-21), so a share shows up late. Add and edit already update the feed on the phone and stay as they are.

## The new story

**1. A post you follow is edited**
→ You are looking at the feed: the card changes in place (words, place, feeling).
→ The list does not move.

**2. A post, story or short is deleted**
→ If it is on screen it leaves the list.
→ Rows above stay where they are.

**3. Someone likes or comments on a post you see**
→ The count on the card changes in place.
→ Only posts on your screen are checked for counts, so a popular post you are not looking at costs nothing.

**4. New posts arrive while you are scrolled down**
→ Nothing is inserted above you.
→ A "New posts" pill shows at the top. Tap it and they appear.
→ At the very top of the feed they appear at once.

**5. You share a post**
→ When it is out, it comes through the same check and appears in your feed. No refresh band, no jump.

**6. You open Home or come back to the app**
→ The app asks the server only for what changed since last time.
→ Changed cards update. No skeleton, no refresh band.

**7. You were away longer than the limit (1 day to start, one setting you can change)**
→ The feed loads normally once.

**8. A post is made Only me**
→ People who could see it lose it from their feed on their next check.

**9. You have no connection**
→ Nothing changes on screen. It tries again on the next open or return.

**10. The server tells the app right away (last phase)**
→ The card changes while you are looking at it, without opening Home again.

## Safety
- The server returns only what the person is allowed to see (audience and blocks).
- A deleted item leaves only its id and kind in the log, no content.

## Waiting on you
- Approval to change the live database (new columns, log table, new server function) — blocks Phase 1 — needed from you.
- "Setting you can change" for the 1 day limit: a value in the app (change and rebuild) or one you change without a release? — blocks Phase 2 — needed from you.

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan
**Status:** [x]
- **Goal:** the plan is saved.
- **Tasks:**
  - [x] Save this plan.
- **Done when:** the file is saved.

### Phase 1: Server knows what changed
**Status:** [x]
- **Goal:** the server can answer "what changed since this moment" for posts, stories and shorts.
- **Depends on:** Phase 0, live database approval.
- **Tasks:**
  - [x] Every post, story and short records when it last changed. Likes and comments do not touch this, so a popular post is not rewritten on every like.
  - [x] A deletions log records the id, kind and time of every delete.
  - [x] One server function returns the changed items, the deleted ids and a new point to continue from, a page at a time (a fixed page size; if more than a few pages are behind, it says "load normally").
  - [x] A second light server function takes the ids the phone is showing and returns only their current counts.
  - [x] It returns only what the caller may see.
  - [x] Old log entries are cleared after a safe time (longer than the away limit).
- **Out of scope:** the app side.
- **Done when:** in a test batch that is rolled back, an edit, a delete and a narrowed audience each show up (or leave) correctly for two different people, and a like changes only the counts answer, not the changes answer.
- **Verify:** rolled-back batch first; **I ask you first:** the live database change.
- **Notes (builder):** applied 2026-10-21 as `supabase/migrations/20261021190119_content_changes.sql`; checks in `supabase/tests/content_changes_test.sql` all passed in a rolled-back batch. `changes_since(kind, after_at, after_id, limit)` returns only ids and operations (`upsert` | `remove` | `delete`, plus `reset` and the next point); the full posts come from `posts_by_ids(ids)` (same shape as the home feed). `post_counts(ids)` gives counts. A post and a short are both rows of `posts` (`kind`). Stories are new by `created_at` or gone by the log; no story "remove" for audience changes yet. Log kept 3 days, "load normally" beyond 3 days or 300 changes. Deletions and changes are limited to your own and accepted follows' content; shorts from people you don't follow are not covered (open for the shorts feed).

### Phase 2: The phone remembers and asks
**Status:** [x]
- **Goal:** the app can ask for changes and keep its place.
- **Depends on:** Phase 1, the setting question above.
- **Tasks:**
  - [x] Remember the last point per kind and per signed-in user on the phone.
  - [x] Ask the server for changes since that point and only move the point forward after the answer is used.
  - [x] Ask for the counts of the ids on screen, separately.
  - [x] Tell the rest of the app what changed (updated items, deleted ids).
  - [x] Too old or no point yet: say "load normally".
  - [x] The away limit is one setting, 1 day by default.
  - [x] Leave a `// TODO(content-changes-plan T1)` marker where the live ping will plug in.
- **Done when:** with a test account, an edit made elsewhere is returned once and not again; signing out and in as another person starts clean; being away past the limit says "load normally".
- **Verify:** analyze and tests run as agreed with you.
- **Notes (builder):** B2 answered: the away limit is `AppConfig.contentChangesMaxAge` (1 day), changed in code. Built in `lib/shared/content`: `ContentChangesRepository` (asks the server, keeps one point per user and kind on the phone, sends a `ContentChanged` event with upserted and removed ids or `mustReload`, moves the point forward after the event, quiet on failure), use cases `CheckContentChangesUseCase(kind)` and `GetPostCountsUseCase(ids)`. First check on a phone only saves a starting point (no reload). The event carries ids only: Phase 3 reads the posts with `posts_by_ids`. The T1 marker is in the repository's `check`. Tests: 5 repository tests pass. Two existing tests in `content_media_repository_test.dart` (progress values) fail on a clean checkout too; not touched here.

### Phase 3: Posts update in place
**Status:** [x]
- **Goal:** story moments 1, 2, 3, 6, 7, 8, 9 for the feed.
- **Depends on:** Phase 2.
- **Tasks:**
  - [x] Home asks when it opens and when the app returns.
  - [x] The feed replaces a changed post, removes a deleted one, ignores the rest.
  - [x] Counts of the posts on screen are asked for when Home opens and when the app returns; the card updates without rebuilding the list.
  - [x] Too old: one normal load.
  - [x] Offline: stays quiet and tries next time.
- **Out of scope:** new posts at the top (next phase).
- **Done when:** edit, delete, like and narrowing a post from another phone each show on this one after Home opens, and the scroll position does not move; with no connection nothing breaks.
- **Verify:** run the app on two devices or accounts.
- **Notes (builder):** `FeedCubit` listens for `ContentChanged` (posts): a known changed post is read again with the new `GetPostsByIdsUseCase` (`posts_by_ids`) and swapped where it stands; a removed or deleted one leaves; one that can no longer be read leaves; unknown ids (new posts) are ignored (Phase 4). `mustReload` runs a silent refresh (`refresh(silent: true)`), skipped while a load is running. `FeedCubit.checkChanges()` runs the check then fetches counts; it runs at start (right after the load starts) and when the app returns (`HomeScreen`). Counts go through `FeedState.counts` and `PostActionsCubit.applyCounts`, so the list is not rebuilt; `FeedState.replacedIds` makes `PostActionsCubit.forget` drop a stale like/save override. Post-row mapping moved to `PostEntityMapper` (shared by both use cases). Not covered: a silent refresh is not seen by `_settled`, and a change in the few milliseconds between the first load and the first check can be missed. Tests: 5 feed tests + 3 actions tests added; existing feed/home tests updated for the new constructor.

### Phase 4: New posts and your share
**Status:** [x]
- **Goal:** story moments 4 and 5.
- **Depends on:** Phase 3.
- **Tasks:**
  - [x] New posts at the top while scrolled down wait behind a "New posts" pill (string in English and Arabic, labelled, RTL checked).
  - [x] At the top of the feed they appear at once.
  - [x] Your own share arrives through the check.
  - [x] Tapping the pill shows them and scrolls to the top.
- **Done when:** scrolled down with new posts waiting, the list does not move until you tap the pill; sharing a post shows it without a refresh band.
- **Verify:** run the app; Arabic checked.
- **Notes (builder):** built from the user's design (saved as `docs/specs/home/screens/s2-new-posts-pill.md`): the pill with avatars of up to 3 authors, count ("9+" above 9), hides while scrolling down, auto-hides after 10 s, tap puts the waiting posts on top then scrolls to top (jump first when more than 6 screens down), a soft ring on new cards, and the round back to top button after 3 screens. The Home tab re-tap scroll to top already existed in the control shell. Another person's new post waits in `FeedState.pendingPosts` and only goes in at once when the person is within one screen of the top; your own new post always goes in at once. Your own share arrives because `ShareToFeedUseCase` runs the change check after the share exists. Left out on purpose: the design's 60 s poll and `home_feed_new_count` (the plan keeps live updates for Phase 6) and "fast" scroll detection (the pill steps aside on any scroll down). Arabic strings are `x-review` drafts. Not run on a device: the scroll behaviour (pill timing, jump, ring) is checked by unit tests of the rules and the merge only. Tests: 7 rules, 8 merge, 4 cubit, 2 share use case; the 5 failing tests in the suite also fail on a clean checkout.

### Phase 5: Stories and shorts
**Status:** [x]
- **Goal:** story moments 1, 2 and 6 for the Stories rail and the shorts.
- **Depends on:** Phase 2.
- **Tasks:**
  - [x] The Stories rail updates and drops deleted stories without reloading.
  - [x] Shorts do the same.
- **Done when:** a story deleted elsewhere leaves the rail after Home opens; an edited short updates.
- **Verify:** run the app.
- **Notes (builder):** Stories: `StoryRailCubit` listens for `ContentChanged` of stories and reads the rail again quietly (the rail holds one row per person, so a changed story is a new read of the rail, not a patch); it asks `CheckContentChangesUseCase(ContentKind.story)` when it starts and when the app returns (`HomeScreen`). Shorts: there is no shorts feed in the app yet (the Shorts tab is a placeholder), so nothing can update; the server, repository and event already serve `ContentKind.short`. Code TODO T2 marks the Shorts tab placeholder in `control_screen.dart`. Tests: 3 story rail tests added; existing story rail tests updated for the new constructor argument. Not run on a device. Also fixed a Phase 4 bug found by `control_screen_test`: `FeedFloaters` read the scroll viewport before it was laid out and threw; it now waits until the position has pixels and a viewport.

### Phase 6: Live ping
**Status:** [ ]
- **Goal:** story moment 10.
- **Depends on:** Phases 3 to 5.
- **Tasks:**
  - [ ] The server pings the app when something changes; the app runs the same check right away.
  - [ ] A missed ping loses nothing, because the check still uses the saved point.
  - [ ] The ping stops when the app is in the background and when the user signs out.
  - [ ] Remove the `T1` marker.
- **Done when:** an edit made on another phone shows here within a few seconds while Home is open; with the ping off, the next open still catches up.
- **Verify:** run on two devices; **I ask you first:** any database setting for live updates.

## What it can't do
- No change while the app is closed or asleep (that would need push notifications).
- Counts of posts you are not looking at are not kept up to date; they are fetched when they come on screen.
- Ordering of the feed is not recalculated; only items already on the screen change in place.
- Live ping needs a connection; offline it waits.

## For the builder
### Reuse
- The existing event bus and `PostSaved` pattern; the `OnAppVisibility` widget on Home; the feed, Stories rail and shorts cubits; the paged scroll view; the existing local datasource style for the saved point.

### Blockers
| item | blocks phase | needed from | status |
|---|---|---|---|
| B1 live database change approval | 1 | you | done 2026-10-21 |
| B2 away limit setting: in the app or changeable without a release | 2 | you | done: one value in the app |

### Code TODOs
| id | what is pending | the code it sits in | phase |
|---|---|---|---|
| T1 | live ping hooks into the change check | the part that runs the check | 2 (placed), 6 (removed) |
| T2 | the shorts feed listens for `ContentChanged` of shorts and runs the check on open and return | the Shorts tab placeholder | 5 (placed), the shorts feature (built) |

### Verification
- Phase 1: rolled-back batch with two accounts; check that a like does not change a post's last-changed time and that a page of changes has a fixed size.
- Phases 2 to 6: `fvm flutter analyze`, agreed tests, then the app on two devices/accounts, scroll position watched in each.
