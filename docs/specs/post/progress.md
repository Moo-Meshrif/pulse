# Progress: post
Current step: 6 (Verify and hand off)
Screens: S1 new-post [written; delta pending], S2 post-options [written; delta pending], S3 add-location [written], S4 visibility [written], S5 edit-post [written; delta pending], S6 tag-people [written], S7 tag-in-photo [written], S8 feeling-activity [written], S9 activity-what [written], S10 tagged-people-sheet [written], S11 remove-tag [written], card/comments-off deltas [written in 02-components]; S1, S2, S5 deltas applied
## Answers so far
- Post UI + tokens live in the post spec [user]; New post screenshot copied from the session into screenshots/s1-new-post.png
- First build: caption, media, location, allow comments; Public chip, Tag people, Feeling/activity = "coming soon"; visibility choices Public / Followers / Only me spec'd for later [user]
- Media up to 10, photos + videos, video up to 10 min, 50 MB each [user]
- Share enabled with text or >= 1 media; loader; success closes + notice "Post shared" [user]
- Q2 add p_comments_enabled to create_post; Q3 location chosen from a map like Facebook (design pending); Q4 sizes confirmed; Q5 discard only with content; Q6 PrimaryButton loading flag [user]
- Location picker = list board (S3), not a map [user via screenshot]
- Build order: 1 control-page, 2 story, 3 post, 4 home [user]
- Q13: PostActionsDatasource + use cases (superseded 2026-10-14: post-only actions stay in features/post; report, audience, mute, files, counts, privacy are shared in lib/shared/content) [user]
- Q7/Q8/Q-L4: follow earlier features (image_picker + MediaPickerService, permission_handler, add geolocator, avatar-style resize) [user]
- Q-L2: icons added and verified [user]
- Visibility built now: board s4-visibility.png -> S4 spec; Q-V1..V4 answered; S2 gets 'Change who can see'; Copy link/Share coming soon [user]
- Resize: presets enum, default Instagram-like; packages geolocator + share_plus + blurhash_ffi approved; places deploy asks at end of Phase 6 [user]
- Round 2026-10-15 (boards `s6-tag-feeling-board.png`, `s10-card-details-board.png`): Share button stays "Share post"; Allow comments switch row stays as the 5th row; S7 tag-in-photo built in full; columns posts.mood_kind/mood_key/mood_text; emoji = native characters; Suggested people = people you follow, newest follow first; activity suggestions = seeded table `activity_suggestions` read by RPC; tagged user removes own tag from a row in S10; tag notification = insert row only (type 'tag'), UI with Activity; allow_tags column + enforcement now (default everyone), settings UI later; write schema-post-tags-mood.sql in spec [user]
- No blocks table exists yet: tag_search/can_tag skip block filtering for now (TODO when blocking exists) [assumed, confirm]
## Open questions (pending)
None blocking. Left: Q10 Arabic review (x-review), Q-L6 deferred, exact post resize values + core folder names (plan).
- Remove-tag board `s11-remove-tag-board.png` supplied; S7 pick list = only S6 people; profile Tagged tab = profile spec follow-up [user]
## Next action
Plan approved: docs/plans/post-plan.md. Phases 0-1 done; implement Phase 2.
- Shared code [user, 2026-10-14]: `lib/shared/<concept>/{data,domain}` for business code 2+ features use, generic names, Cubits call its use cases; one RPC per action taking `p_kind` (post | story | short); mute stays independent per scope. Migrations `post_visibility` and `shared_content_actions` applied 2026-10-14.

2026-10-15 later: activities deferred by the user (Activities tab = "Coming soon", S9 not built, suggestions table removed; TODO API/database).
2026-10-15 round: specs written (S6-S11, card/comments-off, SQL `schema-post-tags-mood.sql` not yet validated/applied). Q28 (Arabic nouns) and Q29 (sizes) answered 2026-10-15. Open: only the Arabic `x-review` of the remaining strings. Plan Phases 13-18 approved 2026-10-15 in docs/plans/post-plan.md; next: implement Phase 13.

