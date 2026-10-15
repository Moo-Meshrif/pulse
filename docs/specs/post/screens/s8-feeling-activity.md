# Feeling / activity (S8)
Screenshot: `../screenshots/s6-tag-feeling-board.png` (board 1, panels 4 and 5). Opened from New post / Edit post > "Feeling / activity" row (S1, S5). Page style = Add location (S3).
> **Built now: Feelings only.** The Activities tab is deferred [user, 2026-10-15]: the segmented control keeps both tabs, tapping "Activities" shows the notice "Coming soon" and stays on Feelings. TODO: activities (list, verbs, suggestions in S9) come later from an API or a database; everything about activities below is for that day, not for the first build.

Purpose / route: choose one feeling or one activity verb; `/create/post/feeling`, full page; returns a `PostMood` or none [user].

## Layout tree
```
Scaffold (background)  [AppSafeArea]
└─ Column
   ├─ Header 56: back 44 · title "How are you feeling?" (Sora 20/700) · "Remove" (end, 15/700 danger; only when a mood is set)
   ├─ Segmented control: h 44, r22, `divider` fill; two segments "Feelings" | "Activities"; thumb white r22
   ├─ Search field: h 48, r24, white; "Search feelings" / "Search activities"
   └─ Expanded scroll
        Feelings tab: 2-column grid, gap 8; tile h 52, r16, white; emoji 22 + word 15/600
        Activities tab: white card r22, rows 64: emoji tile 44 + verb "Celebrating…" 15/600 + chevron 18 (mirrors in RTL)
```

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Feeling tile | emoji + word | 52 high | white; selected = `primarySoft` + 1.5 inset `primary` + `ic_check` 16 primary at end | one choice; tap again clears it [seen] |
| Activity row | emoji + "Watching…" | 64 | white card | opens S9 for that verb |
| Remove | "Remove" | | `danger` 15/700 | clears the mood (feeling or activity) and returns |
| Segmented | Feelings / Activities | 44 | `divider`, white thumb | the tab opens on the current mood's kind, else Feelings |

Feelings (14, key -> emoji, in this order): happy 😊 · excited 🥳 · loved 😍 · relaxed 😌 · grateful 🙏 · motivated 💪 · cool 😎 · amazed 🤩 · tired 😴 · sad 😢 · determined 😤 · sick 🤒 · funny 😂 · blessed 😇 (panel 4 reading order: 2 columns, left then right) [seen].
Activities (10, key): celebrating 🎉 · watching 📺 · eating 🍽️ · drinking ☕ · traveling ✈️ · listening 🎧 · reading 📖 · playing 🎮 · working_out 🏃 · attending 🎟️ [seen; emoji are the board's, native characters, user choice].

## States
| State | UI |
|---|---|
| Nothing chosen | no Remove; no tile selected |
| Feeling chosen | tile selected; tap another switches; Remove visible |
| Activity chosen | Activities tab, that row shows its text under the verb ("the derby with dad", textSecondary 12); Remove visible |
| Search | filters the current tab by EN + AR keywords (word and a few synonyms, kept in code); "No results" = `ic_search` 56 + "No matches" [estimated] |
| Both mixed | feeling and activity are mutually exclusive: choosing one clears the other (board note: one line on the card) |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| feelingTitle | How are you feeling? | كيف تشعر؟ |
| feelingRemove | Remove | إزالة |
| feelingTabFeelings / Activities | Feelings / Activities | المشاعر / الأنشطة |
| feelingSearch / activitySearch | Search feelings / Search activities | ابحث عن المشاعر / ابحث عن الأنشطة |
| feelings | happy, excited, loved, relaxed, grateful, motivated, cool, amazed, tired, sad, determined, sick, funny, blessed | **nouns, no gender** [user]: سعادة، حماس، حب، راحة، امتنان، تحفّز، روعة، دهشة، تعب، حزن، عزيمة، مرض، مرح، بركة (سعادة، حماس، امتنان، تعب from the user; the rest drafts) |
| activities (deferred) | Celebrating…, Watching…, Eating…, Drinking…, Traveling to…, Listening to…, Reading…, Playing…, Working out…, Attending… | verbal nouns [user]: احتفال…، مشاهدة…، أكل…، شرب…، سفر إلى…، استماع إلى…، قراءة…، لعب…، تمرّن…، حضور… (drafts) |
| noMatches | No matches | لا نتائج |
Arabic uses nouns and verbal nouns because gender is not stored [user]; the Arabic list is `x-review` except the four words the user gave.

## Behavior and navigation
- Feeling tile tap: returns at once to the previous page with the feeling (no Done).
- Activity row tap (deferred, TODO): pushes S9 (`s9-activity-what.md`); S9 returns the full activity to the caller.
- Remove: returns with no mood. Back: returns without change.
- Card sentence: EN feeling -> "is feeling 😊happy"; AR feeling -> "😊 سعادة" (emoji + noun, no connector); activity (deferred) EN "is 📺 watching the derby with dad", AR "📺 مشاهدة الديربي" (see `../02-components.md`, headline).

## Data mapping
| UI | Source |
|---|---|
| Result | `PostMood(kind, key, text?)` -> `create_post(p_mood_kind, p_mood_key, p_mood_text)` / `update_post(...)` |
| Feelings, activity verbs, emoji, keywords | static lists in code (keys are the wire values) |

## Responsive / a11y
`ContentWidth` on wide; grid stays 2 columns, tiles flex. Targets >= 44. Semantics: tile "happy, selected", segmented control as tabs. RTL: grid fills right-to-left, chevron mirrors, check stays at the end.

## Acceptance checklist
- [ ] Segmented control with white thumb, search pill, 2-column tiles with emoji + word; selected tile primarySoft with check.
- [ ] Activities list with emoji tiles, chevrons.
- [ ] Remove appears only when a mood is set and clears it.
- [ ] Feeling and activity are exclusive.
