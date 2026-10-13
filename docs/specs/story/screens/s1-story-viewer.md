# Story viewer (S1)
Screenshot: `../screenshots/stories-board.png` panels 1 and 2. Route `/story/:authorId`, full screen over the shell (nav hidden). Opened from the Home rail.

## Layout tree (panel 1: someone else's story)
```
Stack (black)
├─ Media full-bleed (image or video via video_flux), top and bottom shades
├─ Overlays (stickers: text, location) positioned/scaled as saved
├─ Top: progress segments (one per story of this person) / Header row: avatar 36 + name + time ... "···" ... X
└─ Bottom: reply pill "Send a message…" + heart 28 + send 26
```
Panel 2 (your own story): same viewer with header "Your story 5h" (avatar "ME"), bottom shows an **eye with the count ("24")** instead of the reply pill; swipe up opens the viewers sheet (24 viewers, delete, save).

## Elements
See `../01-design-tokens.md` > Viewer. Name = username (e.g. "nour.adel"); time = relative (2h); "···" menu = S6 (`s6-viewer-menus.md`); sticker text uppercase.

## States
| State | UI |
|---|---|
| Playing | progress fills; image 5 s, video its length |
| Paused (hold) | UI fades out, progress stops |
| Keyboard open (reply) | pill pushed up, story paused |
| Loading media | blurhash/thumb until ready; preload the next story's media while one plays [board] |
| Own story | eye + count at the bottom; viewers sheet on swipe up |
| Viewers sheet | list newest first, heart if liked; Delete (confirm dialog) and Save to device |
| Error | media fails: skip with a retry tap [estimated] |
| End | last story of the last person: close; end of a person: next person |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| storyReplyHint | Send a message… | أرسل رسالة… |
| storyYourStory | Your story | قصتك |
| storyViewers | {count} viewers | {count} مشاهدين |
| storyDeleteTitle | Delete this story? (copy [estimated]) | حذف هذه القصة؟ |
| storyDeleteBody | It will be removed for everyone. (copy [estimated]) | ستتم إزالتها للجميع. |
| storySaved (notice) | Saved to your device (estimated) | تم الحفظ على جهازك |
| semantics | Close, More, Like, Send, Viewers | إغلاق، المزيد، إعجاب، إرسال، المشاهدون |

## Behavior and navigation
- Tap right = next story, left = previous; hold = pause; swipe down = close; swipe left = next person [board].
- Mark seen: insert `story_views` when a story has shown for 1 s+ [board].
- Heart: `set_story_like` (optimistic). Replies are not built: they go to Chat when it exists [user].
- Own story: swipe up = viewers sheet; Delete -> confirm dialog (existing `ConfirmationDialog.destructive`); Save downloads the media.
- Starts at the first unseen story of that person; after the last story of the last person in the rail order, close.

## Data mapping
| UI | Source |
|---|---|
| Rail order | `GetStoryRailUseCase` (existing) |
| A person's stories | `rpc('author_stories', {p_author})` (RLS hides expired; `seen_by_me`, `liked_by_me`, own `view_count`, `overlays`) + signed URLs for `path`/`thumb_path` |
| Seen | insert `story_views` (viewer, story) |
| Viewers list | `rpc('story_viewers', {p_story})`: user, viewed_at, liked, total |
| Delete | delete own `stories` row + storage object |

## Responsive / a11y
Full-bleed, safe areas respected (top 54 + inset). Targets >= 44. Reduce motion: no fade of UI on hold [estimated]. RTL: tap zones swap (start = previous, end = next), progress fills from the start side, swipe-left becomes swipe-right for "next person" [estimated].

## Acceptance checklist
- [ ] Segments per story, 3 high, gap 4, filling in order.
- [ ] Header avatar with white ring, name bold, time dimmer, "···" and X at the end.
- [ ] Reply pill with white border, heart and send icons.
- [ ] Location sticker tilted -4°, white with green uppercase text.
- [ ] Tap/hold/swipe gestures; keyboard pauses.
- [ ] Own story: eye count and viewers sheet with delete + save.
