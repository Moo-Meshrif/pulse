# Leave sign-up (S10)
Screenshot: ../screenshots/s10-leave-signup-dialog.png (390 px = 1x), taken over S6
Purpose / route: built with the shared `ConfirmationDialog.destructive` (02-components.md C14); confirmation dialog (C14) when the user leaves the sign-up flow after the account exists. Blur behind, same as S9 [user].

## Layout tree
```
Barrier: scrim @ 40% + blur sigma 12
Card (342 wide, centered, padding 28 v / 24 h, radius 28, white)
├─ Circle 56 dangerSoft + warning triangle icon 24 danger (centered)
├─ 16 > "Leave sign-up?" (`titleSm` Sora 20/700 centered) [estimated, from the shared sheet]
├─ 8 > body (subtitle 15, centered, 2-3 lines): "Your progress is saved. You can pick up where you left off the next time you sign in." [user, resume at saved step]
└─ 24 > Row gap 12: SoftPillButton "Keep going" | DangerPillButton "Leave" (equal width, 48 high)
```

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| leaveTitle | Leave sign-up? | مغادرة التسجيل؟ |
| leaveBody | Your progress is saved. You can pick up where you left off the next time you sign in. | تم حفظ تقدمك. يمكنك المتابعة من حيث توقفت في المرة القادمة التي تسجّل فيها الدخول. |
| keepGoing | Keep going | واصل |
| leave | Leave | مغادرة |

## Behavior and navigation
Keep going / barrier tap / system back: close, stay. Leave: sign out of Supabase, then `AppNavigator.resetTo('/sign-in')` [user]; the next launch or sign-in resumes at the saved step (`profiles.signup_step`) [user]. Shown on any exit from steps 3-8 (back arrow or system back) [user]; see 00-overview.md for the reading used for the back arrow on steps 4-8.

## Data mapping
Static.

## Responsive / a11y
Semantics dialog with title; buttons >= 44 tall; text scale wraps.

## Acceptance checklist
- [ ] Pink round icon with red triangle, bold title, 2-3 line body
- [ ] Grey "Keep going" left, red "Leave" right with white text (mirrors in RTL)
- [ ] Background blurred and dimmed
