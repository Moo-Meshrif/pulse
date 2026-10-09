# Notes
- `pinput` pinned ^6.0.2 (7.x needs separate material_ui package; Material class mismatch).
- Local storage only through `LocalStorageService` (`getValue<T>`/`setValue`); each datasource owns its keys; widgets never touch SharedPreferences.
- Config: `lib/core/constants/app_config.dart` (Supabase URL + publishable key, public by design).
- A method called in `BlocProvider.create` (`..decide()`) yields before its first emit so BlocListener subscribes first (SplashCubit).
- Fonts: Sora, Noto Sans, Noto Sans Arabic.
