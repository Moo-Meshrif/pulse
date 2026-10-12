# Sign in: signed out (S14)
Screenshots: `../screenshots/s14-signin-session-expired.png`, `../screenshots/s14-signin-session-revoked.png` (390 px wide, 1x) [user, 2026-10-12]
Purpose / route: `/sign-in?reason=expired|revoked`. S1 when a session ended: the app knows who it was, so it asks only for the password. Same `SignInScreen` / `SignInCubit` / `SignInView` as S1; this file lists only what differs (everything else = `s1-signin.md`).

> Built 2026-10-12: `SessionBanner`, `AccountCard`, `SignInCubit.start/forgetAccount`, `AppRoutes.signInWith`, splash mapping, `WatchSessionEndedUseCase` + handler in `App`. Password field takes focus when the account is named.

## Layout tree (differences from S1 in bold)
```
Scaffold > SafeArea > scrollable, ContentWidth, side padding 24
├─ LogoTile 48
├─ title "Welcome back"
├─ **subtitle "Enter your password to continue."** (replaces "Sign in to catch up on your feed.")
├─ **SessionBanner (C17)** gap ~28 above [estimated]
├─ **label "Account" + AccountCard (C18)** replaces the "Email or username" field
├─ fieldGap > password field (label "Password", hint "Your password", eye)
├─ "Forgot password?" end-aligned
├─ Sign in (expand)
├─ "or continue with" + Google / Apple
└─ footer "New to Pulse? Create account"
```

## Variants (banner body only) [seen]
| reason | Title | Body |
|---|---|---|
| `expired` (A) | You've been signed out | Your session expired. Sign in again to pick up where you left off. |
| `revoked` (B) | You've been signed out | Your session was ended on another device or after a password change. Sign in again to keep going. |

Chosen by the failure (the splash and any request that fails with it; the app-wide session-ended handler cannot tell a revoked session from an expired one, so it always says A): `AuthFailureReason.sessionExpired` -> A (`session_expired`, `bad_jwt`, expired JWT, not authenticated); `AuthFailureReason.sessionRevoked` -> B (`session_not_found`, `refresh_token_not_found`, `refresh_token_already_used`) [user]. Anything unknown counts as expired.

## Elements (new ones)
| Element | Text | Size | Token | Style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Subtitle | Enter your password to continue. | | textSecondary | subtitle | 8 below title | replaces S1 subtitle |
| Banner | see C17 | w 342, h = content (60 / 84 seen) | primarySoft fill | | gap above field label ~28 [estimated] | not dismissible |
| Account label | Account | | textPrimary | label (13/700) | 8 above card [estimated] | same style as the field labels |
| Account card | see C18 | h 62 [estimated] | surface, 1px border, r14 | | fieldGap below | |
| Password | as S1 | | | | fieldGap below card | focus opens on this field |

## States
- Default: card + password; Sign in disabled until the password has text.
- Loading: spinner in the button, password read-only, "Not you?" disabled.
- Wrong password / throttled / unverified email: as S1 (the identifier sent is the account's username).
- No saved account (never stored or cleared) or saved copy without a username: banner stays (it is about the session), the "Email or username" field shows as in S1 and the subtitle is S1's "Sign in to catch up on your feed." ("Enter your password" only fits with the account named) [user: field; subtitle decided in the build].
- "Not you?": forgets the saved account on this device (profile copy and last-account pointer) and shows the normal S1 form (banner, card and the changed subtitle disappear; the reason is dropped) [user].
- After success: same as S1 (profile complete -> `/home`, incomplete -> `/register?step=N`, `resetTo`).

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| signedOutSubtitle | Enter your password to continue. | أدخل كلمة المرور للمتابعة. |
| signedOutTitle | You've been signed out | تم تسجيل خروجك |
| signedOutExpiredBody | Your session expired. Sign in again to pick up where you left off. | انتهت جلستك. سجّل الدخول مجددًا لتكمل من حيث توقفت. |
| signedOutRevokedBody | Your session was ended on another device or after a password change. Sign in again to keep going. | أُنهيت جلستك على جهاز آخر أو بعد تغيير كلمة المرور. سجّل الدخول مجددًا للمتابعة. |
| accountLabel | Account | الحساب |
| notYou | Not you? | لست أنت؟ |

## Behavior and navigation
- Entered by `resetTo('/sign-in?reason=…')` from (a) the splash when the start-up request fails with a dead session, (b) the app-wide session-ended handler in `App` (any later request or auth event that ends the session), except while on `/reset-password` or the sign-up flow. The app's own sign-out (Leave sign-up, S11 X) never carries a reason.
- The account comes from the profile copy saved on this device (no phone, no birthday), found through a "last account" pointer written whenever that copy is saved, because the session (and so the user id) is gone [user].
- Offline start-up keeps the S13 flow; the banner shows only for a confirmed dead session.
- An unknown or garbled `reason` value = plain S1.

## Data mapping
Card: `LastAccountEntity` (id, fullName, username, avatarUrl). Initials and color from C12 (`AvatarInitials`, color from the user id); photo when `avatarUrl` exists [estimated: S1 screenshots show initials only].

## Responsive / a11y
Banner is a live region announced once on open (title + body as one label); the card is one semantics node "Account, {name}, @{username}" with "Not you?" as its own button; tap targets >= 44; text scale 1.5 wraps the banner and truncates name/username with ellipsis; RTL mirrors (avatar at start, "Not you?" at end), username stays LTR.

## Acceptance checklist
- [ ] Subtitle "Enter your password to continue."
- [ ] Banner A and B match the screenshots (icon, bold title, body, soft green fill)
- [ ] "Account" label + card: 40 initials avatar, bold name, grey @username, green bold "Not you?" at the end
- [ ] No Email/username field; password field below; rest identical to S1
- [ ] "Not you?" returns to the normal S1 form
- [ ] Right banner for expired vs revoked sessions
- [ ] RTL and text scale 2.0 do not overflow
