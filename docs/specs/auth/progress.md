# Progress: auth
Current step: 6 (Verify and hand off) - S11/S12 written, ready for `/spec-to-plan auth`
Screens: S11 set-new-password [written], S12 password-updated-dialog [written], S1 signin [written], S2 forgot-password [written], S3 signup-account [written], S4 signup-verify-email [written], S5 signup-about-you [written], S6 signup-profile [written], S7 signup-interests [written], S8 signup-follow [written], S9 forgot-password-sent-dialog [written], S10 leave-signup-dialog [written]
## Answers so far
All interview answers live in the spec files (tagged [user]/[estimated]); latest:
- Icons ic_warning.svg and ic_trash.svg added by user [user]
- Shared ConfirmationDialog with factories; layout fixed per factory, no auto-switch [user]
- Back arrow steps 4-8 = previous step; step 3 arrow + system back (3-8) = leave dialog [user]
- Leave = sign out then /sign-in [user]
- CLAUDE.md pointer added [user]
## Open questions (pending)
Only TODO items remain in open-questions.md (Supabase schema, Terms/Privacy content, reset-link screen, avatar color rule, estimated spacings, Arabic review).
- NEW: S11 set-new-password (key tile, X close, rules checklist, confirm field, 'Log out of all other devices' checkbox, Update password), S12 password-updated dialog; screenshots copied [user]
- S11: key icon added; rules/segments fill like S3 score; Update enabled when 3 rules met + confirm matches; checkbox default checked -> signOut(others); X -> sign out recovery + /sign-in; S12 = ConfirmationDialog.info, not dismissible, Sign in -> sign out recovery + /sign-in [user]
- Reset flow = email link opens S11 (Supabase can't email a password) [user via screenshots]
- Schema supplied and trimmed (`schema.sql`, not applied); `signup_step` replaces the estimated required-fields resume rule; S1 = Email or username; S10 copy = progress saved; S7/S8 skipped when their list is empty; S8 school line dropped [user]
## Next action
Plan written: docs/plans/auth-plan.md (draft, awaiting approval).
