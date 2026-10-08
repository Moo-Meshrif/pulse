import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers third-party / app-level instances that can't be annotated directly.
@module
abstract class AppModule {
  /// Resolved before the first frame: the start-up route depends on the "seen onboarding" flag.
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// The Supabase client. `main()` initializes Supabase (which restores the stored session) before the
  /// container is built; tests that do not touch the backend never resolve this.
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
