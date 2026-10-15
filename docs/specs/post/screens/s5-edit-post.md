# S5 Edit post

Edit post is the New post screen (`s1-new-post.md`) opened on an existing post: one screen, `AddEditPostScreen`, route `/edit/post` with the `PostEntity` as argument (`/create/post` opens it empty). Opened from the owner's options sheet (S2, row "Edit post"). Layout, tokens and dimens are S1's; only the differences are listed.

| Part | Edit post |
|---|---|
| Title | "Edit post" |
| Fields | everything on S1: caption, audience chip, photo / video, tag people, location, feeling, comments switch; all start from the post |
| Media strip | the post's own photos and videos first, then files added now, then the Add tile; each item has Remove; new files are appended (no reordering) |
| Audience | the post's own audience, not the account default; the picker is the S4 "choose" sheet, applied on Save |
| Primary button | "Save" (S1: "Share post"); enabled when something changed and the post keeps a caption or media |
| Close | asks "Discard changes?" when there are unsaved changes; nothing closes it while saving |
| Success | closes, notice "Post updated"; Home reloads the feed |
| Failure | stays open, notice "Couldn't save your changes" with Retry |

Data: `UpdatePostUseCase` sets a changed comments switch and audience (shared `set_content_audience`), then rpc `update_post` (migration `edit_post`) replaces caption, location and the media list. New files upload under names no existing file has; files the post no longer uses are removed after the save.
