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
├─ 14 > "Phone number" field: country-code button (flag + "+code" + chevron) then the number (hint "••• ••• ••••") > 6 > helper (2 lines)
PinnedBottomCta: PrimaryButton "Continue"
```

## States
Continue always enabled (everything optional). Bio blocked at 150 with live counter. City max 60. Phone: international [user, 2026-10-10]. The country-code button (default Egypt +20) opens the shared country sheet (C15); the number is numeric, forced LTR, digits and spaces only. The stored value is "+code number" ("+966 512345678"); when a number is given, the whole value must have 7-15 digits else "Enter a valid phone number". No number = no phone. Photo set -> circle shows image, sheet gains "Remove photo".

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| profileTitle | Set up your profile | أعدّ ملفك الشخصي |
| profileSubtitle | All optional. You can add these later in Settings. | كل شيء اختياري. يمكنك إضافته لاحقًا من الإعدادات. |
| addPhoto | Add a photo | أضف صورة |
| addPhotoHint | Profiles with a photo get more follows. | الملفات التي تحتوي على صورة تحصل على متابعين أكثر. |
| bioLabel / Hint | Bio / A few words about you | نبذة / بضع كلمات عنك |
| cityLabel / Hint | City / Where are you based? | المدينة / أين تقيم؟ |
| phoneLabel / Hint | Phone number / ••• ••• •••• | رقم الهاتف / ••• ••• •••• |
| phoneHelper | Helps friends find you and lets you recover your account. Kept private. | يساعد أصدقاءك على إيجادك ويتيح لك استعادة حسابك. يبقى خاصًا. |
| takePhoto / chooseGallery / removePhoto | Take photo / Choose from gallery / Remove photo | التقاط صورة / اختيار من المعرض / إزالة الصورة |
| photoSheetTitle | Profile photo | صورة الملف الشخصي |
| countryPickerTitle | Select country | اختر الدولة |
| countrySearchHint | Search country or code | ابحث عن دولة أو رمز |
| countryNoResults | No country found | لم يتم العثور على دولة |
| errorPhone | Enter a valid phone number | أدخل رقم هاتف صالحًا |

## Behavior and navigation
Continue -> save + upload photo (Supabase Storage); Skip saves nothing. Either then loads the interests; if the list is empty, step 5 is skipped and the flow goes to step 6 (`signup_step` = 6), otherwise step 5 opens with the loaded list [user]. Back -> step 3 (S5). Camera/gallery permissions requested on use.
- **Resumed sign-up** [user]: when the flow opens after Verify email (step 3 to 6), it first loads the saved profile (`GetSignupDraftUseCase`) behind a spinner and fills About you and Profile (name, username, birthday, gender, bio, city, phone, photo from its URL). Fields already typed are never overwritten; a failed load leaves them empty. Going back therefore shows what was entered before. Email and password are not restored (never stored); sign-up cannot resume before step 3.
- **Remove photo on a saved photo** [user]: clears the circle at once, but the server copy is deleted only when Continue saves (`removeAvatar` on the profile repository, before the update; a failed delete keeps the user on the step with the error). A newly picked photo replaces the old one, so nothing is deleted separately. Back or Skip leave the saved photo untouched.

## Data mapping
`avatar_url`, `bio`, `city`, `phone` [estimated names].

## Responsive / a11y
Scrolls; CTA over keyboard; counter Semantics.

## Acceptance checklist
- [ ] Dashed circle with camera + small green plus badge bottom-end
- [ ] "Optional" grey and "Skip" grey bold at end
- [ ] Phone shows a country-code button; any country can be chosen
- [ ] Photo sheet has a grabber, a title and icon cards
- [ ] Bio box taller (3 lines) with counter at the label row end
