# Auth: components

Shared by 2+ auth screens. Place in `lib/core/widgets/` if another feature will use it (field, outline button, dialog, chips); otherwise `features/auth/presentation/widgets/`. Reuse `PrimaryButton`, `AppText`, `AppSvgIcon`, `ContentWidth` (existing).

## C1 AuthHeader
Title (`display`) + 8 gap + subtitle (`subtitle`, `textSecondary`). Optional leading `LogoTile` (S1) or `IconTile` (S2, S4). Gap tile -> title 24 [estimated]. Titles wrap to 2 lines; never truncate.

## C2 LogoTile / IconTile
- LogoTile 48 x 48, radius 14, fill `primary`, `assets/icons/logo.svg` recolored white-line on primary (file has its own fills; do not tint) [estimated].
- IconTile 72 x 72, radius 22, fill `primarySoft`, icon 32 `primary` (`ic_lock` S2, `ic_mail` S4) [user]. Top gap from top bar ~ 24 [estimated].

## C3 AuthTextField
Label above (`label` 13/600 `textPrimary`; required adds " *" in `danger`), `labelGap` 6, field, optional helper (`caption`, 6 top gap) or error (replaces helper, `danger`).
Field: white fill, radius 14, 1px `border`, padding 15 v / 16 h, **no fixed height** [user]; hint 15 `textSecondary`; text 15 `textPrimary`. States: focus (`primary` 1.5), error (`danger` 1.5), disabled n/a.
Variants: plain; password (trailing eye `ic_eye` / `ic_eye_off` 22, tap target 44, obscure toggle; Semantics "Show password"/"Hide password"); prefix "@" (username, textSecondary, forced LTR); multiline (bio: 3 lines, counter "n/150" `caption` at end of the label row); read-only tap field (birthday, opens platform date picker).
Gap between fields `fieldGap` 14. Email/username/phone text forced LTR. Keyboard actions and autofill: email `next` + `AutofillHints.email`; sign-in password `done` (submits) + `password`; sign-up password `newPassword`; phone numeric.

## C4 OutlinePillButton / SoftPillButton / DangerPillButton
Pill (full radius). Outline: white, 1px `border`, label 16/700 `textPrimary`, v-padding 15 [user]. Soft: fill `background`, no border, 48 high. Danger: fill `danger`, label white. Pressed: darken fill ~6% / ink. Loading/disabled follow `01-design-tokens.md`.
Add disabled + loading to `PrimaryButton` ([differs]: it currently has neither). Its loading spinner is the shared `AppSpinner` (below).

## C5 SocialButtonsRow
Two equal OutlinePillButtons in a Row, gap 12: "Google", "Apple" (text only, no logos [seen]). Tap -> snackbar "Coming soon" [user]. TODO: replace with Supabase OAuth (Google, Apple) when keys and redirect URIs exist.

## C6 OrDivider
Row: Expanded 1px `divider` line, 12 gap, text, 12 gap, Expanded line. Text from the screen ("or continue with" / "or sign up with").

## C7 StepTopBar (S3..S8)
Row, top padding 16, start 8 (back side) / end 16 [estimated]: back arrow `ic_arrow_back` 24 in 44 box (mirrors in RTL); Expanded column: row with "Step N of 6" (`label` 13/600 `textSecondary`) at start and status ("Required" `primary` 13/600 / "Optional" `textSecondary` 13/600) at end, then 6 progress segments (8 gap above). On S6..S8 a "Skip" text button (16/700 `textSecondary`, 44 high) follows at the end, outside the bar's width [seen]. Progress animates ~200 ms easeInOut [estimated]; fills right to left in RTL [rtl.md].

## C8 PasswordStrengthMeter (S3)
4 segments + word (C3 tokens). Score = count of: length >= 8; has lowercase and uppercase; has digit; has symbol. 0 rules -> hidden. 1 Weak, 2 Fair, 3 Good, 4 Strong [user]. Hidden until the password is non-empty [user]. Semantics: "Password strength: Good".

## C8b PasswordRulesList (S11)
Rows of dot 6 + 12 gap + `caption` 13/400 `textSecondary`, row gap 8. Unmet dot `dashed`; met = `primary` dot with `ic_check`. Rules: length >= 8, has digit, has upper + lower case. Used with the 4 short segments (68 wide, gap 4, not full width) [seen]. Semantics: "<rule>, met/not met".

## C9 LabeledCheckbox (S3)
24 box (20 on S11) + 12 gap + rich text (14/400 `textSecondary`, links 14/700 `primary` underlined, then red " *"). Whole row tappable (44 min). Semantics checked state; links open `/terms` and `/privacy`.

## C10 OtpField (S4) [user: `pinput` package]
6 boxes per `01-design-tokens.md`, numeric keyboard, `AutofillHints.oneTimeCode`, forced LTR in RTL, paste fills all, auto-focus first box, backspace moves back. Error state: all boxes `danger` border + message below. Semantics "Digit N of 6".

## C11 SelectableChip
Pill with label 15/700; selected shows `ic_check` 16 first; used for gender (single-select, tap again clears), interests (multi), and dark variant for S8 tabs (single, no clear). Min tap target 44 (add vertical hit-slop for the 40 dp chips). Semantics `selected`.

