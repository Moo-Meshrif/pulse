import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers third-party / app-level instances that can't be annotated directly.
@module
abstract class AppModule {
  /// Resolved before the first frame: the start-up route depends on the "seen onboarding" flag.
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
