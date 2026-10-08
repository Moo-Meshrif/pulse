/// Backend configuration. The anon / publishable key is public by design (row level security
/// protects the data), so it is a plain constant, not a secret.
abstract final class AppConfig {
  /// Supabase project "pulse" (eu-west-1).
  static const supabaseUrl = 'https://xwldtqsvcpyzktysgmuv.supabase.co';
  static const supabasePublishableKey =
      'sb_publishable_q6R0ckxmE3v96wzL13aXYQ_iMrBfd0L';

  /// Where the password-reset email link opens the app. It must be in Supabase's allowed redirect URLs
  /// (Authentication -> URL Configuration); the native URL scheme is set up with the deep link (Phase 10).
  static const recoveryRedirectUrl = 'pulse://reset-password';
}