## Round 2026-10-21: Share sheet (S12) - step 1 (Intake)
- Trigger: S2 Share and the feed card's share icon both open the Share sheet (board "Share sheet", 7 panels) [user]
- Copy link, WhatsApp, More stay "Coming soon" (T7) until the user provides the deep link; share text decided later [user]
- Send in chat (panels 5-7) hidden until chat exists; spec them, build with chat [user]
- Add to story built now (post as sticker card in the story editor) [user]
- Scope now: Share sheet, Share to feed (caption + audience), shared-post card in the feed, "This post isn't available", "Shared to your feed" notice with View, author notification type share [user]
- Pending: board file not saved yet (`screenshots/s12-share-board.png`); bottom notes (Tokens / Behavior / Data) cut off in the image sent
## Next action (S12)
Get the board file + full bottom notes, then Step 2 (observe) for panels 1-4 and the Add to story tile.
- 2026-10-21: board saved as `screenshots/s12-share-board.png` (1740x2460). Its bottom notes are still cut off in the file itself (Tokens ends at "Compose: thumb 44 r10 - field 44 r22 - Send 52 primary pill with send icon 18", Behavior at "Share to feed: public posts only; sharing a share shares the original; audience...", Data at "Chat needs Chat tables..."). Full text pending [user].
- Notification to the author on share: yes, type `share`, grouped per post [user]
- Add to story: tapping the post sticker in the story viewer opens the post's comments route (placeholder today) [user]
- 2026-10-21: full notes received; sticker board saved (`screenshots/s13-add-to-story-board.png`). Specs written: `screens/s12-share-sheet.md`, `screens/s13-add-to-story.md`, P10-P11 in `02-components.md`, `schema-post-share.sql` (not validated/applied), overview + open-questions Q-S1..S9 updated. Taps "as Facebook"; share icon on Public and Followers (own) posts [user].
## Next action (S12/S13)
Verify specs against the boards, confirm Q-S2/S6-S9, then add the phases to docs/plans/post-plan.md (implementation mode to ask).
- 2026-10-21 later: share board updated (composer tools Tag people / Feeling / Location, `ic_share_forward` title icon, hint removed); tags/feeling/location also kept when editing a share; `ic_palette.svg` added; Followers rule: Public anyone, Followers only people who can see it (chat later). Specs and plan Phases 19-22 updated; open: `ic_share_forward` icon (Q-S10/B14), plan approval.
- 2026-10-21: plan Phases 19-25 approved [user]; ic_share_forward added.

## Round 2026-10-25: Comments + post page - step 1 (Intake)
- New phases for docs/plans/post-plan.md: post page, comments list + write, replies (threads), comment actions (delete own, report, pin; author deletes others') [user]
- Design source: screenshots / board, to be sent by the user [user]
- Replaces the placeholder comments route (`TODO(home-plan H3)`); closes T17 (comments-off bar) and T21 (post page)
## Next action (comments)
Receive the board(s), save them to `screenshots/`, give screen ids (S14+), then Step 2 (observe).
- 2026-10-25: boards saved (`screenshots/s14-comments-board.png`, `s15-post-page-board.png`). Specs written: `screens/s14-comments-sheet.md`, `screens/s15-post-page.md` (includes S16 Likes list), overview + open-questions Q-C1..C11. Decisions: quick emoji go into the reply field; pin left out; sort = popup; shared report with `comment` kind; owner hides (no delete of others'); edit via composer strip. Comments SQL is written in the backend phase of the plan (not in the spec).
## Next action (comments)
User checks the specs (open: Q-C8 icons, Q-C9 estimates), then add Phases 26+ to docs/plans/post-plan.md.
- 2026-10-25: icons ic_reply, ic_copy, ic_send added [user]; Q-C8 closed. Open: Arabic review only.
- 2026-10-25: plan Phases 26-34 added to docs/plans/post-plan.md (waiting for approval). Plan decisions to confirm: hidden comments don't count (B18); old comments route opens the post page; get_post = existing posts_by_ids.
- 2026-10-25: Phase 26 built, migration post_comments applied (B15, B18 answered). Next: Phase 27.
- 2026-10-26: Phase 28 built (composer, reply strip, posting/failed rows, in-memory drafts, comments-off bar). Next: Phase 29.
- 2026-10-26: Phase 29 built (long-press menu, edit, delete, hide + undo, report, copy, double-tap like). Next: Phase 30.
- 2026-10-26: Phase 30 built (@ suggestions above the composer, pick inserts @username, tappable @names; profile tap is a placeholder, TODO(post-plan T23)). Next: Phase 31.
