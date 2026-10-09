# Project Conventions
Verified: 2026-10-08 · pubspec.yaml 2026-10-08

Architecture: feature-first, datasource interface+adapter, repository only for profile, cross-feature via use cases → conventions/architecture.md
State: flutter_bloc Cubit on BaseCubit; freezed only for data states → conventions/state.md
Navigation: built-in Navigator, lib/core/router/, AppNavigator.resetTo → conventions/navigation.md
DI: get_it + injectable, lib/core/di/ → conventions/di.md
Errors: Result<T>/Guard, lib/core/error/ → conventions/errors.md
Serialization: hand-written models + JsonMapper → conventions/serialization.md
UI: tokens lib/core/theme/, shared widgets lib/core/widgets/, gen-l10n EN+AR → conventions/ui.md
Testing: test/ mirrors lib/, helpers/pump_app.dart → conventions/testing.md
File placement: data/{datasource,model,enums}, presentation/{screen,view,cubit,widgets,utils} → conventions/file-placement.md
Notes: pinned pinput, storage, config → conventions/notes.md
