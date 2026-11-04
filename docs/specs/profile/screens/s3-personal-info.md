# Personal info (S3)
Screenshot: `../screenshots/s3-personal-info.png`
Purpose / route: `/settings/personal-info`. Edit own profile.

## Layout tree
```
Scaffold (background), keyboard-aware scroll, side padding 16
├─ AppTopBar back + "Personal info"
├─ Avatar 96 (ring storyRing) + camera badge 32 (primary, bottom-end)
├─ Link "Change cover photo" (primary 15/700, centered)
├─ Field "Full name"
├─ Field "Username" (prefix "@", trailing green check when free)
├─ Field "Bio" (multiline 3 lines, counter "58/150" at label end)
├─ Field "Location"
├─ Field "Email" (read-only)
├─ Row: Field "Phone" (placeholder "+20 ••• ••• ••••") | Field "Birthday" (placeholder "DD / MM / YYYY")
├─ Note (bodyXs textSecondary): "Your email, phone and birthday are private and never shown on your profile."
└─ Save changes (PrimaryButton full width, pinned bottom with AppSafeArea)
```

## Elements
Labels `label` 13/600 textPrimary above fields (gap 6); field gap 14; field height ~52, r14, white fill, border `border`. Phone/Birthday half width, gap 12. Counter caption textSecondary.

## States
Default; focused (primary border); username checking (small spinner in place of the check), free (check ic_check primary), taken or invalid (danger border + message); email read-only (text textSecondary, no focus); saving (button loading); error notice; Save disabled until changed and valid.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| personalInfoTitle | Personal info | المعلومات الشخصية |
| changeCover | Change cover photo | تغيير صورة الغلاف |
| fieldFullName / Username / Bio / Location / Email / Phone / Birthday | Full name / Username / Bio / Location / Email / Phone / Birthday | الاسم الكامل / اسم المستخدم / النبذة / الموقع / البريد الإلكتروني / الهاتف / تاريخ الميلاد |
| birthdayHint | DD / MM / YYYY | يوم / شهر / سنة |
| personalInfoPrivateNote | Your email, phone and birthday are private and never shown on your profile. | بريدك الإلكتروني وهاتفك وتاريخ ميلادك خاصة ولا تظهر في ملفك الشخصي. |
| saveChanges | Save changes | حفظ التغييرات |
| usernameTaken / Invalid | That username is taken / Use 3-30 letters, numbers, dots or underscores | اسم المستخدم مستخدم بالفعل / استخدم من 3 إلى 30 حرفًا أو رقمًا أو نقطة أو شرطة سفلية |
| discardTitle / Body / Confirm / Keep | Discard changes? / Your edits will be lost. / Discard / Keep editing | تجاهل التغييرات؟ / ستفقد تعديلاتك. / تجاهل / متابعة التعديل |
| profileSaved | Profile updated | تم تحديث الملف الشخصي |

## Behavior and navigation
Camera badge -> `PhotoSourceSheet` -> crop square -> upload -> avatar. "Change cover photo" -> same sheet, crop 390:170 -> upload -> cover; "Remove photo" row only when one exists. Username: validated like sign-up, availability via `username_exists` (debounced), own current username counts as free. Bio max 150 (counter). Location: tapping the field opens the place picker (`/pick-place`, features/places) and reads its `LocationChoice` result; the chosen name is saved in `city`; the picker's "remove" result clears it [user]. The field is read-only text with ic_location and a chevron-free tap target. Email read-only (changes need verification, later). Phone and birthday editable, same formats as sign-up (phone via `PhoneField` with country code, birthday date picker). Save: enabled only when changed and valid; success -> notice "Profile updated" + pop. Back or system back with unsaved edits -> "Discard changes?" dialog.

## Data mapping
`profiles`: full_name, username, bio, city (Location), phone, birthday, avatar_url, cover_url. Email from the auth user. Phone and birthday are kept off the device copy (existing rule).

## Responsive / a11y
Keyboard: scroll the focused field into view; Save stays visible above the keyboard. RTL: "@" prefix on the start side, check on the end side, counter on the end side. Badge label "Change profile photo".

## Acceptance checklist
- Avatar 96 with soft ring and 32 camera badge on the end-bottom.
- Phone and Birthday on one row; note under them; Save pinned.
- Counter shows live length; username check icon matches state.
