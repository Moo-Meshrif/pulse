# Privacy (S5)
Screenshot: `../screenshots/s5-privacy.png`
Purpose / route: `/settings/privacy`.

## Layout tree
```
Scaffold (background), side margin 12
├─ AppTopBar back + "Privacy"
├─ Card: SwitchRow "Private account" + 2-line subtitle
├─ Section "WHO CAN MESSAGE YOU": card RadioRows [Everyone, People you follow, No one]
├─ Section "WHO CAN COMMENT": card RadioRows [Everyone, Followers only, Turn off comments]
└─ Section "VISIBILITY": card [SwitchRow "Show activity status", SwitchRow "Appear in search", Row "Blocked accounts" value "3" ›]
```

## States
Each control saves at once (optimistic, rolls back with an error notice). Loading: skeleton rows. Radio selected = primary ring + dot.

## Strings
| key | en | ar (x-review) |
|---|---|---|
| privacyTitle | Privacy | الخصوصية |
| privateAccount / Sub | Private account / Only people you approve can see your posts, shorts and followers. | حساب خاص / فقط من توافق عليهم يمكنهم رؤية منشوراتك وشورتسك ومتابعيك. |
| whoCanMessage | Who can message you | من يمكنه مراسلتك |
| everyone / peopleYouFollow / noOne | Everyone / People you follow / No one | الجميع / الأشخاص الذين تتابعهم / لا أحد |
| whoCanComment | Who can comment | من يمكنه التعليق |
| followersOnly / turnOffComments | Followers only / Turn off comments | المتابعون فقط / إيقاف التعليقات |
| visibility | Visibility | الظهور |
| activityStatus / Sub | Show activity status / Let friends see when you're online | إظهار حالة النشاط / دع أصدقاءك يرون متى تكون متصلًا |
| appearInSearch / Sub | Appear in search / People can find you by name or email | الظهور في البحث / يمكن للناس إيجادك بالاسم أو البريد الإلكتروني |
| blockedAccounts | Blocked accounts | الحسابات المحظورة |

## Behavior and navigation
Private account on: new follows become requests; existing followers stay; off: pending requests stay pending and the owner accepts or declines them later (follow requests list) [user]. Message / comment choices stored on the profile (new columns `who_can_message`, `who_can_comment`; values everyone / following (followers for comment) / none) and enforced: comments by the comment RPCs (existing per-post comments switch still applies inside the choice); messages when Chat exists. Show activity status -> `show_activity`; Appear in search -> `appear_in_search` (new, search honors it). Blocked accounts row -> S6.

## Data mapping
`profiles.is_private` (exists), new: who_can_message, who_can_comment, show_activity, appear_in_search. Blocked count from `blocks`.

## Responsive / a11y
Radio groups announced as radio groups; row is the tap target. RTL: radios on the end side.

## Acceptance checklist
- 4 white r22 cards; selected radios match the screenshot (message = People you follow, comment = Everyone).
- Blocked accounts row has value "3" and a chevron.
