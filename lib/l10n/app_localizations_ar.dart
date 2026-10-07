// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'pulse';

  @override
  String get back => 'رجوع';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'الصفحة $current من $total';
  }

  @override
  String get onboarding1Title => 'شارك اللحظات التي تحرّكك';

  @override
  String get onboarding1Body =>
      'انشر الصور والقصص من يومك، وتعرّف على ما يفعله أصدقاؤك.';

  @override
  String get onboarding2Title => 'تصفّح مقاطع الفيديو القصيرة';

  @override
  String get onboarding2Body =>
      'مقاطع سريعة بملء الشاشة من المبدعين الذين تتابعهم، وأخرى جديدة نختارها لك.';

  @override
  String get onboarding3Title => 'ابقَ قريبًا عبر الدردشة';

  @override
  String get onboarding3Body =>
      'راسل أصدقاءك فرديًا أو في مجموعات، وأرسل الصور والمقاطع القصيرة والرسائل الصوتية.';
}
