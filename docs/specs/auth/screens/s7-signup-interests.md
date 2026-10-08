# Sign-up 5: Interests (S7)
Screenshot: ../screenshots/s7-signup-interests.png
Purpose / route: step 5 of `SignUpFlow`.

## Layout tree
```
StepTopBar (Step 5 of 6, 5 filled, "Optional", "Skip")
side padding 24, scrollable
├─ title "What are you into?" > 8 > subtitle (2 lines)
├─ ~24 > Wrap(spacing 10, runSpacing 12) of SelectableChip (interest, h44)
PinnedBottomCta: caption "{n} selected" (14/400 textSecondary, centered, hidden at 0) > 12 > PrimaryButton "Continue"
```
Selected in screenshot: Travel, Photography. Order: Travel, Photography, Food, Football, Fitness, Music, Tech, Movies & TV, Art & design, Books, Gaming, Fashion, Nature, Comedy.

## States
Loading: chip skeletons (rounded pills, shimmer-free flat `segmentTrack`). Error: message "Couldn't load topics" + "Retry" text button. Empty list: same as error without retry [estimated]. Selected / unselected per tokens. Continue always enabled; no min/max [user].

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| interestsTitle | What are you into? | ما اهتماماتك؟ |
| interestsSubtitle | Pick a few topics so your feed and shorts feel like you. | اختر بعض المواضيع ليشبهك موجزك ومقاطعك القصيرة. |
| selectedCount | {n} selected | تم اختيار {n} |
| interestsError | Couldn't load topics | تعذّر تحميل المواضيع |
| retry | Retry | إعادة المحاولة |
| Travel, Photography, Food, Football, Fitness, Music, Tech, Movies & TV, Art & design, Books, Gaming, Fashion, Nature, Comedy | (as listed; fallback copy, normally from backend) | سفر، تصوير، طعام، كرة القدم، لياقة، موسيقى، تقنية، أفلام وتلفزيون، فن وتصميم، كتب، ألعاب، أزياء، طبيعة، كوميديا |

## Behavior and navigation
Tap toggles. Continue -> save selected ids; Skip saves nothing. Either then loads the suggested and popular profiles; if both are empty, step 6 is skipped and the flow ends at `/home` (`signup_step` = 0), otherwise step 6 opens with the loaded list [user]. Back -> step 4. The list is loaded on the previous step, so S7 normally has no empty state; the error + Retry state stays for a failed load.

## Data mapping
Supabase `interests` (id, slug, name_en, name_ar, sort_order) [user, schema]; the 14 above are the seeded rows. Saved with RPC `set_user_interests(ids)`.

## Responsive / a11y
Wrap reflows; chips Semantics `selected`; labels never truncate (chip grows).

## Acceptance checklist
- [ ] Selected chips green with white check + label; others white outline
- [ ] 4 rows in screenshot widths: 3 / 4 / 3 / 3 / 1 chips
- [ ] "2 selected" centered above Continue
