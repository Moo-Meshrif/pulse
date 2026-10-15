# Activity: what (S9)
> **DEFERRED [user, 2026-10-15]: do not build.** TODO: activities come later from an API or a database (source undecided). This file keeps the design for that day; the `activity_suggestions` table and RPC were removed from `schema-post-tags-mood.sql` and will be redesigned with the source.

Screenshot: `../screenshots/s6-tag-feeling-board.png` (board 1, panel 6). Pushed from S8 when an activity verb is tapped.
Purpose / route: say what the activity is about (pick a suggestion or write your own, 1-60 chars); `/create/post/feeling/activity`, full page; returns `PostMood(activity, verb, text)` straight to New post [user].

## Layout tree
```
Scaffold (background)  [AppSafeArea]
└─ Column
   ├─ Header 56: back 44 · title "{emoji} Watching" (Sora 20/700)
   ├─ Field: h 48, r24, white, focused 2 px primary ring, clear ×; autofocus; text = what ("the derby with dad")
   ├─ Section label "SUGGESTIONS" (section 13/700 UPPERCASE)
   └─ List card (white, r22): rows 56
        ├─ first row (only when the field has text): `ic_plus` 20 primary in a 32 tile + "Use "the derby with dad"" (primarySoft row fill)
        └─ suggestion rows: emoji tile 32 + label 15/600 + (subtitle 12 textSecondary, e.g. "Football")
   Keyboard open.
```

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Title | "{emoji} {Verb}" | | Sora 20/700 | the verb without the ellipsis ("Watching") |
| Field | placeholder "What?" [estimated] | 48 | | max 60 chars, counter shown from 50 [estimated] |
| Use row | `Use "{text}"` | 56 | primarySoft, primary text 15/700 | trims; needs 1..60 chars |
| Suggestion row | label + subtitle | 56 | | tap returns it |

## States
| State | UI |
|---|---|
| Blank field | only suggestions for the verb (top 10, `activity_suggestions_list(verb, null)`), no Use row |
| Typing | Use row first, then suggestions filtered by the text (300 ms debounce) |
| Loading | `PulseLineLoader` width 44 over the list |
| No suggestions | only the Use row [seen: custom text always possible] |
| Error | list shows only the Use row; notice "Couldn't load suggestions" [estimated] |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| activityWhatHint | What? | ماذا؟ |
| activitySuggestions | Suggestions | اقتراحات |
| activityUse | Use "{text}" | استخدم "{text}" |
| activitySuggestionsError | Couldn't load suggestions | تعذّر تحميل الاقتراحات |
Suggestion labels and subtitles come from the database by locale (`label_en` / `label_ar`).

## Behavior and navigation
Tapping the Use row or a suggestion pops S9 and S8 and returns the activity to New post / Edit post. Back returns to S8 without change. The returned text is what the card shows: "is 📺 watching the derby with dad" [user].

## Data mapping
| UI | Source |
|---|---|
| Suggestions | `rpc('activity_suggestions_list', {p_verb, p_q, p_locale})` -> id, label, subtitle, emoji (table `activity_suggestions`, seeded, editable in Supabase) |
| Result text | `posts.mood_text` (1..60), kind `activity`, key = verb |

## Responsive / a11y
List scrolls above the keyboard. Semantics: Use row "Use {text}". RTL: field text follows direction; header mirrors.

## Acceptance checklist
- [ ] Title with emoji and verb, focused field with ×, SUGGESTIONS, first row "+ Use ...", suggestion rows with subtitle.
- [ ] Use row appears only with text and is highlighted.
- [ ] Choosing returns straight to New post with the headline preview.
