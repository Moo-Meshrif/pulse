# Password updated (S12)
Screenshot: ../screenshots/s12-password-updated-dialog.png (390 px = 1x), over S11
Purpose / route: success dialog built with the shared `ConfirmationDialog.info` (02-components.md C14), blur behind [user].

## Layout tree
```
Barrier: scrim @ 40% + blur sigma 12 (AppDialogShell)
Card (342 wide, padding 28 v / 24 h, radius 28)
├─ Circle 56 primarySoft + ic_check 24 primary
├─ 16 > "Password updated" (titleSm Sora 20/700 centered)
├─ 8 > body (bodySm centered, 3 lines): "You can now sign in with your new password. Other devices have been logged out."
└─ 24 > PrimaryPill "Sign in" (48 high, full width)
```

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| updatedTitle | Password updated | تم تحديث كلمة المرور |
| updatedBodyOthers | You can now sign in with your new password. Other devices have been logged out. | يمكنك الآن تسجيل الدخول بكلمة مرورك الجديدة. تم تسجيل الخروج من الأجهزة الأخرى. |
| updatedBody | You can now sign in with your new password. | يمكنك الآن تسجيل الدخول بكلمة مرورك الجديدة. |
| signIn | Sign in | تسجيل الدخول |
`updatedBody` (without the second sentence) is used when the checkbox was unchecked [estimated].

## Behavior and navigation
"Sign in": sign out the recovery session, `AppNavigator.resetTo('/sign-in')` [user]. Not dismissible: barrier tap and Android back do nothing [user].

## Data mapping
Static; body variant from the checkbox value.

## Responsive / a11y
Dialog Semantics with the title; button >= 44; text scale wraps.

## Acceptance checklist
- [ ] Green check circle, bold centered title, 3-line body, one full-width green pill
- [ ] S11 blurred and dimmed behind
