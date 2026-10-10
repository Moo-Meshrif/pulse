# Architecture
Covers: layering, feature layout, dependency direction, use cases, repositories, datasources
Does not cover: where each kind of file goes (file-placement.md), error types (errors.md)
Rule: `lib/features/<f>/{data,domain,presentation}`, shared `lib/core/`, entry `lib/app/`. Feature = capability, not a table (interests/follows live in `profile`). Repository / entity / use case only when needed.
Datasource per concern: `abstract interface class` + `final class` Supabase adapter in ONE file, `@LazySingleton(as: …)`, returns wire models (or void) and throws `Failure`.
Repository only where sources are coordinated: `ProfileRepository` (abstract + Impl one file; remote + `ProfileLocalDatasource`, network-first, local fallback only on lost connection; maps model -> entity privately; models never import `domain/`).
Features trade ONLY via `domain/use_case/` (`@injectable`, named by intent, smallest return type). `auth` -> `profile` one way; `profile` never imports `auth`/`splash`; nobody imports another feature's datasource/repository/model/entity. Sign-up flow lives in `auth/presentation`.
Never: feature per table, pass-through use cases, cross-feature datasource imports.
Example: lib/features/splash (calls IsSignedInUseCase + GetSignupStepUseCase); lib/features/profile/data/repository
Exceptions: onboarding has no data layer beyond a local flag datasource.
