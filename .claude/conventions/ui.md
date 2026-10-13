# UI
Covers: theme tokens, shared widgets, l10n, RTL, loading
Does not cover: business logic
Rule: tokens in `lib/core/theme/` (`context.appColors.<token>`, `context.text.<style>` no color, `AppSpacing`/`AppRadius`/`AppShadows`); all `AppTextStyles` `inherit: false`. Assets in `lib/core/constants/app_assets.dart`. RTL: docs/specs/_theme/rtl.md. Specs CSS shorthand `a b c` = top, sides, bottom.
Shared (2+ features) in `lib/core/widgets/` + barrel `widgets.dart` (AppTextField, PillButton, PrimaryButton, SelectableChip, AppDialogShell, ConfirmationDialog folder, LogoTile, LogoLockup, AppLoadingView + AppInlineLoading, ContentWidth, AppSafeArea, AppPage (Scaffold + AppSafeArea + ContentWidth: every screen uses it), LoadingOverlay + `runWithLoadingOverlay`, PulseLineLoader, AppBottomSheet (shared sheet shell), NavClearance (room the shell's nav bar takes)). Feature-only in `presentation/widgets/`. A widget with related files gets its own folder, and only its entry file is exported from the barrel (`confirmation_dialog/`, `loading_overlay/`).
One loader: `AppSpinner`; `PrimaryButton` loading reuses it. A wait the user sits through after an action (saving, skipping, uploading) uses `await runWithLoadingOverlay(context, task, label:, progress:, tone:)`: the screen fades and rises into a frost at once (220 ms) and stays until the task ends, then fades out (160 ms) while the result is already returned (no delay, no minimum time), taps blocked until it is gone, a heartbeat line (`PulseLineLoader`) with an optional label and progress. Never for first-load screens (skeletons) or buttons (they spin).
l10n: gen-l10n `lib/l10n/app_en.arb` (template) + `app_ar.arb`, `context.l10n` (lib/core/extensions/l10n.dart); Arabic drafts tagged `x-review`; unsupported locale -> English.
Safe area: wrap every screen body and bottom sheet in `AppSafeArea`, never a bare `SafeArea` or `bottom: false`. Pass `bottomSpace` = the bottom padding the content already has; the total bottom space is `max(system inset, bottomSpace)`, so Android navigation buttons never hide content and gesture-navigation devices get no extra gap.

Report flow: `ReportSheet.show(context, copy: ReportCopy, onSubmit, tone)` in `lib/core/widgets/report_sheet/` (reasons, note, thanks); `ReportReason` enum in `lib/core/enums/`. `AppBottomSheet.show(tone: SheetTone.dark)` is the story-viewer surface. `context.showSnackBar(msg, actionLabel:, onAction:)` for Undo/Retry.

Never: hard-coded colors/text styles, per-feature copies of shared widgets.
Example: lib/features/auth/presentation/view/sign_in_view.dart
Tokens added: `AppTextStyles.action` (14/700). Fixed (unscaled) layout values carry `// unscaled: <reason>`; `no_unscaled_literals_test` enforces scaled tokens.
