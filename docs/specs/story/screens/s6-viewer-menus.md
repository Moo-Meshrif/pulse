# Story viewer: options, report, delete (S6)
Screenshot: `../screenshots/stories-board-v2.png` panels 7-10. Extends S1; answers Q6 [user via board].
All open with the story **paused** (small "Paused" chip under the header, header faded, progress frozen); the story resumes on close.

## Panel 7: options on someone's story (dark sheet, grabber)
Group 1: **Mute @nour.adel** + subtitle "Hide their stories from your rail" (`ic_volume_off`) · **Go to profile** (`ic_user`) · **Copy link** (`ic_link`). Group 2 (red text): **Report story** (`ic_flag`).
- Mute: hides that person's stories from the rail and skips them in the viewer; undo from a notice [board]. Backend: shared `set_mute(p_scope: 'stories')` + `story_mutes` (was `set_story_mute`; code path is the shared `SetMuteUseCase` with `MuteScope.stories`, the story keeps its own rail refresh); `story_rail` skips muted authors.
- Go to profile: opens their profile. Copy link: copies the story link + notice.

## Panel 8: options on your story
Group 1: **Save to device** (`ic_download`) · **Who can see this** (`ic_audience`) + subtitle "Followers" (read-only for now: no picker, so no chevron [user, Q18]) · **Viewers** + subtitle "24" (`ic_eye`; opens the viewers sheet). Group 2 (red): **Delete story** (`ic_trash`).
No Report, Mute or Go to profile [board].
"Who can see this" subtitle = audience (Q7 answered: "Followers", "Public" for public accounts [user]).
Save: media with stickers and text burned in [board].

## Panel 9: Report story
Dark sheet: title "Report story", body "Why are you reporting this story? Your report is anonymous." Rows with chevron: Spam · Nudity or sexual content · Hate speech or symbols · Bullying or harassment · Violence or dangerous acts · False information · Something else. Same reasons and flow as **Report post** (post feature), including the Something-else note step; after sending: thanks screen, then the viewer skips to the next story. Backend: `report_story(p_story, p_reason, p_note)` (schema extras section 4).

## Panel 10: Delete confirm
Dark dialog over the paused story: red `ic_trash`, "Delete this story?", "It will be removed for everyone, along with its 24 views. You can't undo this." (count = view count), red **Delete** button, **Cancel** text. After delete: notice "Story deleted"; go to your next story, or close the viewer if it was the last [board].
Use `ConfirmationDialog.destructive` on a dark surface variant; dark sheet/dialog surface `#1F2423` [user, Q15].

## Viewers sheet (own story, panel 2 of board)
White sheet (light), grabber, header eye + "24 viewers" with red-tint **delete** circle and **save** circle; rows avatar + name + @username, red outline heart when they liked it; newest first.

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| storyPaused | Paused | (to draft) |
| storyMute | Mute @{username} | (to draft) |
| storyMuteHint | Hide their stories from your rail | (to draft) |
| storyGoToProfile | Go to profile | (to draft) |
| storyCopyLink | Copy link | (to draft) |
| storyReport | Report story | (to draft) |
| storyReportBody | Why are you reporting this story? Your report is anonymous. | (to draft) |
| storySaveToDevice | Save to device | (to draft) |
| storyWhoCanSee | Who can see this | (to draft) |
| storyViewersItem | Viewers | المشاهدون |
| storyDelete | Delete story | (to draft) |
| storyDeleteTitle | Delete this story? | حذف هذه القصة؟ |
| storyDeleteBody | It will be removed for everyone, along with its {count} views. You can't undo this. | (to draft) |
| storyDeleted | Story deleted | (to draft) |
| cancel / delete | reuse shared | |

## Acceptance checklist
- [ ] "Paused" chip while any sheet or dialog is open; resumes on close.
- [ ] Two grouped cards per sheet; red group for destructive/report.
- [ ] Own: Save, Who can see this (Followers), Viewers (24), Delete. Others: Mute, Go to profile, Copy link, Report.
- [ ] Report reasons list identical to Report post.
- [ ] Delete dialog with red button and Cancel.

## Shared code update [user, 2026-10-14]
Report goes through the shared `ReportContentUseCase` (`ContentKind.story`, RPC `report_content`, replaces `report_story`); mute through the shared `SetMuteUseCase`; deleting a story removes its row, then its files through the shared `RemoveMediaFilesUseCase` (best effort: a failed cleanup no longer fails the delete). Code lives in `lib/shared/content`.
