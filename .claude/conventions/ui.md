# UI
Covers: theme tokens, shared widgets, l10n, RTL, loading
Does not cover: business logic
Rule: tokens in `lib/core/theme/` (`context.appColors.<token>`, `context.text.<style>` no color, `AppSpacing`/`AppRadius`/`AppShadows`); all `AppTextStyles` `inherit: false`. Assets in `lib/core/constants/app_assets.dart`. RTL: docs/specs/_theme/rtl.md. Specs CSS shorthand `a b c` = top, sides, bottom.
Shared (2+ features) in `lib/core/widgets/` + barrel `widgets.dart` (AppTextField, PillButton, PrimaryButton, SelectableChip, AppDialogShell, ConfirmationDialog folder, PinnedBottomCta, LogoTile, LogoLockup, AppSpinner, AppLoadingView, ContentWidth, AppSafeArea). Feature-only in `presentation/widgets/`. A widget with related files gets its own folder.
One loader: `AppSpinner`; `PrimaryButton` loading reuses it.
l10n: gen-l10n `lib/l10n/app_en.arb` (template) + `app_ar.arb`, `context.l10n` (lib/core/extensions/l10n.dart); Arabic drafts tagged `x-review`; unsupported locale -> English.
Safe area: wrap every screen body and bottom sheet in `AppSafeArea`, never a bare `SafeArea` or `bottom: false`. Pass `bottomSpace` = the bottom padding the content already has; the total bottom space is `max(system inset, bottomSpace)`, so Android navigation buttons never hide content and gesture-navigation devices get no extra gap.

Never: hard-coded colors/text styles, per-feature copies of shared widgets.
Example: lib/features/auth/presentation/view/sign_in_view.dart
Tokens added: `AppTextStyles.action` (14/700). Fixed (unscaled) layout values carry `// unscaled: <reason>`; `no_unscaled_literals_test` enforces scaled tokens.
