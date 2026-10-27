# Report a problem (S10)
Screenshot: `../screenshots/s10-report-problem.png`
Purpose / route: `/settings/report`.

## Layout tree
```
├─ AppTopBar back + "Report a problem"
├─ Label "What's going wrong?" (label 15/700) + Wrap of chips: Feed, Shorts, Chat, Profile, Signing in, Something else (single select)
├─ Label "Tell us more" + counter "0/500" + multiline field (placeholder "What happened, and what did you expect to happen?", ~165 tall)
├─ Label "Screenshots" + " (optional)" (regular weight) + row: thumbnails 84 (with x remove, 24 dark circle) + dashed "Add" tile
├─ Checkbox (checked) "Include device info and app logs to help us fix it faster"
└─ Send report (PrimaryButton full width, pinned bottom)
```

## States
Chip selected = dark fill white text (Shorts in the screenshot). Send enabled when a category is chosen and the text has at least 10 characters [Q-S10-1]. Add tile hidden at 3 images. Sending: button loading, uploads with progress on thumbnails. Success: notice "Thanks, we got your report" + pop. Error: retry notice, content kept.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| reportTitle | Report a problem | الإبلاغ عن مشكلة |
| reportWhatsWrong | What's going wrong? | ما المشكلة؟ |
| reportCatFeed / Shorts / Chat / Profile / SigningIn / Other | Feed / Shorts / Chat / Profile / Signing in / Something else | الرئيسية / الشورتس / المحادثات / الملف الشخصي / تسجيل الدخول / شيء آخر |
| reportTellMore | Tell us more | أخبرنا بالمزيد |
| reportHint | What happened, and what did you expect to happen? | ماذا حدث، وماذا كنت تتوقع أن يحدث؟ |
| reportScreenshots / Optional | Screenshots / (optional) | لقطات الشاشة / (اختياري) |
| reportAdd | Add | إضافة |
| reportIncludeLogs | Include device info and app logs to help us fix it faster | أرفق معلومات الجهاز وسجلات التطبيق لمساعدتنا في الإصلاح بشكل أسرع |
| reportSend | Send report | إرسال البلاغ |
| reportThanks | Thanks, we got your report | شكرًا، وصل بلاغك |

## Behavior and navigation
Add -> `PhotoSourceSheet` (gallery, multi 3 max), 5 MB each, compressed on device. Logs when checked: device model, OS, app version, last 50 error lines (from `ErrorReporter`). Leaving with text typed -> "Discard?" dialog [Q-S10-2].

## Data mapping
New `problem_reports(id, user_id, category, message, screenshot_paths[], device_info jsonb, logs text, created_at)`, insert-only for clients; screenshots in a private Storage bucket `problem-reports/<user_id>/...`. category values: feed, shorts, chat, profile, signing_in, other. message 1-500.

## Responsive / a11y
Chips wrap; thumbnails have "Remove screenshot" label. RTL: counter at the end.

## Acceptance checklist
- Chip wrap order as the screenshot; counter right-aligned; dashed tile next to the thumbnail; checkbox primary check.
