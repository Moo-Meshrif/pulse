# Sign-up 6: Follow (S8)
Screenshot: ../screenshots/s8-signup-follow.png
Purpose / route: step 6 (last) of `SignUpFlow`.

## Layout tree
```
StepTopBar (Step 6 of 6, 6 filled, "Optional", "Skip")
Column
├─ Scrollable (side padding 24 for header; list card margin 12)
│  ├─ title "Follow people you know" > 8 > subtitle (2 lines)
│  ├─ ~20 > Row of dark-variant SelectableChip: Suggested (selected) | From contacts | Popular  (gap 10)
│  ├─ ~20 > Row: "SUGGESTED FOR YOU" (section style, textSecondary) ... "Follow all" (14/700 primary, end)
│  └─ 8 > white card r22: 6 x FollowRow (no dividers)
└─ PinnedBottomCta bar (top hairline divider): PrimaryButton "Continue" + 8 + caption "Follow at least 3 people for a better feed" (13/400 textSecondary, centered)
```
Data: RPC `suggested_profiles(p_tab)` (see `schema.sql`); the screenshot rows are only a sample, and "Went to your school" is not supported (no data). Sample rows: SK Salma Kamal "12 mutual friends" · OH Omar Hassan "Went to your school" · LT Lina Tarek "5 mutual friends" · MR Monohor Roy "Lives in Kolkata" · YF Yara Fawzy "3 mutual friends" · DN Dev Nair "2 mutual friends".

## States
- Tabs: Suggested (default, loaded on step 5), From contacts (empty state "Coming soon", no permission request) [user]; TODO: contacts permission + matching later, Popular (RPC `suggested_profiles('popular')`).
- Follow -> "Following" (outline pill) for a public profile; a private profile (`is_private`) becomes "Requested" (same outline pill) until they accept. Tap again unfollows or cancels the request [estimated]. "Follow all" follows every visible row; label stays.
- Loading (tab switch): 6 skeleton rows; error: message + Retry [estimated]; empty tab: message only [estimated].
- Continue always enabled; caption is a hint only [user]. List scrolls under the pinned bar; scrollbar visible in screenshot (platform default).

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| followTitle | Follow people you know | تابع أشخاصًا تعرفهم |
| followSubtitle | Their posts and shorts will show up in your feed. You can change this anytime. | ستظهر منشوراتهم ومقاطعهم القصيرة في موجزك. يمكنك التغيير في أي وقت. |
| tabSuggested / tabContacts / tabPopular | Suggested / From contacts / Popular | مقترحون / من جهات الاتصال / الأكثر شعبية |
| suggestedForYou | SUGGESTED FOR YOU | مقترحون لك (no uppercase in Arabic) |
| followAll | Follow all | متابعة الكل |
| follow / following | Follow / Following | متابعة / تتابعه |
| mutualFriends | {n} mutual friends (ICU plural; 1 -> "1 mutual friend") | {n} أصدقاء مشتركين (ICU plural) |
| livesIn | Lives in {city} | يسكن في {city} |
| followHint | Follow at least 3 people for a better feed | تابع 3 أشخاص على الأقل لموجز أفضل |
| comingSoon | Coming soon | قريبًا |
| continueButton | Continue | متابعة |

## Behavior and navigation
The first list is loaded on step 5 Continue/Skip (see S7); the screen is skipped when both Suggested and Popular are empty [user]. Switching to another tab loads that tab; an empty tab shows a message only ("No suggestions yet", Continue stays enabled) [estimated]. Following a row keeps it in the list (local state). Meta line: "{n} mutual friends" or "Lives in {city}", hidden when neither exists (the school line has no data) [user]. Continue -> follows are already saved per tap -> `/home` via `AppNavigator.resetTo`. Skip -> `/home` [user]. Back -> step 7.

## Data mapping
Meta line is a backend-provided string per profile (mutual count, school, city) [estimated]; avatar initials from the name (first letters of first two words); colors from the palette (rule: open-questions). Follows saved to `follows` [estimated name].

## Responsive / a11y
Follow button Semantics "Follow {name}"; rows tap target >= 44; name/meta 1 line with ellipsis; tabs scroll horizontally if too wide.

## Acceptance checklist
- [ ] Dark "Suggested" chip, others outline
- [ ] White rounded card, 6 rows, avatar colors as in screenshot
- [ ] Pinned bar with hairline, green Continue and grey caption
- [ ] 6 of 6 segments green
