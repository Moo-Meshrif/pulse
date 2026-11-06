# Progress: shorts

Current step: 6 (verify)

Screens: S1 Shorts feed [written], S2 New short [written], S3 Short editor [written without source screenshot].

## Answers so far

- Feature identifier → Shorts; slug `shorts` [user]
- Target → phone, light mode [user]
- S1 source → `screenshots/s1-shorts-feed.png`, 720 × 1559 px [seen]
- S2 source → `screenshots/s2-new-short.png`, 720 × 1559 px [seen]
- Screen names → S1 “Shorts feed”; S2 “New short” [user]
- Target → EN + AR; 390 × 844 existing design frame; no Figma [user]
- Theme → reuse `docs/specs/_theme/` and `lib/core/theme/` [observed]
- S1 layout → confirmed; fixed Facebook-style navigation sits below the video rather than overlaying it [user]
- S2 layout → confirmed [user]
- Design tokens → reuse existing theme; add only dark translucent media overlays and teal Record card [user]
- Navigation → shared across all pages, owned by control; Shorts has different behavior [user]
- Shorts navigation → shared bottom nav is fixed; each video takes only the remaining space above it [user]
- S1 behavior → vertical paged feed; visible item auto-plays and loops; tap pauses; Following/For you filter; actions open the usual profile, likes, comments, or system share flow [user]
- S2 recording → reuse the Story video recorder with Shorts-specific title; picker/gallery accepts videos only [user]
- Post-selection → Short editor with caption, trim, sound, visibility, and Share; returns to Shorts feed [user]
- Short editor scope → tag people, location, feeling/activity, and Allow comments [user]
- Maximum duration → 60 seconds; update shared media policy [user]
- Feed selection → Following is newest public Shorts from followed accounts; For you discovers eligible public Shorts ordered by engagement and recency [user]
- Own-Short overflow → match the Post menu: edit, toggle comments, change visibility, and delete [user]
- Sound → video’s original audio only; leave a music-library feature TODO [user]
- States → loading skeleton, retryable inline error, empty Following discovery prompt, offline last loaded video; Share disabled during upload and editor retained for retry [user]
- Video ratio → accept non-9:16 clips without cropping using padded/background presentation; 9:16 recommended [user]

## Open questions (pending)

- None blocking; Q1-Q4 are documented in `open-questions.md`.

## Next action

Re-read the written specs against S1 and S2, then request specification approval.
