# Sign-up 1: Account (S3)
Screenshot: ../screenshots/s3-signup-account.png
Purpose / route: `/register`, step 1 of `SignUpFlow`.

## Layout tree
```
StepTopBar (Step 1 of 6, 1 segment filled, "Required")
Scrollable, side padding 24
├─ title "Create your account" > 8 > subtitle
├─ gap ~24 > AuthTextField "Email *" (hint you@example.com)
├─ 14 > AuthTextField "Password *" (hint "At least 8 characters", eye [user deviation])
├─ 10 > PasswordStrengthMeter ("Good" at end)  (hidden until typing)
├─ ~18 > LabeledCheckbox "I agree to the Terms and Privacy Policy *"
├─ ~14 > "* Required" (caption 13/400 textSecondary, red asterisk)
├─ ~24 > OrDivider "or sign up with" > ~16 > SocialButtonsRow
PinnedBottomCta: PrimaryButton "Continue" (expand) + ~12 gap + "Already on Pulse? " + "Sign in" (15, primary bold, centered)
```

## States
- Initial: empty fields, checkbox **unchecked**, no meter, Continue disabled [user] (screenshot shows a filled mock).
- Enabled when email valid, password >= 8, checkbox checked.
- Loading on Continue; errors: invalid email "Enter a valid email"; short password "Password must be at least 8 characters"; email exists "An account with this email already exists" [estimated copy].

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| stepOf | Step {n} of 6 | الخطوة {n} من 6 |
| required / optional / skip | Required / Optional / Skip | مطلوب / اختياري / تخطي |
| signUpTitle | Create your account | أنشئ حسابك |
| signUpSubtitle | Start with just your email and a password. | ابدأ ببريدك الإلكتروني وكلمة مرور فقط. |
| emailLabel / emailHint | Email / you@example.com | البريد الإلكتروني / you@example.com |
| passwordLabel | Password | كلمة المرور |
| passwordHintMin | At least 8 characters | 8 أحرف على الأقل |
| strengthWeak / Fair / Good / Strong | Weak / Fair / Good / Strong | ضعيفة / مقبولة / جيدة / قوية |
| agreePrefix / and | I agree to the / and | أوافق على / و |
| terms / privacyPolicy | Terms / Privacy Policy | الشروط / سياسة الخصوصية |
| requiredNote | Required | مطلوب |
| orSignUpWith | or sign up with | أو سجّل باستخدام |
| continueButton | Continue | متابعة |
| alreadyOnPulse | Already on Pulse? | لديك حساب على Pulse؟ |
| signInLink | Sign in | تسجيل الدخول |
| errorPasswordShort | Password must be at least 8 characters | يجب ألا تقل كلمة المرور عن 8 أحرف |
| errorEmailExists | An account with this email already exists | يوجد حساب بهذا البريد بالفعل |

## Behavior and navigation
Continue -> Supabase `signUp(email, password)` -> step 2 (code emailed). Back arrow leaves the flow (no dialog). "Sign in" -> S1. TODO: Terms / Privacy -> `/terms`, `/privacy` placeholders [user]. Social -> "Coming soon".

## Data mapping
User input only. Strength computed locally.

## Responsive / a11y
Scrolls; CTA rises over keyboard; password autofill `newPassword`.

## Acceptance checklist
- [ ] 1 of 6 segments green, rest grey; "Required" green at end
- [ ] Red asterisks on Email, Password, checkbox line, and the "* Required" note
- [ ] Meter 3 green + 1 grey + "Good" (only with a 3-score password)
- [ ] Links in the checkbox line green, bold, underlined
- [ ] Continue pinned bottom with "Already on Pulse? Sign in" under it
