# Repository Guidelines

## Project Structure & Module Organization

Pulse is a Flutter app organized by feature. Put feature code in `lib/features/<feature>/`, using `data/`, `domain/`, and `presentation/` where needed. Shared business concepts live in `lib/shared/`; infrastructure, theme, routing, and reusable widgets live in `lib/core/`. Keep dependencies directed toward `core`: features may use `shared` and `core`, while `shared` may use `core`. Platform projects are in `android/` and `ios/`; assets are in `assets/`, localization files in `lib/l10n/`, and Supabase migrations and functions in `supabase/`. Tests mirror `lib/` under `test/`.

## Build, Test, and Development Commands

Use the Flutter version pinned by FVM:

- `fvm flutter pub get` installs dependencies.
- `fvm flutter run` runs the app on a connected device or emulator.
- `fvm flutter analyze` runs static analysis and lint checks.
- `fvm flutter test` runs the test suite; append a test path to run one file.
- `fvm dart run build_runner build --delete-conflicting-outputs` regenerates injectable and Freezed code after relevant changes.
- `fvm flutter gen-l10n` regenerates localization code from ARB files.

## Coding Style & Naming Conventions

Format Dart with `fvm dart format .` and follow `analysis_options.yaml`, including strict types and relative imports. Use two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Use Cubits for feature state and existing theme tokens and shared widgets for UI. Read `.project/project-conventions.md` for detailed conventions and the relevant `docs/specs/<feature>/00-overview.md` before UI work.

## Testing Guidelines

Use `flutter_test`, `bloc_test`, and `mocktail` as appropriate. Name tests `*_test.dart` and place them alongside the corresponding structure under `test/`. Reuse `test/helpers/pump_app.dart` for widget setup and assert localized text through generated localization strings. Run the affected tests and static analysis before submitting changes; no repository-wide coverage threshold is specified.

## Commit & Pull Request Guidelines

Recent commits use concise, imperative Conventional Commit subjects, often with scopes, such as `fix(db): align migration history` or `feat(post): add a likes list`. Describe the behavior and motivation in pull requests, link relevant issues, and include screenshots for visible UI changes. Report the checks run and any remaining limitations.
