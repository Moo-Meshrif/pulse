# Progress: home
Current step: done; plan approved (docs/plans/home-plan.md, 2026-10-14)
Screens: S1 home-feed [written], S2 post-options [written]
## Answers so far
- Slug home; S1 Home feed; Flutter phone 390x844 light, LTR+RTL, EN+AR, no Figma [user]
- Theme reused; user token file copied to source-tokens.md [user]
- Nav bar, shell, Create sheet = separate "control page" feature (iOS-style glass, imports other features' pages); Home draws a placeholder nav [user]
- Rail title stays "Stories"; scrollbar under rail removed [user]
- Taps: search /search, bell /activity, Your story create, story viewer, avatar profile, options sheet placeholder, comments, share, like/save toggle [user]
- Header floating+snap; caption 3 lines, more/less (less scrolls back); seen ring border; media aspect clamp; multi-image + video as token file; double-tap like; wide = ContentWidth; PulseLoader shared pending; AR drafts x-review [user]
- Q2: first load = skeletonizer shimmer (package defaults tuned to theme); refresh + load-more use PulseLoader (look pending) [user]
- Q4: empty tile icon ic_inbox; Q3: user will provide the 5 missing icons [user]
- Q7: chips, double-tap heart, media error (blurhash + tap retry), more/less 14/600 confirmed [user]
- Q8: Arabic stays x-review; Q9: user's home_feed.sql copied to schema.sql, gaps listed in Q9a [user]
- Q9a answered: rail = people; Your story tile always first; schema-post-options.sql written [user]
- Q1a answered with board v2 (3b/3c note step); Undo 5 s; rail image = author avatar [user]
- Q2 answered with the Page loading board: shimmer skeleton for first load, PulseLoader (Lottie) for refresh/load-more [user]
- Q3: five icons added to assets/icons [user]
- Video via video_flux (feed, stories, shorts); control page is specced before home is planned [user]
- New post is NOT in home (own feature later); home uses use cases from the post and story features [user]
- Short data-layer specs written for post and story (docs/specs/post, docs/specs/story) [user]
- Ownership: post widgets (card, options sheet) live in the post feature; story viewer + create in the story feature; rail UI in home [user]
- Build order: 1 control-page, 2 story, 3 post, 4 home [user]
## Open questions (pending)
See open-questions.md (Q1-Q10).
## Next action
Control, story and post are implemented (git log). Spec is complete; run `/spec-to-plan home`. Still open: Q6 (specs for search/activity/profile/comments, deferred), Q8 (Arabic x-review), Q16 (verify PulseLineLoader in the plan).
- Q1 answered with the post-options board; S2 written [user]
