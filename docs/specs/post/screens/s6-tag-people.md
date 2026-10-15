# Tag people (S6)
Screenshot: `../screenshots/s6-tag-feeling-board.png` (board 1, panels 1 and 2). Opened from New post / Edit post > "Tag people" row (S1, S5). Page style = Add location (S3).
Purpose / route: choose up to 20 people to tag in the post; `/create/post/tag-people`, full page pushed on the root Navigator, returns the chosen list (user ids + display data) on Done [user].

## Layout tree
```
Scaffold (background)  [AppSafeArea]
└─ Column
   ├─ Header 56: back 44 (start) · title "Tag people" (Sora 20/700) · "Done" pill (end, 36 high, r18, primary fill, white 14/700)
   ├─ Search field: h 48, r24, white, search icon 20 + "Search people"; focused = 2 px primary ring + clear button 28 (×)
   ├─ Chip row (only when >= 1 chosen): horizontal scroll, gap 8
   │    chip: h 36, r18, primarySoft; avatar 28 + name 13/700 primary + remove × (22 white circle)
   ├─ Section row (only with a blank search): "SUGGESTED" (section 13/700 UPPERCASE) ........ "3 / 20" (12 textSecondary)
   ├─ Expanded list: white card r22, rows 64, avatar 44, name 15/700, @username 13 textSecondary; check 24 at end
   └─ "Tag in photo" button (only when the post has photos; disabled until >= 1 person is chosen [user]): pinned at the bottom above the inset, full width minus 20, h 48, outlined (1 px `primary`, primary 15/700) with `ic_image` 18 [user: estimate accepted]
```
Search state (panel 2): the Suggested row and chip row stay as they are; the list shows matches for the typed text (rows keep the same style); keyboard open, list scrolls above it.

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Back | | 44 target | `ic_arrow_back` textPrimary | returns without saving; confirm only if the list changed ("Discard changes?" reuse S1 dialog) [estimated] |
| Done | "Done" | 36 high | primary pill | enabled once someone is chosen or the list changed (so clearing still works); returns the list |
| Chip | name (full name first word or username) | 36 | primarySoft | tap × removes the person |
| Check | | 24 | on: primary fill + white `ic_check`; off: 2 px #9AA6A2 circle | [seen] |
| Disabled row | "Doesn't allow tags" | row opacity 50% | `ic_block` 12 + 12 textSecondary under the name | no check shown; tap does nothing [seen] |
| Counter | "3 / 20" | | caption 12 `textSecondary` | turns `danger` at 20 [user] |

## States
| State | UI |
|---|---|
| Loading | `PulseLineLoader` width 44 centered under the search (first load and each search) |
| Suggested | blank search: people I follow, newest follow first (`tag_search(null)`), max 30 |
| Search | `tag_search(q)`: followers and people I follow, username starts with / name contains q; 300 ms debounce; blank again = suggested |
| No results | existing `AppEmpty` with `ic_search` and "No people found" [user, 2026-10-15: `CompactStateView` / `ic_not_found` do not exist, use what exists] |
| Max reached | 20 chosen: counter turns `danger`, unchosen rows drop to 50% and cannot be picked, tapping one shows the notice "You can tag up to 20 people" [user] |
| Error | notice "Couldn't load people. Retry" with Retry |
| Disabled person | row at 50% + "Doesn't allow tags" (`can_tag = false`), cannot be picked |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| tagPeopleTitle | Tag people | وسم الأشخاص |
| tagPeopleSearch | Search people | ابحث عن أشخاص |
| tagPeopleSuggested | Suggested | مقترحون |
| tagPeopleDone | Done | تم |
| tagPeopleNoTags | Doesn't allow tags | لا يسمح بالوسم |
| tagPeopleMax | You can tag up to 20 people | يمكنك وسم 20 شخصًا كحد أقصى |
| tagPeopleEmpty | No people found | لا يوجد أشخاص |
| tagPeopleInPhoto | Tag in photo | الوسم في الصورة |
| tagPeopleError | Couldn't load people. Retry | تعذّر تحميل الأشخاص. أعد المحاولة |
Counter "3 / 20" uses the locale numerals rule in `rtl.md`.

## Behavior and navigation
- Tap a row = toggle; the person appears or leaves the chip row at once. Max 20, no duplicates, never yourself (server also enforces).
- Chips in picking order; the New post row shows the first two names + "and N other(s)".
- Done returns `List<TagChoice>` (id, username, fullName, avatarUrl, and any photo spot kept from S7). A person removed here loses their S7 spot.
- Photo spots are set in S7, opened by the "Tag in photo" button (needs photos and at least one chosen person); S7 returns here, then Done returns to New post [user]. This page itself only chooses people.

## Data mapping
| UI | Source |
|---|---|
| Rows | `rpc('tag_search', {p_q, p_limit})` -> id, username, full_name, avatar_url, can_tag |
| Chips and counter | local list |
| Result | into `NewPost.tags` -> `create_post(p_tags)` / `update_post(p_tags)` |

## Responsive / a11y
`ContentWidth` on wide screens; keyboard pushes the list up. Rows >= 44 targets; semantics: "{name}, tagged / not tagged", check is a checkbox; chip × "Remove {name}". RTL: back, Done and chips mirror; chip row scrolls from the end; avatar before name.

## Acceptance checklist
- [ ] Header, search pill, chips, SUGGESTED + counter, white list card with green checks as the board.
- [ ] Search panel: focused ring, clear ×, filtered list, disabled "Doesn't allow tags" row at 50%.
- [ ] 20 max, counter updates, Done returns to New post with names in the row.
- [ ] AR: mirrored, Arabic font.
