# Notes
- `pinput` pinned ^6.0.2 (7.x needs separate material_ui package; Material class mismatch).
- Local storage only through `LocalStorageService` (`getValue<T>`/`setValue`); each datasource owns its keys; widgets never touch SharedPreferences.
- The saved Home (lists that grow) goes in Hive through `SnapshotStorage` (Hive adapter; keys in `StorageKeys`, JSON strings, cache folder); small flags stay in `LocalStorageService`; signed media links are never stored.
- Config: `lib/core/constants/app_config.dart` (Supabase URL + publishable key, public by design).
- A method called in `BlocProvider.create` (`..decide()`) yields before its first emit so BlocListener subscribes first (SplashCubit).
- Fonts: Sora, Noto Sans, Noto Sans Arabic.
- Migrations [user, 2026-10-20]: every new table gets `revoke all … from anon, authenticated` plus explicit `grant`s for what the app reads or writes directly, in the migration that creates it (tables only reached through `security definer` RPCs get no grant). Supabase no longer grants new `public` tables by default (from 2026-10-30), so a missing grant means "permission denied" after `db reset` or on a branch.
