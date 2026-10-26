# Post page (S15) and Likes list (S16)
Screenshot: `../screenshots/s15-post-page-board.png` (5 panels + Tokens / Behavior / Data notes). One post with everything: full caption, media, likes, comments. Reached from the feed, notifications, links, chat and shares [board]. Replaces the "comments route" targets of `TODO(post-plan T21)` (the framed original on a share, the story sticker's View post).

## Layout tree (panel 1)
```
Scaffold (background `background`)
├─ Top bar 52 + status: back 44 (ic_arrow_back, mirrors) · title "Post" (Sora 18/700) · more 44 (ic_more_horizontal, opens S2 for this post)
└─ Scroll
     ├─ Post card (white, r22) = the feed card (3.1, 3.15) with: full caption 15/1.5 (no "more"), hashtags 600 `primary`, media up to 4:5 + dots below + "1/3" chip
     │    ├─ Author row as P2/P2a-P2c; Follow chip 32 `primary` on the end (hidden on your own posts; "Following" once you follow)
     │    ├─ Actions: heart + 1.2K, comment + 86, send, bookmark at the end (as P5)
     │    ├─ "Liked by" row: avatars 22 overlapping -6 + "Liked by **salma.ash** and **1,203 others**" (13 text, names bold)
     │    └─ Date line "October 25, 2026 · 6:42 PM" (12 textSecondary)
     ├─ Comments section (white, r22): header "Comments" (Sora 16/700) + sort chip 30 ("Most relevant"), then the S14 rows inline (no sheet)
     └─ Composer pinned at the bottom (emoji row + field), exactly the S14 composer
```
Tokens [board]: top bar 52 + status, back 44, title Sora 18/700, more 44; mini author when scrolled: avatar 28, 15/700; card = feed card with full caption 15/1.5; media 4:5 max with dots and "1/3" chip; Follow chip 32 `primary`; liked-by avatars 22 overlap -6, text 13; date 12 `textSecondary`; comments section white r22, header Sora 16/700, sort chip 30; rows as S14.

## Panels
| # | Panel | Content |
|---|---|---|
| 1 | Post page | as the tree. Opened from a tap on the caption or time, a notification, a shared link or a chat bubble |
| 2 | Scrolled | once the author row leaves the screen the title becomes a mini author (avatar 28 + name) with a divider under the bar. Comments load 20 at a time; replies collapse to "View N more replies" |
| 3 | From a notification | a comment, reply or mention notification opens the page with that comment **first in the comments list** [user], highlighted `primarySoft`, fading after 2 s (no scrolling needed), and a small dark chip "From your notification" (with the comment icon) under the bar for 2 s. Route `/p/:postId?comment=:id`; the targeted comment goes to the top, then the usual list follows without repeating it. For a reply, its parent comment is shown first with the reply highlighted under it, then the usual list. If the comment was deleted or hidden, the list is the usual one and the chip is not shown |
| 4 | Likes | tap "Liked by …" opens S16 |
| 5 | Not available | bare `ic_lock_closed` 72, "This post isn't available" (Sora 16/700), "It may have been deleted, or the owner limited who can see it." (14 textSecondary), "Back to Home" primary pill. Used for deleted, private author you don't follow, audience changed and blocked. The back arrow and "..." stay |

## Behavior
- **Route:** `/p/:postId` (+ `?comment=:id`); deep links, notifications, share-card original and story sticker all use it [board]. The old route `/post/:postId/comments` opens this page with the comment field focused; the S14 sheet is opened by the comment icon on a card (`CommentsSheet.show`) [plan decision, confirm].
- **From the feed:** the hero media is passed with the loaded post so the page shows at once, then refreshes (`get_post`) [board]. Likes, comments and saves update the page and the feed card together (same shared post state) [board].
- **More (...)** opens S2 (Post options) for this post; **comments off** shows the bar instead of the composer (`../02-components.md`).
- **Video** plays with sound on this page (muted in the feed) [board].
- **Comments:** same data, rows and actions as S14; the sort chip here works the same; "Add a comment…" focuses the field; the comment icon in the actions scrolls to the section and focuses the composer [user].
- **Follow chip:** follows the author; after it succeeds the chip stays and reads "Following" (outline); tapping it unfollows with no confirm [user]. Hidden only on your own posts.
- **Offline:** the passed post stays visible; failed refresh shows the shared error toast; with nothing to show, the shared error tile with Try again.

## S16 Likes list (panel 4) [user: "take the likes design from the details board"]
```
Scaffold: top bar 52 (back 44, title "Likes · 1,204" Sora 18/700, more 44 only as in the board)
├─ Search field (h 44, white, magnifier, "Search")
└─ White card r22 with rows: avatar 44, name 14/700 over @username 12 textSecondary, button at the end:
     "Following" (outline), "Follow" (primary), "Follow back" (primary) for people who follow you
```
- Who appears: the **author sees everyone**; others see the people they are allowed to see (private accounts hidden) [board]. Search filters by name or username (server side, after 300 ms without typing [user]).
- Paged (`PagedScrollView`): `rpc('post_likers', {p_post, q, p_limit, p_before})` returns profiles + follow state. Row tap opens the profile (`/profile` placeholder until it exists); the button follows / unfollows (Following asks nothing, tapping it unfollows at once, no confirm dialog [user]).
- Empty search: shared "No results" tile; zero likes: not reachable (the row is hidden when there are none).
- The "Liked by" preview uses `rpc('liked_by_preview', {p_post})` → first follower who liked + 2 avatars + total [board]. For a post with no likes the row is hidden.

## Data
| Call | Use |
|---|---|
| `rpc('get_post', {p_post})` | same row shape as `home_feed` (author, media[], counts, liked / saved by me, tags, mood, visibility, comments_enabled, shared original); null when not visible |
| `rpc('post_likers', {p_post, q, p_limit, p_before})` | S16 |
| `rpc('liked_by_preview', {p_post})` | the "Liked by" row |
| comments | `post_comments` / `comment_replies` (S14); `?comment=` : `post_comments` gets an optional `p_focus` (comment id): the page starts with that comment (or its parent thread) and leaves it out of the normal rows [user] |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| postPageTitle | Post | المنشور |
| postFollow | Follow | متابعة |
| postLikedBy | Liked by {name} and {count} others | أعجب {name} و{count} آخرين |
| postLikedByOne | Liked by {name} | أعجب {name} |
| postFromNotification | From your notification | من إشعارك |
| postUnavailableTitle | This post isn't available | هذا المنشور غير متاح |
| postUnavailableBody | It may have been deleted, or the owner limited who can see it. | ربما تم حذفه، أو قيّد صاحبه من يمكنه رؤيته. |
| postBackToHome | Back to Home | العودة إلى الرئيسية |
| likesTitle | Likes · {count} | الإعجابات · {count} |
| likesSearchHint | Search | بحث |
| followFollowing / followFollowBack | Following / Follow back | تتابعه / رد المتابعة |
Existing keys reused: S14 strings, P11 "Post unavailable" where it fits (different copy here: the board's long text).

## Acceptance checklist
- [ ] Panel 1: full caption, media with dots and chip, Follow chip rules, Liked by row, date, comments section, pinned composer
- [ ] Scroll swaps the title for the mini author; comments page by 20
- [ ] Notification open: targeted comment first in the list, highlight fades after 2 s, chip for 2 s
- [ ] Likes list: search, Follow / Following / Follow back; author sees all, others only visible people
- [ ] Not available state for deleted / hidden / blocked; Back to Home works
- [ ] Share-card original and story sticker open this page (markers T21 removed)
- [ ] EN + AR, 1.5x, 320 dp, wide window
