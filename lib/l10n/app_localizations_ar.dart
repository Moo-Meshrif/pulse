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
  String get terms => 'الشروط';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get comingSoon => 'قريبًا';

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

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String stepOf(int n) {
    return 'الخطوة $n من 6';
  }

  @override
  String get required => 'مطلوب';

  @override
  String get optional => 'اختياري';

  @override
  String get strengthWeak => 'ضعيفة';

  @override
  String get strengthFair => 'مقبولة';

  @override
  String get strengthGood => 'جيدة';

  @override
  String get strengthStrong => 'قوية';

  @override
  String passwordStrength(String strength) {
    return 'قوة كلمة المرور: $strength';
  }

  @override
  String otpDigit(int n) {
    return 'الرقم $n من 6';
  }

  @override
  String ruleMet(String rule) {
    return '$rule، محققة';
  }

  @override
  String ruleNotMet(String rule) {
    return '$rule، غير محققة';
  }

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get offlineTitle => 'أنت غير متصل بالإنترنت';

  @override
  String get offlineBody =>
      'تحقق من شبكة Wi-Fi أو بيانات الجوال. سنحاول مرة أخرى فور عودة الاتصال.';

  @override
  String get cantReachTitle => 'تعذّر الوصول إلى Pulse';

  @override
  String get cantReachBody =>
      'حدث خطأ من جانبنا. حسابك بأمان، يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get signInTitle => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول لتلحق بآخر ما في موجزك.';

  @override
  String get identifierLabel => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'كلمة المرور الخاصة بك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get orContinueWith => 'أو تابع باستخدام';

  @override
  String get newToPulse => 'جديد على Pulse؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get errorCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get errorIdentifierRequired => 'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get errorPasswordRequired => 'أدخل كلمة المرور';

  @override
  String errorTooManyAttempts(String time) {
    return 'محاولات كثيرة جدًا. حاول مرة أخرى بعد $time.';
  }

  @override
  String get errorNetwork => 'لا يوجد اتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get forgotTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotSubtitle =>
      'أدخل البريد المرتبط بحسابك وسنرسل لك رابط إعادة التعيين.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get backToSignIn => 'العودة إلى تسجيل الدخول';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get sentTitle => 'تحقق من بريدك';

  @override
  String sentBody(String email) {
    return 'أرسلنا رابط إعادة التعيين إلى $email. افتحه لتعيين كلمة مرور جديدة.';
  }

  @override
  String get openEmailApp => 'فتح تطبيق البريد';

  @override
  String get noEmailApp => 'لم يتم العثور على تطبيق بريد';

  @override
  String get didntGetIt => 'لم يصلك؟';

  @override
  String get resendLink => 'إعادة إرسال الرابط';

  @override
  String resendLinkIn(String time) {
    return 'إعادة الإرسال خلال $time';
  }

  @override
  String get changeEmail => 'تغيير البريد';

  @override
  String get linkResent => 'تم إرسال الرابط مرة أخرى';
}
