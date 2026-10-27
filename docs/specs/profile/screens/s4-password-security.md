# Password & security (S4)
Screenshot: `../screenshots/s4-password-security.png`
Purpose / route: `/settings/security`.

## Layout tree
```
Scaffold (background), scroll, side margin 12
├─ AppTopBar back + "Password & security"
├─ Section "CHANGE PASSWORD": card
│  ├─ "Current password" field (obscured)  ├─ "New password" (hint "At least 8 characters")  ├─ "Confirm new password" (hint "Type it again")
│  └─ Row: link "Forgot password?" (primary 15/700) + "Update" pill (primary, height ~44)
├─ Section "LOGIN PROTECTION": card [SwitchRow "Two-factor authentication", SwitchRow "Login alerts"]
├─ Section "WHERE YOU'RE LOGGED IN": card [DeviceRow x3]
└─ DangerButtonCard "Log out of all other devices"
```
DeviceRow: grey tile 40 (ic_phone / ic_laptop, `surfaceMuted`), title `body` ("iPhone 15 · This device"), subtitle `bodyXs` ("Cairo · Active now" in primary for this device; "Cairo · 2 hours ago" textSecondary), trailing outline "Log out" pill (not on this device).

## States
Fields in the card use `surfaceMuted` fill; eye toggle on each field; Update disabled until current filled, new meets rules and confirm matches; loading; wrong current password error; success notice. 2FA, Login alerts, device list: coming soon (see below).

## Strings
| key | en | ar (x-review) |
|---|---|---|
| securityTitle | Password & security | كلمة المرور والأمان |
| changePasswordSection | Change password | تغيير كلمة المرور |
| currentPassword / newPassword / confirmNewPassword | Current password / New password / Confirm new password | كلمة المرور الحالية / كلمة المرور الجديدة / تأكيد كلمة المرور الجديدة |
| newPasswordHint / confirmHint | At least 8 characters / Type it again | 8 أحرف على الأقل / اكتبها مرة أخرى |
| forgotPassword | Forgot password? | نسيت كلمة المرور؟ |
| update | Update | تحديث |
| loginProtection | Login protection | حماية تسجيل الدخول |
| twoFactor / Sub | Two-factor authentication / Ask for a code when signing in on a new device | المصادقة الثنائية / اطلب رمزًا عند تسجيل الدخول من جهاز جديد |
| loginAlerts / Sub | Login alerts / Tell me about logins from new places | تنبيهات تسجيل الدخول / أخبرني عن تسجيل الدخول من أماكن جديدة |
| whereLoggedIn | Where you're logged in | الأجهزة المسجّل عليها |
| thisDevice / activeNow / hoursAgo | This device / Active now / {n} hours ago | هذا الجهاز / نشط الآن / قبل {n} ساعات |
| logOut | Log out | تسجيل الخروج |
| logOutOthers | Log out of all other devices | تسجيل الخروج من كل الأجهزة الأخرى |
| logOutOthersTitle / Body | Log out other devices? / They will need to sign in again. | تسجيل الخروج من الأجهزة الأخرى؟ / سيحتاجون إلى تسجيل الدخول مرة أخرى. |
| passwordUpdated | Password updated | تم تحديث كلمة المرور |
| wrongCurrentPassword | Current password is wrong | كلمة المرور الحالية غير صحيحة |
| comingSoon | This is coming soon | هذه الميزة قادمة قريبًا |

## Behavior and navigation
Update: verify the current password (re-sign-in call), then update the password with the same rules and strength checks as sign-up/reset (S3 auth); success -> notice, fields cleared. Forgot password -> existing email reset flow (sends the link to the account email, notice "email sent"). Log out of all other devices: `ConfirmationDialog` -> sign out other sessions (existing auth call) -> notice. Two-factor, Login alerts: shown disabled (40% opacity), tap -> "coming soon" notice. Device list: coming soon: the card shows a single row for "This device" only with the real device name [Q-S4-1].

## Data mapping
Supabase auth (update user password, sign out `others` scope). Device name from the device info plugin; city/time: none (hidden for this device).

## Responsive / a11y
Obscured fields: eye toggle labelled "Show/Hide password". RTL: link on the start side, Update on the end side.

## Acceptance checklist
- Fields on `surfaceMuted` inside the white card; link and Update on one row.
- Switches on, thumbs white; device rows with grey 40 tile; red full-width card at the bottom.
