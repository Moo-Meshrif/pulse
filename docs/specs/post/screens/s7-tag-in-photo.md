# Tag in photo (S7)
Screenshot: `../screenshots/s6-tag-feeling-board.png` (board 1, panel 3). Opens from the "Tag in photo" button on S6 (shown only when the post has photos and at least one person is chosen) [user]; optional, S6 Done alone tags people in the post only. Build in full [user]. Card side (badge and labels): `../02-components.md` (P2/P4 additions) and board 2 panels 1-3.
Purpose / route: place each chosen person on a photo (x/y 0..1); `/create/post/tag-in-photo`, full page; returns the same `List<TagChoice>` with spots [user].

## Layout tree
```
Scaffold (background)  [AppSafeArea]
└─ Column
   ├─ Header 56: back · title "Tag in photo" (Sora 20/700) · "Done" pill
   ├─ Hint (14 `textSecondary`, padding 0 24): "Tap where someone is, then pick them. Drag a label to move it."
   ├─ Photo area (Expanded, full width): the selected photo (fit contain), counter pill "1/2" (top-end, mediaChip, 12/600 white)
   │    ├─ labels: dark pill at each spot (see tokens) with name + × ; small pointer
   │    └─ tap marker: dashed circle 28 (white, dashed 2) while choosing
   ├─ Thumbnail strip: 56 x 56 thumbs r12, gap 8; selected = 2 px `primary` ring offset 2; badge (top-end) = tags on that photo
   └─ Info card (white, r18, padding 10 16): `ic_user` 18 primary, text 14 + "**Youssef Samir** tagged in the post, not in a photo"
```
Videos are skipped (no spot on a video; the strip shows photos only).

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Label | username | h 30, r10, padding 0 10 | #161A19 @ 82%, 13/700 white | × 18 white inside; 7 px pointer toward the spot; above the spot, flips below when the spot is lower than 80% of the photo height [seen] |
| Spot marker | | 28 | dashed white ring | appears on tap, then the pick list opens |
| Photo counter | "1/2" | | mediaChip, 12/600 white | |
| Thumb badge | tag count | 20 circle | `primary` + white 11/700 | top-end of the thumb [user] |
| Info card | people with no spot | r18, padding 10 16 | `ic_user` 18 `primary`, name 700, text 14 | one line per person, or "N people tagged in the post, not in a photo"; hidden when everyone has a spot |

## Behavior
- Tap an empty spot -> marker -> **pick list** = bottom sheet (Post options shell) listing only the people chosen in S6 who do not yet have a spot on this photo; each row avatar 40 + name + @username; a search box at the top filters the list; picking one puts the label at the spot and closes the sheet [user, 2026-10-15]. No new people can be added here.
- Drag a label to move it (clamped inside the photo); tap × removes the spot only (the person stays tagged in the post; they appear in the info card).
- One spot per person: moving a person to another photo removes the first spot.
- Thumbnails switch the photo; the badge counts tags on it.
- Done returns to S6 (then S6 Done returns to New post); back with unsaved changes asks "Discard changes?".
- Coordinates saved as fractions of the photo's displayed width/height (x, y in 0..1), so they hold at any size.

## States
| State | UI |
|---|---|
| No photos | S6 hides the "Tag in photo" button, so S7 is never opened |
| Everyone placed | pick list shows "Everyone is placed" [estimated, text only]; info card hidden |
| Loading photo | blurhash/placeholder until the picked file is decoded |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| tagInPhotoTitle | Tag in photo | الوسم في الصورة |
| tagInPhotoHint | Tap where someone is, then pick them. Drag a label to move it. | اضغط على مكان الشخص ثم اخترْه. اسحب الوسم لتحريكه. |
| tagInPhotoNoSpot | {name} tagged in the post, not in a photo | تم وسم {name} في المنشور وليس في صورة |
| tagInPhotoNoSpotMany | {count} people tagged in the post, not in a photo | تم وسم {count} أشخاص في المنشور وليس في صورة |
| tagInPhotoAllPlaced | Everyone is placed | تم وضع الجميع |

## Data mapping
| UI | Source |
|---|---|
| Label | `post_tags.media_position` (photo index in the final media list), `x`, `y` |
| People without a spot | `post_tags` row with null position/x/y |
| Edit post | existing tags load from `home_feed.tags`; removing a photo clears its spots (server turns them into post-only tags) |

## Responsive / a11y
Photo area keeps the photo's aspect; labels min touch 44 (padding around the pill). Semantics: "Tag {name}, drag to move", × "Remove {name}'s spot". RTL: labels are positioned by x/y as drawn (not mirrored); header and strip mirror.

## Acceptance checklist
- [ ] Hint, photo with 1/2 counter, dark labels with ×, dashed tap marker, thumbs with tag badge, info card.
- [ ] Tap -> pick list of S6 people only; label appears and can be dragged inside the photo.
- [ ] × removes the spot, person moves to the info card.
- [ ] Done returns spots to New post; card later shows badge and labels (board 2).
