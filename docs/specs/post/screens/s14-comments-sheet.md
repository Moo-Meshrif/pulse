# Comments sheet (S14)
Screenshot: `../screenshots/s14-comments-board.png` (6 panels + Tokens / Behavior / Data notes). Opened from the comment icon on a post card and from the post page (S15). Replaces the placeholder comments route (`TODO(home-plan H3)`); the same list and composer are drawn inline on S15 (see `s15-post-page.md`). One reply level, like the database [user, board].

## Layout tree (panel 1)
```
Sheet over the post (white, top radius 28, top gap 88 dp from the screen top, draggable to full height; grabber; scrim; AppSafeArea)
├─ Header: "Comments" (Sora 18/700) + sort chip at the end (h 32, background, "Most relevant" + chevron-down)
├─ Divider
├─ List (scrolls)
│    ├─ Comment row (top level): padding 8 4, avatar 36, gap 10
│    │    ├─ name 13/700 + time 12 textSecondary (author gets the "Author" badge)
│    │    ├─ text 14/1.45
│    │    ├─ line: "Reply" (12/600 textSecondary) + "{n} likes" (12/600 textSecondary)
│    │    └─ heart at the end (outline; filled red when liked; likes by you)
│    ├─ Replies: indented 50, avatar 28, same row; "Author" badge: 18 high, primarySoft background, primary text 10/700
│    ├─ "View {n} more replies" line (12/700, a 24 dp dash before it), 3 replies show first
│    └─ Load more at the end of the list (20 top-level per page)
├─ Divider (off `divider`)
└─ Composer (pinned, rides above the keyboard)
     ├─ Emoji row (22): heart, raised hands, fire, clap, cry, heart-eyes, surprised, laughing; tap inserts the emoji at the cursor
     └─ Row: your avatar 36 + field (h 44, r22, `background`; focus ring 1.5 primary) + send (40 circle: primary when there is text, `divider` off)
```
Tokens [user, board notes]: sheet radius 28, top 88; header Sora 18/700; sort chip 32 on `background`; row padding 8 4; avatar 36 (reply 28, indent 50); gap 10; name 13/700; time 12; Reply / likes 12/600 `textSecondary`; heart 18 [user, was 16]; liked heart color `like`; text 14/1.45; Author badge 18 `primarySoft` / `primary` 10/700; "View N more replies" 12/700 with a 24 line; highlight `primarySoft`; posting 55% opacity; failed uses `warningInk`; composer emoji row 22, avatar 36, field 44 r22 `background`, send 40 circle, off = `divider`.

## Panels
| # | Panel | Content |
|---|---|---|
| 1 | Comments sheet | as the tree. Heart red on a comment you liked (12 likes example) |
| 2 | Replying | tapping Reply opens the thread: the parent gets a `primarySoft` highlight with its replies under it; the field starts with `@name ` and a strip above the composer "Replying to **@mariam.h**" + X. Send turns primary when there is text beyond the `@name`. Replies always attach to the **top-level** comment, even when you reply to a reply |
| 3 | Long-press on someone's comment | the comment gets a darker highlight, the list dims; a sheet slides up: six emoji circles (heart, raised hands, fire, clap, cry, heart-eyes), then a card with **Reply**, **Copy text**, then a card with **Hide comment** (post owner only) and **Report comment** (red). Tapping an emoji closes the sheet and **adds it to the reply field** (opens the reply as Reply does) [user]. Double-tap a comment likes it |
| 4 | Your comment states | optimistic: your comment shows at once at 55% opacity with "Posting…". On failure: amber line "Couldn't post · Retry · Delete" (warningInk). Long-press your own: **Edit**, **Copy text**, **Delete** (confirm dialog) |
| 5 | Empty | `ic_comment` at 56, "No comments yet" (Sora 16/700), "Start the conversation." (13 textSecondary); keyboard opens when the sheet came from the comment icon |
| 6 | Mentions | typing `@` + letters shows a suggestions card above the composer: 3 rows (avatar 36, name 14/700, @username 12 textSecondary), the first highlighted `primarySoft`. Sources: your followers + people in this thread. Pick inserts `@username ` and the people mentioned get a mention notification |

## Behavior
- **Tap on `@name`** in a comment opens that profile; the profile screen is a placeholder, leave `// TODO(post-plan T23)` there [user].
- **Sort** [user]: chip opens a small popup under it with two rows, "Most relevant" and "Newest", the current one checked; choosing reloads from the top. Most relevant = replies by the post author and comments you liked first, then newest [board]; Newest = time descending.
- **Paging:** page of 20 top-level comments (keyset on the time); each shows its first 3 replies, "View N more replies" loads the rest of that thread; no pull to refresh [user]; any load error (first page, more comments, more replies) shows the shared error tile or row with **Try again**.
- **Max 1000 characters:** counter appears after 900 ("930 / 1000"); send is disabled while the text is empty [board]. The keyboard "send" key sends.
- **Edit** [user]: the text goes into the composer, a strip "Editing comment" + X (like Replying); send saves; the row then shows "Edited" after the time. Replies stay. Cancel (X) restores the empty field.
- **Delete** your own comment: a confirm dialog (shared ConfirmationDialog, delete tone); a top-level comment takes its replies with it [board].
- **Hide comment** (post owner, not your own comment): the comment disappears for everyone except its writer, who still sees it normally [board]. A toast "Comment hidden" with an **Undo** action shows the comment again for everyone [user]; once the toast is gone there is no way to unhide it.
- **Report comment:** the shared report sheet (reasons as posts) with a new `comment` kind [user]; then the same "Thanks for reporting" row.
- **Copy text** copies the body and shows a toast "Copied".
- **Like:** heart toggles optimistically; count under the row ("1 like" / "12 likes"; no count at zero); double-tap on the row likes it (never unlikes) [board].
- **Comments off (3.15):** the old comments stay and are read-only; the composer and emoji row are replaced by a bar "Comments are turned off for this post" (see `../02-components.md` "Post page when comments are off"). Long-press still gives Copy text and Report; Reply is hidden.
- **Failed post:** Retry sends again with the same client id (no duplicates); Delete drops it.
- Closing the sheet with text in the field keeps the draft for this post until the app is closed [user]; sending clears it.
- Offline: first load shows the shared error tile with Try again; sending offline shows the failed state of panel 4.
- Blocked or hidden-by-audience post: the sheet never opens (the post page shows "not available").

