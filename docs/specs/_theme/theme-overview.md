# Theme overview

Source of all values: the "Pulse — Design Spec (Flutter)" document pasted by the user [user]. Tags: `[user]` given by user, `[seen]` visible in screenshot, `[estimated]` by eye, `[unknown]` not known.

## Principles
- All values are logical pixels (dp). Design frame 390 x 844, 1 design px = 1 dp [user]. Never measure screenshots (they are 720 px wide); use the numbers in these specs.
- Wrap screens in `SafeArea`; paddings in specs sit inside it [user].
- Languages: English + Arabic; layouts must work LTR and RTL [user]. RTL rules, including what must NOT mirror and the Arabic type substitutions, are in `rtl.md` [user].
- Modes: **light only for now** [user]. Dark tokens are `[unknown]`. Keep tokens in a `ThemeExtension` (or equivalent) so a dark set can be added later without touching widgets.

## Token -> code mapping
- Kit files `app_colors.dart`, `app_text_styles.dart`, `app_dimens.dart` and `app_assets.dart` are not in the repo. flutter-app-builder creates them from these specs [user].
- Colors: `lib/core/theme/app_colors.dart` (does not exist yet). Names in `colors.md` are the Dart identifiers (camelCase) [user].
- Typography: text styles named as in `typography.md`.
- Spacing / radius / shadows: constants named as in `spacing-radius-shadows.md`.
- Feature specs reference tokens by name (e.g. `colors/primary`), never raw hex.

## Files
- colors.md, typography.md, spacing-radius-shadows.md, icons-and-assets.md, rtl.md
