# S5 Edit post

Edit post is the New post screen (`s1-new-post.md`) opened on an existing post: one screen, `AddEditPostScreen`, route `/edit/post` with the `PostEntity` as argument (`/create/post` opens it empty). Opened from the owner's options sheet (S2, row "Edit post"). Layout, tokens and dimens are S1's; only the differences are listed.

| Part | Edit post |
|---|---|
| Title | "Edit post" |
| Fields | everything on S1: caption, audience chip, photo / video, tag people (S6/S7, starting from the post's tags and spots), location, feeling / activity (S8/S9, starting from the post's mood), comments switch; all start from the post [user: edit covers caption, feeling, location and tags, board 2 panel 6] |
| Media strip | the post's own photos and videos first, then files added now, then the Add tile; each item has Remove; new files are appended (no reordering) |
| Audience | the post's own audience, not the account default; the picker is the S4 "choose" sheet, applied on Save |
| Primary button | "Save" (S1: "Share post"); enabled when something changed and the post keeps a caption or media |
| Close | asks "Discard changes?" when there are unsaved changes; nothing closes it while saving |
| Success | closes, notice "Post updated"; Home reloads the feed |
| Failure | stays open, notice "Couldn't save your changes" with Retry |

Tags: removing a person here sends no notification; a person who removed their own tag in the last 24 h is dropped silently when re-added. Removing a photo clears the spots on it (those people stay tagged in the post). New tags notify the person.

Data: `UpdatePostUseCase` sets a changed comments switch and audience (shared `set_content_audience`), then rpc `update_post` (migration `edit_post`, extended by `post_tags_mood` with mood and tags) replaces caption, location, mood, tags and the media list. New files upload under names no existing file has; files the post no longer uses are removed after the save.
