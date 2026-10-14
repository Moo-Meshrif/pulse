# Progress: post
Current step: 6 (Verify and hand off)
Screens: S1 new-post [written], S2 post-options [written, moved from home], S3 add-location [written], S4 visibility [written]
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
## Open questions (pending)
None blocking. Left: Q10 Arabic review (x-review), Q-L6 deferred, exact post resize values + core folder names (plan).
## Next action
Plan approved: docs/plans/post-plan.md. Phases 0-1 done; implement Phase 2.
- Shared code [user, 2026-10-14]: `lib/shared/<concept>/{data,domain}` for business code 2+ features use, generic names, Cubits call its use cases; one RPC per action taking `p_kind` (post | story | short); mute stays independent per scope. Migrations `post_visibility` and `shared_content_actions` applied 2026-10-14.