## Data
| Call | Use |
|---|---|
| `rpc('post_comments', {p_post, p_sort, p_limit, p_before})` | top-level comments with author, like count, `liked_by_me`, reply count, first 3 replies, `edited_at`, `is_post_author`; hidden ones only for the writer; keyset paging |
| `rpc('comment_replies', {p_comment, p_limit, p_before})` | the rest of one thread |
| `rpc('add_comment', {p_post, p_body, p_parent, p_client_id})` | client id so Retry is safe; replies go to the top-level parent; mentions parsed on the server |
| `rpc('set_comment_like', {p_comment, p_liked})` | idempotent like / unlike |
| edit / delete / hide / report | `edit_comment`, `delete_comment`, `hide_comment(p_comment, p_hidden)` (post owner only; Undo calls it with false), shared report with kind `comment` |
| `comment_mention_candidates(p_post, q)` | followers + people in the thread, 3 rows |
Existing: `comments(id, post_id, author_id, parent_id, body, created_at)`, `posts.comment_count`. Add: `comment_likes(comment_id, user_id)`, `comments.like_count`, `reply_count`, `edited_at`, `hidden_at`. Notifications for comment / reply / mention already exist (`notifications` migration). The migration is written and validated in the backend phase of the plan; the exact SQL is not in the spec yet [user: board notes].

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| commentsTitle | Comments | التعليقات |
| commentsSortRelevant / Newest | Most relevant / Newest | الأكثر صلة / الأحدث |
| commentsAuthorBadge | Author | الكاتب |
| commentReply | Reply | رد |
| commentLikes | {count, plural, one{1 like} other{{count} likes}} | {count, plural, one{إعجاب} other{{count} إعجابات}} |
| commentsViewMoreReplies | View {count} more replies | عرض {count} ردود أخرى |
| commentsAddHint | Add a comment… | أضف تعليقًا… |
| commentsReplyingTo | Replying to {name} | الرد على {name} |
| commentsEditing | Editing comment | تعديل التعليق |
| commentsPosting | Posting… | جارٍ النشر… |
| commentsCouldntPost | Couldn't post | تعذّر النشر |
| commentsRetry / commentsDelete | Retry / Delete | إعادة المحاولة / حذف |
| commentsEdited | Edited | تم التعديل |
| commentsEmptyTitle / Body | No comments yet / Start the conversation. | لا توجد تعليقات بعد / ابدأ المحادثة. |
| commentsCopyText / Edit / Hide / Report | Copy text / Edit / Hide comment / Report comment | نسخ النص / تعديل / إخفاء التعليق / الإبلاغ عن التعليق |
| commentsDeleteTitle / Body | Delete comment? / This also deletes its replies. | حذف التعليق؟ / سيتم حذف الردود أيضًا. |
| commentsHidden / Copied | Comment hidden / Copied | تم إخفاء التعليق / تم النسخ |
| commentsUndo | Undo | تراجع |
| commentsCounter | {count} / 1000 | {count} / 1000 |
| commentsOff | Comments are turned off for this post | التعليقات متوقفة لهذا المنشور |
Existing keys reused: report strings, `confirmationDialog` strings where they fit.

## Assets
Existing: `ic_comment`, `ic_heart`, `ic_heart_filled`, `ic_chevron_down`, `ic_close`, `ic_eye_off`, `ic_flag`, `ic_edit`, `ic_trash`, `ic_check`, `ic_chat_bubble`. **Added by the user 2026-10-25 (register in `app_assets.dart`):** `ic_reply` (long-press Reply row), `ic_copy` (Copy text), `ic_send` (composer send). Clock for "Posting…" and warning for the failed line: `ic_clock`, `ic_warning` exist.

## RTL
Indent and heart mirror; avatars lead. Time and counts follow the text direction; `@name` keeps its LTR order in an Arabic sentence (wrap in an LTR isolate).

## Acceptance checklist
- [ ] Panel 1 matches: header, chip, rows, replies indent, badge, View N more replies
- [ ] Reply opens the thread with highlight, @name and the Replying strip; reply to a reply attaches to the top-level comment
- [ ] Long-press sheet for someone else's (Reply, Copy, Hide for the owner, Report) and your own (Edit, Copy, Delete); emoji add to the field
- [ ] Posting 55% / failed amber with Retry and Delete; Retry never duplicates
- [ ] Empty state; mentions list with 3 rows; comments-off bar
- [ ] EN + AR, 1.5x, 320 dp, wide window
