# Forgot password: link sent (S9)
Screenshot: ../screenshots/s9-forgot-password-sent-dialog.png (780 px = 2x)
Purpose / route: custom content inside the shared `AppDialogShell` (C14) shown over S2 after a successful send. The user asked for **blur behind the dialog** so the body does not show through.

## Layout tree
```
Barrier: scrim #161A19 @ 40% + BackdropFilter blur sigma 12
Card (342 wide, centered vertically, padding 28 v / 24 h, radius 28, white, dialog shadow)
├─ Circle 56 primarySoft + ic_mail 24 primary (centered)
├─ 16 > "Check your email" (Sora 22/700 centered)
├─ 8 > "We sent a reset link to " + bold "dip•••@gmail.com" + ". Open it to set a new password." (subtitle 15, centered, 2 lines)
├─ 24 > PrimaryButton-style pill "Open email app" (48 high, expand)
├─ 8 > SoftPillButton "Back to sign in" (48 high, expand)
└─ 20 > Row centered: "Didn't get it?" (14/400 textSecondary) 8 "Resend link" (14/700 primary) 8 "·" 8 "Change email" (14/700 primary)
```

## States
Default; resend cooldown 30 s: "Resend link in 0:30" disabled grey [estimated, mirrors S4]; resend success: snackbar "Link sent again" [estimated].

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| sentTitle | Check your email | تحقق من بريدك |
| sentBody | We sent a reset link to {email}. Open it to set a new password. | أرسلنا رابط إعادة التعيين إلى {email}. افتحه لتعيين كلمة مرور جديدة. |
| openEmailApp | Open email app | فتح تطبيق البريد |
| backToSignIn | Back to sign in | العودة إلى تسجيل الدخول |
| didntGetIt | Didn't get it? | لم يصلك؟ |
| resendLink | Resend link | إعادة إرسال الرابط |
| resendLinkIn | Resend link in {time} | إعادة الإرسال خلال {time} |
| changeEmail | Change email | تغيير البريد |
| linkResent | Link sent again | تم إرسال الرابط مرة أخرى |

## Behavior and navigation
- Open email app: `url_launcher` with `mailto:` [user]; if it cannot launch, snackbar "No email app found" [estimated].
- Resend link: `resetPasswordForEmail` again, 30 s cooldown [estimated, not answered].
- Change email: close dialog and focus the S2 email field [estimated, not answered].
- Back to sign in: `AppNavigator.resetTo('/sign-in')`.
- Barrier tap / Android back: close the dialog, stay on S2 [estimated].

## Data mapping
Email = value typed on S2, masked like S4 (first 3 chars + "•••" + domain).

## Responsive / a11y
Card max width 342, scrolls inside if text scale is large; focus trapped; title announced as dialog title; screen readers read the masked email string.

## Acceptance checklist
- [ ] Blurred + dimmed S2 behind; S2 text unreadable under the card
- [ ] Round mail icon, centered bold title, 2-line body with bold email
- [ ] Green pill, grey pill, then footer links separated by a dot
