# Add post to story: sticker card (S13)
Screenshot: `../screenshots/s13-add-to-story-board.png` (5 panels + Sticker tokens / Behavior / Data notes). Opened from "Add to story" in the Share sheet (`s12-share-sheet.md`). Uses the story editor (`../../story/screens/s3-create-edit.md`) and viewer (`../../story/screens/s1-story-viewer.md`); the code lives in the story feature, the post data comes from a post use case.
Purpose / route: post a story that shows another post (or your own) as a draggable sticker on a coloured background. Viewers tap the sticker to see the post.

## Rules [seen in board notes, user confirmed 2026-10-21]
- Allowed posts: Public posts, and your own Public / Followers posts (the Share sheet icon table in `s12-share-sheet.md`). The story's audience is the post's audience or narrower: a Followers post can only go to Followers or Close friends.
- The story is a **photo story**: the background (plus your text and drawing) is rendered to an image on Share; the post sticker is **not** baked in. It is saved as data and drawn live by the viewer, so a deleted post becomes "Post unavailable".
- Video posts use the poster frame (the first frame image) in the sticker.

## Layout tree (editor, panel 1)
```
Story editor (3.12 shell) background = gradient from the media colors
├─ X close (start, top) · tool column (end): T text · palette · download
├─ Sticker: white card, width 280 (72% of screen), r20, padding 10, tilt -2°, shadow 0 16 40 black @35%
│    ├─ Author row: avatar 28 + username 13/700 (padding 2 2 8)
│    ├─ Media 4:5, r14 (first media)
│    └─ Caption 13/1.4, 2 lines, username bold
│  Selected: 2 dashed white outline, offset 8
├─ Style dots (6 high, active 18 wide, above the hint) + hint "Tap the post to change its style · pinch to resize" (white 13)
└─ Bottom bar: "Your story" pill (avatar + label) · "Share >" white pill (same as the story editor)
```

## Panels
| # | Panel | Content |
|---|---|---|
| 1 | Sticker, post card (default) | as tree. Drag, pinch 0.5x-2x, rotate. Tap the sticker = next style |
| 2 | Style: media only | rounded media (r22) with an author chip (h 30, `#161A19` @ 62%, avatar 22, username 12/700 white) at its bottom-start. The palette tool shows 6 background swatches above the bottom bar: from media (default) · dark · primary · 3 gradients |
| 3 | Style: compact | white card width 310, r18, padding 10, thumb 64 r12 + username 13/700 + caption 13 `textSecondary` 2 lines. For adding your own text above it (Aa); text, drawing and other stickers work as usual. Dark background shown |
| 4 | Viewer: tap the sticker | story pauses, the rest dims 25%, "View post" pill (white, h 44, chevron, pointer up) under the sticker. Tap the pill = opens the post [user, 2026-10-21: the comments route of the post, until a post page exists]. Tap elsewhere = resume |
| 5 | Viewer: post unavailable | the sticker is replaced by a frosted card (lock icon, "Post unavailable" 16/700, "It was deleted, or you can't see it."); the background stays. Not tappable |

## Behavior
- **Background default:** the two dominant colors of the first media (palette tool, package `palette_generator`, **new package: ask before adding**), top to bottom gradient. If no colors can be read, use a primary gradient.
- Style cycle order: card -> media -> compact -> card. Sticker position, style, scale, rotation and background are saved with the story. The dots show the current style.
- Share = same upload path as other stories (`story` background upload, then `create_story` with the sticker); the posting rail (S4) shows as usual.
- The viewer reads the post through normal access rules; `null` = panel 5. Likes, replies and the viewers list work as on any story.
- Later (not now): the post's author gets a "shared your post in their story" notification (`story_mention` style) [board note].

## Data (`../schema-post-share.sql`, not applied)
`stories.shared_post_id uuid references posts on delete set null`; `stories.sticker jsonb` = `{style: card|media|compact, x, y, scale, rotation, bg: {kind, colors[]}}` (x, y are 0-1 fractions of the screen). `create_story(..., p_shared_post, p_sticker)` re-checks the post can be shared and that the story audience is the post's audience or narrower.

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| storyPostStickerHint | Tap the post to change its style · pinch to resize | اضغط على المنشور لتغيير شكله · اسحب بإصبعين لتغيير الحجم |
| storyViewPost | View post | عرض المنشور |
| storyPostUnavailableTitle | Post unavailable | المنشور غير متاح |
| storyPostUnavailableBody | It was deleted, or you can't see it. | تم حذفه، أو لا يمكنك رؤيته. |
| storyPostNotShareable | This post can't be added to a story. | لا يمكن إضافة هذا المنشور إلى قصة. |
The last row is [estimated], for when the server refuses.

## Assets
Palette tool icon and download icon: the story editor's existing icons (the board shows them in the tool column). Icon names for the palette tool: `UNKNOWN`, ask in the plan (Phase 2 task).

## Responsive / a11y
Sticker width = 72% of the screen on phones, capped for wide screens at the story frame. Pinch limits 0.5x-2x. The sticker has a label "Post by {username}: {caption}"; the viewer pill reads "View post, button". RTL: author row and chip mirror; the sticker's position is saved as a screen fraction and is NOT mirrored. Text scale only affects the sticker text (2 lines, ellipsis).

## Acceptance checklist
- [ ] Default style card, tilt -2°, shadow, background from the media colors.
- [ ] Tap cycles card, media, compact; dots follow; hint copy matches.
- [ ] Drag, pinch 0.5x-2x and rotate work; the sticker stays inside the frame.
- [ ] Viewer: tap pauses, dims 25%, shows "View post"; tapping elsewhere resumes.
- [ ] Deleted or hidden post shows the frosted "Post unavailable" card.
- [ ] A Followers post can only be posted to Followers or Close friends.
- [ ] EN + AR + RTL.
