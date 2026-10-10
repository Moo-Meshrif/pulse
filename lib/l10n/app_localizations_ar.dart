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
  String get errorCredentials =>
      'البريد الإلكتروني/اسم المستخدم أو كلمة المرور غير صحيحة';

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
  String get errorEmailSend =>
      'تعذّر إرسال البريد الإلكتروني حالياً. حاول مرة أخرى بعد قليل.';

  @override
  String get errorRateLimited => 'طلبات كثيرة. انتظر قليلاً ثم حاول مرة أخرى.';

  @override
  String get errorServer => 'تعذّر إكمال طلبك حالياً. حاول مرة أخرى بعد قليل.';

  @override
  String get errorWeakPassword =>
      'كلمة المرور ضعيفة جدًا. استخدم كلمة أطول تحتوي على أحرف وأرقام ورموز.';

  @override
  String get errorSamePassword =>
      'يجب أن تختلف كلمة المرور الجديدة عن القديمة.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية هذا الرابط. اطلب رابطًا جديدًا وحاول مرة أخرى.';

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

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpSubtitle => 'ابدأ ببريدك الإلكتروني وكلمة مرور فقط.';

  @override
  String get passwordHintMin => '8 أحرف على الأقل';

  @override
  String get agreePrefix => 'أوافق على';

  @override
  String get agreeAnd => 'و';

  @override
  String get orSignUpWith => 'أو سجّل باستخدام';

  @override
  String get continueButton => 'متابعة';

  @override
  String get alreadyOnPulse => 'لديك حساب على Pulse؟';

  @override
  String get errorPasswordShort => 'يجب ألا تقل كلمة المرور عن 8 أحرف';

  @override
  String get errorEmailExists => 'يوجد حساب بهذا البريد بالفعل';

  @override
  String get errorAccountNotFound => 'لا يوجد حساب بهذا البريد';

  @override
  String get verifyTitle => 'تحقق من بريدك';

  @override
  String verifySubtitle(String email) {
    return 'أرسلنا رمزًا من 6 أرقام إلى $email. أدخله أدناه للتحقق من حسابك.';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendCodeIn(String time) {
    return 'إعادة الإرسال خلال $time';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get useDifferentEmail => 'استخدام بريد آخر';

  @override
  String get errorWrongCode => 'رمز غير صحيح، حاول مرة أخرى';

  @override
  String get aboutTitle => 'عنك';

  @override
  String get aboutSubtitle => 'بهذه الطريقة سيجدك الناس على Pulse.';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'اسمك';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get usernameHint => 'اسم المستخدم';

  @override
  String get usernameHelper =>
      'الأحرف والأرقام والنقاط والشرطة السفلية. 3 أحرف على الأقل.';

  @override
  String get birthdayLabel => 'تاريخ الميلاد';

  @override
  String get birthdayHint => 'DD / MM / YYYY';

  @override
  String get birthdayHelper =>
      'يُستخدم للتأكد من عمرك. لا يظهر في ملفك الشخصي.';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get genderOptional => '(اختياري)';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderPreferNot => 'أفضّل عدم الذكر';

  @override
  String get errorUsernameTaken => 'اسم المستخدم مستخدم بالفعل';

  @override
  String get errorMinAge => 'يجب أن يكون عمرك 18 عامًا على الأقل';

  @override
  String get profileTitle => 'أعدّ ملفك الشخصي';

  @override
  String get profileSubtitle =>
      'كل شيء اختياري. يمكنك إضافته لاحقًا من الإعدادات.';

  @override
  String get addPhoto => 'أضف صورة';

  @override
  String get addPhotoHint =>
      'الملفات التي تحتوي على صورة تحصل على متابعين أكثر.';

  @override
  String get bioLabel => 'نبذة';

  @override
  String get bioHint => 'بضع كلمات عنك';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get cityHint => 'أين تقيم؟';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => '••• ••• ••••';

  @override
  String get photoSheetTitle => 'صورة الملف الشخصي';

  @override
  String get countryPickerTitle => 'اختر الدولة';

  @override
  String get countrySearchHint => 'ابحث عن دولة أو رمز';

  @override
  String get countryNoResults => 'لم يتم العثور على دولة';

  @override
  String get phoneHelper =>
      'يساعد أصدقاءك على إيجادك ويتيح لك استعادة حسابك. يبقى خاصًا.';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseGallery => 'اختيار من المعرض';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get errorPhone => 'أدخل رقم هاتف صالحًا';

  @override
  String get interestsTitle => 'ما اهتماماتك؟';

  @override
  String get interestsSubtitle =>
      'اختر بعض المواضيع ليشبهك موجزك ومقاطعك القصيرة.';

  @override
  String selectedCount(int n) {
    return 'تم اختيار $n';
  }

  @override
  String get interestsError => 'تعذّر تحميل المواضيع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get followTitle => 'تابع أشخاصًا تعرفهم';

  @override
  String get followSubtitle =>
      'ستظهر منشوراتهم ومقاطعهم القصيرة في موجزك. يمكنك التغيير في أي وقت.';

  @override
  String get tabSuggested => 'مقترحون';

  @override
  String get tabContacts => 'من جهات الاتصال';

  @override
  String get tabPopular => 'الأكثر شعبية';

  @override
  String get suggestedForYou => 'مقترحون لك';

  @override
  String get followAll => 'متابعة الكل';

  @override
  String get follow => 'متابعة';

  @override
  String get following => 'تتابعه';

  @override
  String followPerson(String name) {
    return 'تابع $name';
  }

  @override
  String unfollowPerson(String name) {
    return 'إلغاء متابعة $name';
  }

  @override
  String mutualFriends(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n صديق مشترك',
      many: '$n صديقًا مشتركًا',
      few: '$n أصدقاء مشتركين',
      two: 'صديقان مشتركان',
      one: 'صديق مشترك',
    );
    return '$_temp0';
  }

  @override
  String livesIn(String city) {
    return 'يسكن في $city';
  }

  @override
  String get followHint => 'تابع 3 أشخاص على الأقل لموجز أفضل';

  @override
  String get noSuggestions => 'لا توجد اقتراحات بعد';

  @override
  String get followError => 'تعذّر تحميل الأشخاص';

  @override
  String get leaveTitle => 'مغادرة التسجيل؟';

  @override
  String get leaveBody =>
      'تم حفظ تقدمك. يمكنك المتابعة من حيث توقفت في المرة القادمة التي تسجّل فيها الدخول.';

  @override
  String get keepGoing => 'واصل';

  @override
  String get leave => 'مغادرة';

  @override
  String get resetTitle => 'عيّن كلمة مرور جديدة';

  @override
  String resetSubtitle(String email) {
    return 'لـ $email. استخدم كلمة مرور لم تستخدمها على Pulse من قبل.';
  }

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get ruleLength => '8 أحرف على الأقل';

  @override
  String get ruleNumber => 'تحتوي على رقم';

  @override
  String get ruleCase => 'أحرف كبيرة وصغيرة';

  @override
  String get confirmLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get confirmHint => 'أعد كتابتها';

  @override
  String get logoutOthers => 'تسجيل الخروج من جميع الأجهزة الأخرى';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get errorMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get linkExpiredTitle => 'انتهت صلاحية هذا الرابط';

  @override
  String get linkExpiredBody => 'اطلب رابطًا جديدًا لإعادة تعيين كلمة مرورك.';

  @override
  String get requestNewLink => 'طلب رابط جديد';

  @override
  String get updatedTitle => 'تم تحديث كلمة المرور';

  @override
  String get updatedBodyOthers =>
      'يمكنك الآن تسجيل الدخول بكلمة مرورك الجديدة. تم تسجيل الخروج من الأجهزة الأخرى.';

  @override
  String get updatedBody => 'يمكنك الآن تسجيل الدخول بكلمة مرورك الجديدة.';

  @override
  String get close => 'إغلاق';
}
