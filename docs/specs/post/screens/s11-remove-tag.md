# Remove your tag (S11)
Screenshot: `../screenshots/s11-remove-tag-board.png` (5 panels). Three ways in, one confirm, one result [user].
Purpose / route: a tagged person removes themselves from someone else's post; dialog, no route.

## Entry points
| # | Where | UI |
|---|---|---|
| 1 | Post options sheet (S2) when the viewer is tagged and not the owner (`i_am_tagged`) | a line at the top "You're tagged in this post" (`ic_user` 16 primary + 13 textSecondary), then the normal viewer sheet (quick row Save / Copy link / Share), and as the **first row of the group** "Remove me from this post" (sub "You won't be tagged anymore", icon `ic_user_minus` 16, row highlighted `primarySoft`, icon `primary`: it is the action you came for, not a danger). Then Not interested, then red Report post |
| 2 | Your own label on the photo (card tag view, tap the person badge) | your label is a white card r12, shadow 0 8 24 @ 25%: row 34 (avatar 22 + "You"), action row 38 with `ic_user_minus` 16 + "Remove tag" 13/700 `danger`. Other labels stay dark and open the profile |
| 3 | Profile > Tagged tab, long-press a tile | sheet: thumb + "{Owner}'s post" + "Tagged by {username} · {time}", rows View post / **Remove me from post** (danger, sub "Leaves your Tagged tab"). **Follow-up for the profile spec**; only the RPCs exist now [user] |
Also from S10: your own row, pill "Remove".

## Confirm dialog
`ConfirmationDialog.destructive`: icon `ic_user_minus` 44 stroke 1.5 `danger`, title "Remove your tag?" (Sora 20/700), body "You'll no longer be tagged in {Owner}'s post or its photos. The post itself stays." (14 textSecondary), "Remove" 52 danger pill, "Cancel" 44 link. Same dialog from all entry points.

## Behavior
- Removes you from the post and every photo on it in one call.
- Optimistic: headline and labels update at once ("You and 2 others" -> "Omar Khaled and Laila Fouad"), your label disappears, notice "Tag removed" / "You're no longer tagged in this post." Roll back with an error notice "Couldn't remove your tag" if the call fails.
- Your tag notification is deleted; the owner gets nothing; the owner cannot re-tag you in that post for 24 hours (`tag_removals`).
- Profile tile (entry 3): animates out in 200 ms; an empty tab uses the "No tagged posts yet" state (profile spec).
- `remove_my_tag` returns false when you were not tagged (already removed elsewhere): treat as success, refresh the card.

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| tagYoureTagged | You're tagged in this post | تم وسمك في هذا المنشور |
| tagRemoveMe / sub | Remove me from this post / You won't be tagged anymore | أزلني من هذا المنشور / لن يتم وسمك بعد الآن |
| tagRemoveLabel | Remove tag | إزالة الوسم |
| tagRemoveTitle | Remove your tag? | إزالة وسمك؟ |
| tagRemoveBody | You'll no longer be tagged in {name}'s post or its photos. The post itself stays. | لن يتم وسمك بعد الآن في منشور {name} أو صوره. يبقى المنشور كما هو. |
| tagRemoveConfirm / Cancel | Remove / Cancel | إزالة / إلغاء |
| tagRemovedNotice / sub | Tag removed / You're no longer tagged in this post. | تمت إزالة الوسم / لم يعد وسمك في هذا المنشور. |
| tagRemoveError | Couldn't remove your tag | تعذّرت إزالة وسمك |

## Data mapping
`rpc('remove_my_tag', {p_post})` -> bool. `home_feed.i_am_tagged` decides whether S2 shows the row. Use case in `features/post` (`RemoveMyTagUseCase`), called by `PostActionsCubit`.

## Acceptance checklist
- [ ] S2 shows the tagged line and a highlighted "Remove me from this post" as the first row for a tagged viewer.
- [ ] Own label is a white card with danger "Remove tag"; other labels stay dark.
- [ ] One destructive dialog from every entry; result notice "Tag removed"; headline and labels update in place.
