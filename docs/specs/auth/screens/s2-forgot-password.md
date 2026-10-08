# Forgot password (S2)
Screenshot: ../screenshots/s2-forgot-password.png
Purpose / route: `/forgot-password`. Request a reset link. `ForgotPasswordScreen` + `ForgotPasswordCubit`.

## Layout tree
```
Scaffold (bg background) > SafeArea, side padding 24
├─ Back arrow (44 box, start side 8, top ~16)
├─ IconTile 72 (ic_lock) [top ~ 24 below arrow]
├─ gap 24 > title "Forgot password?" (display) > gap 8 > subtitle (2 lines)
├─ gap ~32 > AuthTextField "Email" (hint you@example.com)
├─ gap ~24 > PrimaryButton "Send reset link" (expand)
├─ Spacer
└─ OutlinePillButton "Back to sign in" (expand, pinned bottom ~24 from bottom)
```

## Elements
| Element | Text | Token | Notes |
|---|---|---|---|
| Back arrow | - | textPrimary | mirrors in RTL; -> S1 |
| Icon tile | lock | primarySoft / primary | 72, r22 |
| Title | Forgot password? | display | |
| Subtitle | Enter the email linked to your account and we'll send you a reset link. | subtitle | |
| Send reset link | | primary | disabled until email non-empty; loading spinner |
| Back to sign in | | outline | -> S1 |

## States
Default / loading / error ("Enter a valid email" on invalid format [estimated]; request error: snackbar "Something went wrong. Try again." [estimated]). Success -> S9 dialog over this screen (screen content stays).

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| forgotTitle | Forgot password? | نسيت كلمة المرور؟ |
| forgotSubtitle | Enter the email linked to your account and we'll send you a reset link. | أدخل البريد المرتبط بحسابك وسنرسل لك رابط إعادة التعيين. |
| emailLabel / emailHint | Email / you@example.com | البريد الإلكتروني / you@example.com |
| sendResetLink | Send reset link | إرسال رابط إعادة التعيين |
| backToSignIn | Back to sign in | العودة إلى تسجيل الدخول |
| errorGeneric | Something went wrong. Try again. | حدث خطأ ما. حاول مرة أخرى. |

## Behavior and navigation
Send -> `resetPasswordForEmail(email)` (the emailed link finishes the reset; link handling/new-password screen is out of scope, see open-questions) -> open S9. Keyboard: email `done` submits.

## Data mapping
Email user input; remembered into the S9 dialog (masked).

## Responsive / a11y
Same as S1; the pinned bottom button rises with the keyboard.

## Acceptance checklist
- [ ] Lock tile soft green, 72 dp; title 1 line; subtitle 2 lines grey
- [ ] Single email field; green pill below; outline "Back to sign in" pinned bottom
- [ ] RTL: back arrow flips
