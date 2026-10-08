# Sign in (S1)
Screenshot: ../screenshots/s1-signin.png (720 px)
Purpose / route: `/sign-in`. Entry for returning users. `SignInScreen` provides `SignInCubit`; `SignInView` is pure UI.

## Layout tree
```
Scaffold (bg background) > SafeArea > scrollable, ContentWidth, side padding 24
├─ LogoTile 48 (top ~56 from frame top [estimated])
├─ gap 24 > title "Welcome back" (display) > gap 8 > subtitle
├─ gap ~32 > AuthTextField "Email" (hint you@example.com)
├─ fieldGap 14 > AuthTextField "Password" (hint "Your password", eye)
├─ gap ~14 > "Forgot password?" end-aligned (14/700 primary, 44 tap)
├─ gap ~24 > PrimaryButton "Sign in" (expand)
├─ gap ~24 > OrDivider "or continue with"
├─ gap ~20 > SocialButtonsRow
└─ Spacer, bottom (centered, ~28 above bottom): "New to Pulse? " (15/400 textSecondary) + "Create account" (15/700 primary)
```

## Elements
| Element | Text | Size | Token | Style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Title | Welcome back | - | textPrimary | display | | |
| Subtitle | Sign in to catch up on your feed. | - | textSecondary | subtitle | 8 below title | |
| Identifier field | label "Email or username" [user, as in screenshot], hint you@example.com | pad 15/16 | border | label / 15 | | email or username; forced LTR |
| Password field | label "Password" | | border | | 14 above | eye toggle |
| Forgot link | Forgot password? | 44 tap | primary | 14/700 | end aligned | -> S2 |
| Sign in | Sign in | 56 | primary | button | | disabled/loading per tokens |
| Footer | New to Pulse? Create account | | textSecondary / primary | 15 | bottom | -> /register |

## States
- Default: Sign in enabled. Pressing it with an empty field shows a danger caption under that field ("Enter your email or username" / "Enter your password") and sends nothing; typing clears it [user].
- Loading: spinner in button, fields read-only.
- Error: wrong credentials (or unknown username) -> snackbar "Incorrect email or password" [user]. No format error: a value containing "@" is treated as an email, anything else as a username [user].
- Unverified email: the function answers 403 with the account's email only after the correct password; go to S4 with that email (returned in `AuthFailure.email`, the field may have held a username) and send a new code [user].
- Too many attempts (`AuthFailure(tooManyAttempts, retryAfter)`): snackbar "Too many attempts. Try again in {time}." (a lost connection shows "No connection…" and anything else "Something went wrong…", all worded by `Failure.l10n(context)`) and Sign in stays disabled until the countdown ends; {time} is formatted like the resend cooldown. Limits: 5 / minute per IP, 5 / 15 minutes per identifier (constants at the top of `supabase/functions/sign-in/index.ts`). [draft: built in Phase 4; Arabic x-review]
- Social: snackbar "Coming soon". TODO: real Google/Apple sign-in later.

## Strings
| Key | en | ar [draft, x-review] |
|---|---|---|
| signInTitle | Welcome back | مرحبًا بعودتك |
| signInSubtitle | Sign in to catch up on your feed. | سجّل الدخول لتلحق بآخر ما في موجزك. |
| identifierLabel | Email or username | البريد الإلكتروني أو اسم المستخدم |
| emailHint | you@example.com | you@example.com |
| passwordLabel | Password | كلمة المرور |
| passwordHint | Your password | كلمة المرور الخاصة بك |
| forgotPassword | Forgot password? | نسيت كلمة المرور؟ |
| signInButton | Sign in | تسجيل الدخول |
| orContinueWith | or continue with | أو تابع باستخدام |
| google / apple | Google / Apple | Google / Apple |
| newToPulse | New to Pulse? | جديد على Pulse؟ |
| createAccount | Create account | إنشاء حساب |
| errorCredentials | Incorrect email or password | البريد الإلكتروني أو كلمة المرور غير صحيحة |
| errorTooManyAttempts | Too many attempts. Try again in {time}. | محاولات كثيرة جدًا. حاول مرة أخرى بعد {time}. [draft, x-review] |
| comingSoon | Coming soon | قريبًا |
| showPassword / hidePassword | Show password / Hide password | إظهار كلمة المرور / إخفاء كلمة المرور |

## Behavior and navigation
Sign in -> `AuthDatasource.signIn(identifier, password)`: the app calls the Edge Function `sign-in` with the identifier (email, or a username = anything without an "@") and the password; the function checks the password server-side and answers with tokens only, and the app stores the session (`setSession`). An unknown username, an unknown email and a wrong password all give the same answer ("Incorrect email or password"). The app never receives an account's email before a correct password -> success: check profile complete; complete -> `/home` via `AppNavigator.resetTo`; incomplete -> `/register` step 3 [user]. Keyboard: email `next`, password `done` submits. Screen scrolls when the keyboard opens.

## Data mapping
Both fields user input. Password never logged. Error text static (mapped from Supabase error codes).

## Responsive / a11y
Scrolls on small phones; ContentWidth on tablets; text scale 1.5 wraps; eye toggle Semantics; tap targets >= 44.

## Acceptance checklist
- [ ] Logo tile top-left, 48 dp, green with white pulse line
- [ ] Title/subtitle text and weights match; subtitle grey
- [ ] Label "Email or username"; fields white, r14, 1px border, hints grey; eye icon trailing (leading in RTL)
- [ ] "Forgot password?" end-aligned green bold
- [ ] Sign in pill green, full width; Google/Apple equal-width outline pills, no logos
- [ ] Footer centered near bottom, "Create account" green bold
- [ ] RTL: everything mirrors, hint/email stay LTR
