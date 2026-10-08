# Set a new password (S11)
Screenshot: ../screenshots/s11-set-new-password.png (390 px = 1x)
Purpose / route: `/reset-password`. Opened by the Supabase recovery email link (deep link; Supabase cannot email a password, only a link) [user]. `ResetPasswordScreen` + cubit.

## Layout tree
```
Scaffold (bg background) > SafeArea, side padding 24
├─ Close "X" (ic_close 24 in 44 box, start side, top ~16) -> not a back arrow
├─ IconTile 72 (ic_key) [~24 below X]
├─ 24 > title "Set a new password" (display) > 8 > subtitle: "For " + bold "dip•••@gmail.com" + ". Use something you haven't used on Pulse before." (2 lines)
├─ ~24 > AuthTextField "New password" (hint "At least 8 characters", eye)
├─ 8 > strength segments: 4 x ~68 wide, h4, gap 4 (they do NOT span full width) [seen]
├─ 12 > rules list (3 rows, gap 8): dot 6 + 12 gap + text caption 13/400 textSecondary
│    "At least 8 characters" · "Contains a number" · "Upper and lower case letters"
├─ ~16 > AuthTextField "Confirm new password" (hint "Type it again", no eye in screenshot)
├─ ~16 > Row: checkbox 20 (checked, primary) + 12 + "Log out of all other devices" (13/400 textSecondary)
└─ PinnedBottomCta: PrimaryButton "Update password" (expand; disabled look in screenshot)
```

## Elements
| Element | Token | Notes |
|---|---|---|
| Close X | textPrimary | `ic_close`; closes to /sign-in |
| Icon tile | primarySoft / primary | 72, r22, `ic_key` 32 |
| Segments | switchOff empty; fill by strength | same score and colors as S3 meter (C8); no word label [seen] |
| Rule dot | `dashed` (#9AA6A2) unmet; `primary` + `ic_check` when met | 6 dp dot; met state is my addition, not in the screenshot [user: "dot turns primary + check"] |
| Checkbox | 20 square r6 (smaller than S3's 24) [seen, estimated] | checked primary + white check |
| Update password | primary @40% when disabled | loading spinner |

## States
- Initial: both fields empty, segments empty, all dots grey, checkbox checked, button disabled [seen].
- Update enabled when all 3 rules are met and confirm equals new password [user]. Rules: length >= 8; has a digit; has both upper and lower case.
- Mismatch: after confirm is non-empty and different, danger border + "Passwords don't match" [estimated].
- Loading on Update. Request error: snackbar "Something went wrong. Try again." [estimated].
- Expired/invalid recovery link [user, default accepted]: when the link cannot start a recovery session, `/reset-password` shows the key `IconTile`, title "This link has expired", subtitle "Request a new link to reset your password.", and a `PrimaryButton` "Request a new link" -> `/forgot-password` (S2). The X still goes to `/sign-in`. No form is shown.

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| resetTitle | Set a new password | عيّن كلمة مرور جديدة |
| resetSubtitle | For {email}. Use something you haven't used on Pulse before. | لـ {email}. استخدم كلمة مرور لم تستخدمها على Pulse من قبل. |
| newPasswordLabel / Hint | New password / At least 8 characters | كلمة المرور الجديدة / 8 أحرف على الأقل |
| ruleLength | At least 8 characters | 8 أحرف على الأقل |
| ruleNumber | Contains a number | تحتوي على رقم |
| ruleCase | Upper and lower case letters | أحرف كبيرة وصغيرة |
| confirmLabel / Hint | Confirm new password / Type it again | تأكيد كلمة المرور الجديدة / أعد كتابتها |
| logoutOthers | Log out of all other devices | تسجيل الخروج من جميع الأجهزة الأخرى |
| updatePassword | Update password | تحديث كلمة المرور |
| errorMismatch | Passwords don't match | كلمتا المرور غير متطابقتين |
| linkExpiredTitle | This link has expired | انتهت صلاحية هذا الرابط |
| linkExpiredBody | Request a new link to reset your password. | اطلب رابطًا جديدًا لإعادة تعيين كلمة مرورك. |
| requestNewLink | Request a new link | طلب رابط جديد |

## Behavior and navigation
- Link opens the app -> Supabase recovery session (PASSWORD_RECOVERY event) -> `/reset-password` [estimated mechanism; TODO: configure the URL scheme and the Supabase redirect URL].
- Update: `updateUser(password)`; if the checkbox is checked then `signOut(scope: others)` [user]; success -> S12 dialog.
- X: sign out the recovery session and `AppNavigator.resetTo('/sign-in')`, no confirmation [user].
- Keyboard: new password `next` (`newPassword` autofill), confirm `done` submits.

## Data mapping
Email = recovery session user's email, masked like S4/S9. Passwords user input, never logged.

## Responsive / a11y
Scrolls; eye toggle Semantics; rule rows announce "met / not met"; X Semantics "Close"; checkbox tappable with label (44 min row).

## Acceptance checklist
- [ ] X at top-start (not an arrow), key tile below it
- [ ] Subtitle with bold masked email, 2 lines
- [ ] 4 short segments (not full width) + 3 rule rows with grey dots
- [ ] Checkbox checked by default, label small grey
- [ ] "Update password" pinned bottom, dimmed until valid
- [ ] Expired link: key tile, "This link has expired", "Request a new link" button to S2, no form
- [ ] RTL: X moves to the right; dots/text mirror
