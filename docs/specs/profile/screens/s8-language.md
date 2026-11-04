# Language (S8)
Screenshot: `../screenshots/s8-language.png`
Purpose / route: `/settings/language`.

## Layout tree
```
├─ AppTopBar back + "Language"
├─ SearchPillField "Search languages"
├─ Section "APP LANGUAGE": card rows [native name 15/700 + English name 13 textSecondary, trailing ic_check primary on the selected one]
│   English, العربية (Arabic)  (only these two; no other languages are listed) [user]
└─ Footnote (bodyXs textSecondary): "Arabic switches the whole app to right-to-left."
```

## States
Selected = check. Search filters by native or English name (case-insensitive); no match -> "No languages found". Only English and Arabic exist; the screenshot's other 5 rows (Français, Español, Deutsch, Türkçe, हिन्दी) are dropped [user].

## Strings
| key | en | ar (x-review) |
|---|---|---|
| languageTitle | Language | اللغة |
| searchLanguages | Search languages | ابحث عن لغة |
| appLanguage | App language | لغة التطبيق |
| languageRtlNote | Arabic switches the whole app to right-to-left. | العربية تحوّل التطبيق بالكامل من اليمين إلى اليسار. |
| languageNone | No languages found | لم يتم العثور على لغات |
Language names are shown in their own script (not translated) with the English name below; in Arabic UI the second line is the Arabic name [Q-S8-1].

## Behavior and navigation
English and Arabic apply at once (locale set in the app, kept on the device, default = device locale, unsupported device locales fall back to English). Choosing Arabic flips layout to RTL immediately. Stays on the page after choosing [Q-S8-2].

## Data mapping
Local `SharedPreferences` key via a datasource; no server field.

## Responsive / a11y
Rows are radio-like (selected state announced). Search field keyboard: search action.

## Acceptance checklist
- 2 rows (English, العربية), English selected with a teal check; footnote below the card; search pill r full on white.