## C12 AvatarInitials + FollowRow (S8)
Avatar 48 circle with 2-letter initials. Row: avatar, 12 gap, Expanded column (name `name` 15/700, meta `bodySm` 14/400 `textSecondary`, 1 line each, ellipsis), Follow pill (primary, label 14/700 white, padding 20 h / 8 v). Following state = outline pill, label "Following" `textPrimary` 14/700. Row padding 12; rows live in one white card (radius 22, side margin 12, inner padding 12) with no dividers [seen].

## C13 PhotoPickerAvatar (S6)
88 circle (tokens above) + row text. Tap -> bottom sheet (radius 28 top, `scrim` backdrop) with "Take photo", "Choose from gallery", and "Remove photo" if set (`image_picker`) [user]. Picked image is shown `BoxFit.cover` in the circle (solid border replaces dashed, badge stays); upload to a Supabase Storage bucket on finish of step 4 [user].

## C14 AppDialogShell + ConfirmationDialog (S10, shell also used by S9)
One shared component in `lib/core/widgets/` (used by 2+ features) [user]; reference sheet: `screenshots/confirmation-dialog-component.png` ("One component, six configurations").

**AppDialogShell** (route + card): barrier `scrim` #161A19 @ 40% + `BackdropFilter` blur sigma 12 [user]; card width = screen - 48, max 342, centered; padding 28 vertical / 24 horizontal [seen, sheet]; radius 28, white, dialog shadow; fade + scale from 0.96, 180 ms [estimated]. Barrier tap and Android back close it (returns `false`/null) [estimated]. `Directionality` from locale. Scrolls inside the card at large text scales.

**ConfirmationDialog** = shell + content. Public API: each factory is a static method taking `BuildContext` that shows the dialog and returns `Future<bool?>` (true = confirmed, false/null = cancelled). Factories:

| Factory | Icon tile (56 circle) | Actions | Seen in sheet |
|---|---|---|---|
| `ConfirmationDialog.destructive(icon, title, message, confirmLabel, cancelLabel)` | `dangerSoft` fill, icon `danger` 24 | Row: SoftPill cancel (start) + DangerPill confirm (end), equal width | Log out, Delete this post (and S10 "Leave sign-up?") |
| `ConfirmationDialog.primary(icon, title, message, confirmLabel, cancelLabel)` | `primarySoft` fill, icon `primary` | Row: SoftPill cancel + Primary confirm | Save as draft? |
| `ConfirmationDialog.info(icon, title, message, okLabel)` | `primarySoft` fill, icon `primary` | One full-width Primary pill | Post shared |
| `ConfirmationDialog.stacked(title, message, confirmLabel, cancelLabel, {destructive = true})` | none (no icon) | Column, gap 8: confirm pill on top (danger or primary), SoftPill cancel below; used when labels are long | Discard changes? |

Content: icon tile (optional) > 16 > title (`titleSm`, Sora 20/700 centered [estimated]) > 8 > message (`bodySm` 14/400 `textSecondary`, centered, line height 1.45) > 24 > actions. Buttons 48 high, pill, label 16/700 [estimated]; row gap 12. In RTL the row mirrors (cancel on the right, confirm on the left) [seen, Arabic sheet]. The stacked variant also has no icon and a smaller top gap.
Layout is fixed per factory, never automatic [user]: each factory defines its own title, description, buttons and button layout (destructive/primary = row, info = single, stacked = column). A caller passes the texts (and icon where the factory has one), not the layout.
Semantics: dialog role with title as label; actions >= 44 tall; focus starts on the cancel action for destructive.

`ConfirmationDialog.info` takes `dismissible` (default true); S12 passes false (barrier tap and Android back do nothing) [user].

**Auth usage:** S12 = `ConfirmationDialog.info(icon: ic_check, title: "Password updated", ..., okLabel: "Sign in", dismissible: false)`. S10 = `ConfirmationDialog.destructive(icon: ic_warning, title: "Leave sign-up?", message: ..., confirmLabel: "Leave", cancelLabel: "Keep going")`. S9 is not a confirmation (primary + soft stacked actions and a footer link row): it is custom content placed inside `AppDialogShell`.

## C15 PinnedBottomCta
Bottom area with side padding 24 and bottom padding ~24 [estimated] holding the CTA (+ caption/link). Scrolling content sits above; when the keyboard opens the CTA rises with it and content scrolls (`resizeToAvoidBottomInset`). S8's bottom area has a white-ish bar with top hairline `divider` [seen].

## C16 AppSpinner / AppLoadingView (shared, `lib/core/widgets/`) [user: "make shared loading and show it"]
`AppSpinner`: the app's one circular progress indicator (size, stroke and color from the caller; `PrimaryButton`'s loading state is a 20 dp white, stroke 2 `AppSpinner`). `AppLoadingView`: a `primary` spinner, 32 dp with a 3 stroke, centered in the screen body and announced as "Loading" (`loading` string, Arabic draft `x-review`). Shown by the splash while it resolves the first route and by any screen that waits for its first data [size and stroke estimated].

