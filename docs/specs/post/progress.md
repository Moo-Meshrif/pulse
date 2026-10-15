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
