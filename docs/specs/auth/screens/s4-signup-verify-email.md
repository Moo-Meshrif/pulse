# Sign-up 2: Verify email (S4)
Screenshot: ../screenshots/s4-signup-verify-email.png
Purpose / route: step 2 of `SignUpFlow`. Also shown when sign-in finds an unverified email.

## Layout tree
```
StepTopBar (Step 2 of 6, 2 filled, "Required")
side padding 24
├─ IconTile 72 (ic_mail) > 24 > title "Check your email" > 8 > subtitle (rich: bold masked email)
├─ ~32 > OtpField (6 boxes, 4th focused in screenshot)
├─ ~24 > "Didn't get it? " + "Resend code" (15, primary bold; cooldown "Resend code in 0:30", disabled grey)
PinnedBottomCta: PrimaryButton "Verify" (expand) + ~12 + "Use a different email" (15/700 primary, centered)
```

## States
- Empty / partial: Verify disabled until 6 digits [user].
- Loading on Verify. Wrong code: boxes `danger` border + "Wrong code, try again" below [user].
- Resend: 30 s cooldown, label "Resend code in 0:30" counting down [user].
- Masked email: first 3 chars of the local part + "•••" + "@domain" (e.g. dip•••@gmail.com); fewer than 3 chars -> show all + "•••" [estimated rule].

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| verifyTitle | Check your email | تحقق من بريدك |
| verifySubtitle | We sent a 6-digit code to {email}. Enter it below to verify your account. | أرسلنا رمزًا من 6 أرقام إلى {email}. أدخله أدناه للتحقق من حسابك. |
| didntGetIt | Didn't get it? | لم يصلك؟ |
| resendCode | Resend code | إعادة إرسال الرمز |
| resendIn | Resend code in {time} | إعادة الإرسال خلال {time} |
| verify | Verify | تحقق |
| useDifferentEmail | Use a different email | استخدام بريد آخر |
| errorWrongCode | Wrong code, try again | رمز غير صحيح، حاول مرة أخرى |

## Behavior and navigation
Verify -> `verifyOTP(type: signup)` -> step 3. Resend -> `resend(type: signup)`. "Use a different email" and back arrow -> step 1 (email kept editable) [estimated]. Step 2 is not revisitable after success [user].

## Data mapping
Email from step 1 (or from S1). Code user input, forced LTR.

## Responsive / a11y
Numeric keyboard; `oneTimeCode` autofill; Semantics "Digit N of 6"; boxes shrink to fit narrow widths (min 44 wide).

## Acceptance checklist
- [ ] Mail tile, title, 2-line subtitle with bold masked email
- [ ] 3 filled boxes with green border, 1 focused with dark border, 2 idle grey
- [ ] "Resend code" green bold after grey "Didn't get it?"
- [ ] Verify pinned bottom, "Use a different email" below
