# Sign-up 4: Profile (S6)
Screenshot: ../screenshots/s6-signup-profile.png
Purpose / route: step 4 of `SignUpFlow`. All optional.

## Layout tree
```
StepTopBar (Step 4 of 6, 4 filled, "Optional", "Skip")
side padding 24, scrollable
├─ title "Set up your profile" > 8 > subtitle
├─ ~24 > PhotoPickerAvatar row: circle 88 + 16 gap + Column("Add a photo" 16/700 textPrimary, "Profiles with a photo get more follows." bodySm textSecondary)
├─ ~24 > "Bio" label + counter "0/150" (end) > multiline field 3 lines (hint "A few words about you")
├─ 14 > "City" field (hint "Where are you based?")
├─ 14 > "Phone number" field (hint "+20 ••• ••• ••••") > 6 > helper (2 lines)
PinnedBottomCta: PrimaryButton "Continue"
```

## States
Continue always enabled (everything optional). Bio blocked at 150 with live counter. City max 60. Phone numeric keyboard, forced LTR, digits/space/+ only; when non-empty must have 7-15 digits else "Enter a valid phone number" [user]. Photo set -> circle shows image, sheet gains "Remove photo".

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| profileTitle | Set up your profile | أعدّ ملفك الشخصي |
| profileSubtitle | All optional. You can add these later in Settings. | كل شيء اختياري. يمكنك إضافته لاحقًا من الإعدادات. |
| addPhoto | Add a photo | أضف صورة |
| addPhotoHint | Profiles with a photo get more follows. | الملفات التي تحتوي على صورة تحصل على متابعين أكثر. |
| bioLabel / Hint | Bio / A few words about you | نبذة / بضع كلمات عنك |
| cityLabel / Hint | City / Where are you based? | المدينة / أين تقيم؟ |
| phoneLabel / Hint | Phone number / +20 ••• ••• •••• | رقم الهاتف / +20 ••• ••• •••• |
| phoneHelper | Helps friends find you and lets you recover your account. Kept private. | يساعد أصدقاءك على إيجادك ويتيح لك استعادة حسابك. يبقى خاصًا. |
| takePhoto / chooseGallery / removePhoto | Take photo / Choose from gallery / Remove photo | التقاط صورة / اختيار من المعرض / إزالة الصورة |
| errorPhone | Enter a valid phone number | أدخل رقم هاتف صالحًا |

## Behavior and navigation
Continue -> save + upload photo (Supabase Storage); Skip saves nothing. Either then loads the interests; if the list is empty, step 5 is skipped and the flow goes to step 6 (`signup_step` = 6), otherwise step 5 opens with the loaded list [user]. Back -> step 3 (S5). Camera/gallery permissions requested on use.

## Data mapping
`avatar_url`, `bio`, `city`, `phone` [estimated names].

## Responsive / a11y
Scrolls; CTA over keyboard; counter Semantics.

## Acceptance checklist
- [ ] Dashed circle with camera + small green plus badge bottom-end
- [ ] "Optional" grey and "Skip" grey bold at end
- [ ] Bio box taller (3 lines) with counter at the label row end
