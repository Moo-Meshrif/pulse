# Auth: overview

Platform: Flutter, phone, 390 x 844 design frame, **light only**, LTR + RTL, English + Arabic [user]. No Figma link; screenshots + interview are the source. Screenshots are 720 px wide (1.846x) except S9 (780 px, 2x) and S10 (390 px, 1x). Measurements below are px / scale = dp, tagged `[estimated]` unless the user gave them.
Theme: reuse `../_theme/` and `lib/core/theme/` (`context.appColors`, `context.text`, `AppSpacing`, `AppRadius`, `AppShadows`). Deltas only in `01-design-tokens.md`. RTL rules: `../_theme/rtl.md`.
Backend: **Supabase now, RESTful API later** [user]. Schema: `schema.sql` (trimmed to these specs). Put Supabase behind datasource interfaces (an interface + Supabase adapter per concern, in one file) so the REST swap changes only the data layer. Architecture rules: see *Structure* below.

## Screens
| ID | Name | File | Screenshot | Route |
|---|---|---|---|---|
| S1 | Sign in | screens/s1-signin.md | screenshots/s1-signin.png | `/sign-in` |
| S2 | Forgot password | screens/s2-forgot-password.md | screenshots/s2-forgot-password.png | `/forgot-password` |
| S3 | Sign-up 1: Account | screens/s3-signup-account.md | screenshots/s3-signup-account.png | `/register` step 1 |
| S4 | Sign-up 2: Verify email | screens/s4-signup-verify-email.md | screenshots/s4-signup-verify-email.png | step 2 |
| S5 | Sign-up 3: About you | screens/s5-signup-about-you.md | screenshots/s5-signup-about-you.png | step 3 |
| S6 | Sign-up 4: Profile | screens/s6-signup-profile.md | screenshots/s6-signup-profile.png | step 4 |
| S7 | Sign-up 5: Interests | screens/s7-signup-interests.md | screenshots/s7-signup-interests.png | step 5 |
| S8 | Sign-up 6: Follow | screens/s8-signup-follow.md | screenshots/s8-signup-follow.png | step 6 |
| S9 | Forgot password: link sent (dialog over S2) | screens/s9-forgot-password-sent-dialog.md | screenshots/s9-forgot-password-sent-dialog.png | dialog |
| S10 | Leave sign-up (dialog over S6) | screens/s10-leave-signup-dialog.md | screenshots/s10-leave-signup-dialog.png | dialog |
| S11 | Set a new password | screens/s11-set-new-password.md | screenshots/s11-set-new-password.png | `/reset-password` |
| S13 | Splash: loading, offline, can't reach | screens/s13-splash.md | screenshots/s13-splash-*.png | `/` (after onboarding) |
| S12 | Password updated (dialog over S11) | screens/s12-password-updated-dialog.md | screenshots/s12-password-updated-dialog.png | dialog |

Also needed, not designed: TODO: `/terms` and `/privacy` in-app placeholder screens [user]; TODO: `/home` placeholder until specced [user]; TODO: Supabase recovery deep link: URL scheme + redirect URL configuration; Expired/invalid link state: specced in S11 [user, default accepted].

## Navigation map
```
/ (start) --no session--> /sign-in (S1)      --session + profile complete--> /home
                          --session + profile incomplete--> /register step 3 (S5) [user]
S1 --"Forgot password?"--> S2 --Send reset link--> S9 dialog (over S2)
S1 --"Create account"--> /register (S3)       S3 --"Sign in"--> S1
S1 --Sign in ok--> /home (AppNavigator.resetTo)   unverified email --> S4 (verify step)
S2 --back arrow / "Back to sign in"--> S1
Email link (deep link) --> S11 --Update password--> S12 dialog --Sign in--> S1 (sign out recovery session, resetTo)   S11 --X--> S1
S9 --Open email app--> mailto:   --Back to sign in--> S1 (resetTo)
S9 --Resend link--> resend (cooldown)   --Change email--> close dialog, focus S2 email field [estimated]
S3 -> S4 -> S5 -> S6 -> S7 -> S8 --Continue--> /home (resetTo)
S6/S7/S8 Skip --> next step; S8 Skip --> /home. S6 Continue/Skip skips S7 when the interests list is empty; S7 Continue/Skip skips S8 (straight to /home) when Suggested and Popular are both empty
Back: S3 leaves flow; S4 -> S3; S5 back = leave via S10 dialog (account verified, S4 not revisitable);
      S6 -> S5, S7 -> S6, S8 -> S7. System back identical to the arrow.
S10 (leave dialog) shows on any exit from steps 3-8, back arrow or system back [user, Q1]. Reading used here: the back arrow on step 3 and the system back on steps 3-8 open S10; the back arrow on steps 4-8 still goes to the previous step [user, confirmed].
```

## Structure
- **Architecture (final rules, from review; builder skill `architecture.md` → *The rules in one list*):**
  - A feature is a capability, not a table. `auth` = session (sign in, forgot / reset password, sign-up flow S3-S8 + S10 and their screens). `profile` = the user's profile, interests and follows (data, no screens yet). `splash` = the first-route decision. Interests and follows are NOT features: they belong to `profile`.
  - Data: a datasource per concern, each an `abstract interface class` + Supabase adapter in one file (`auth_datasource.dart`; `profile_datasource.dart`, `interests_datasource.dart`, `follows_datasource.dart`), returning wire `data/model` classes (enums with their wire values in `data/enums`). Only datasources touch Supabase.
  - A repository only where sources are coordinated: `ProfileRepository` (abstract + Impl, one file) writes through to `ProfileLocalDatasource` ("update profile saves it locally"; never phone or birthday), reads network-first with the saved copy only on a lost connection, and maps `ProfileModel` -> `ProfileEntity`. `auth` has no repository.
  - An entity only where the concept differs from the model (`ProfileEntity`); interests and suggested profiles are used as models.
  - Features trade only through use cases (`domain/use_case/`): `IsSignedInUseCase` (auth), `GetSignupStepUseCase` (profile), plus the use cases the sign-up flow needs from `profile` (S5-S8). One way: `auth` and `splash` call `profile`, `profile` never imports them; nobody imports another feature's datasource, repository, model or entity.
  - `splash` shows the shared loading view (`AppLoadingView`, `02-components.md` C16) while it decides the first route; the Cubit method called from `BlocProvider.create` yields before its first emit.
- S1, S2 are standalone screens, each with its own Cubit.
- S3..S8 are the views of one `SignUpFlow` screen: one `SignUpCubit`, steps swapped without swipe, shared `StepTopBar` (progress animates; fills right to left in RTL) [user].
- Resume: on app start read `profiles.signup_step` from Supabase (3..6 = next step, 0 = complete) [user, schema]; a value of 3 to 6 opens the flow at that step (at least step 3). The DB blocks leaving step 3 until full_name, username and birthday are set.

## Files
01-design-tokens.md, 02-components.md, screens/*, assets.md, open-questions.md, progress.md
