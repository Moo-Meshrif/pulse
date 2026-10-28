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
  String get communityGuidelines => 'إرشادات المجتمع';

  @override
  String get cookiePolicy => 'سياسة ملفات تعريف الارتباط';

  @override
  String get openSourceLicenses => 'تراخيص المصدر المفتوح';

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
  String get noInternetTitle => 'لا يوجد إنترنت';

  @override
  String get noInternetBody => 'أنت متصل بشبكة لكنها لا تتصل بالإنترنت.';

  @override
  String get weakConnectionTitle => 'اتصال ضعيف';

  @override
  String get weakConnectionBody => 'اتصالك بطيء جدًا. حاول مرة أخرى بعد قليل.';

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
    return 'إذا كان هناك حساب لـ $email، فقد أرسلنا رابط إعادة التعيين. افتحه لتعيين كلمة مرور جديدة.';
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
  String get requested => 'تم الطلب';

  @override
  String cancelRequestPerson(String name) {
    return 'إلغاء طلب متابعة $name';
  }

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
  String get skipStepTitle => 'تخطي هذه الخطوة؟';

  @override
  String get skipStepBody => 'سيتم مسح ما أدخلته في هذه الخطوة ولن يتم حفظه.';

  @override
  String get keepEditing => 'متابعة التعديل';

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
  String get linkExpiredSnackBar =>
      'انتهت صلاحية هذا الرابط. اطلب رابطًا جديدًا لإعادة تعيين كلمة مرورك.';

  @override
  String get signedOutSubtitle => 'أدخل كلمة المرور للمتابعة.';

  @override
  String get signedOutTitle => 'تم تسجيل خروجك';

  @override
  String get signedOutExpiredBody =>
      'انتهت جلستك. سجّل الدخول مجددًا لتكمل من حيث توقفت.';

  @override
  String get signedOutRevokedBody =>
      'أُنهيت جلستك على جهاز آخر أو بعد تغيير كلمة المرور. سجّل الدخول مجددًا للمتابعة.';

  @override
  String get accountLabel => 'الحساب';

  @override
  String get notYou => 'لست أنت؟';

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

  @override
  String get failedPageTitle => 'حدث خطأ ما';

  @override
  String get failedPageBody =>
      'تعذّر تحميل هذه الصفحة. المشكلة ليست منك، يُرجى المحاولة مرة أخرى.';

  @override
  String get goToHome => 'الذهاب إلى الرئيسية';

  @override
  String get notFoundPageTitle => 'هذه الصفحة غير متاحة';

  @override
  String get notFoundPageBody =>
      'قد يكون الرابط معطّلاً، أو تمت إزالة المحتوى.';

  @override
  String get offlinePageTitle => 'أنت غير متصل بالإنترنت';

  @override
  String get offlinePageBody =>
      'اتصل بشبكة Wi-Fi أو بيانات الجوال. سنعيد التحميل فور عودتك.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navShorts => 'الفيديوهات القصيرة';

  @override
  String get navCreate => 'إنشاء';

  @override
  String get navChat => 'الدردشة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String navUnread(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get createTitle => 'إنشاء';

  @override
  String get createPost => 'منشور';

  @override
  String get createPostSub => 'شارك صورًا أو فيديوهات أو نصًا في خلاصتك';

  @override
  String get createShort => 'فيديو قصير';

  @override
  String get createShortSub => 'سجّل أو ارفع فيديو عموديًا حتى 60 ثانية';

  @override
  String get reportReasonSpam => 'محتوى مزعج';

  @override
  String get reportReasonNudity => 'عري أو محتوى جنسي';

  @override
  String get reportReasonHate => 'خطاب كراهية أو رموز';

  @override
  String get reportReasonBullying => 'تنمر أو مضايقة';

  @override
  String get reportReasonViolence => 'عنف أو أفعال خطيرة';

  @override
  String get reportReasonFalseInfo => 'معلومات مضللة';

  @override
  String get reportReasonOther => 'شيء آخر';

  @override
  String get reportElseTitle => 'شيء آخر';

  @override
  String get reportElseBody => 'صف المشكلة في بضع كلمات. بلاغك مجهول.';

  @override
  String get reportSend => 'إرسال البلاغ';

  @override
  String get reportSentTitle => 'شكرًا لإبلاغنا';

  @override
  String get reportDone => 'تم';

  @override
  String get storyReportTitle => 'الإبلاغ عن القصة';

  @override
  String get storyReportBody => 'لماذا تبلغ عن هذه القصة؟ بلاغك مجهول.';

  @override
  String get storyReportSent => 'سنراجع هذه القصة.';

  @override
  String get storyReportNotePlaceholder => 'أخبرنا بما يزعجك في هذه القصة…';

  @override
  String reportNoteCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get errorPermission =>
      'ليس لدى Pulse صلاحية الوصول. اسمح بها من الإعدادات ثم حاول مجددًا.';

  @override
  String get storyReplyHint => 'أرسل رسالة…';

  @override
  String get storyYourStory => 'قصتك';

  @override
  String storyViewers(int count) {
    return '$count مشاهدين';
  }

  @override
  String get storyMore => 'المزيد من الخيارات';

  @override
  String get storyLike => 'إعجاب';

  @override
  String get storyUnlike => 'إزالة الإعجاب';

  @override
  String get storySend => 'إرسال';

  @override
  String get storyReplySoon => 'الردود قريبًا.';

  @override
  String get storyAgeNow => 'الآن';

  @override
  String storyAgeMinutes(int count) {
    return '$countد';
  }

  @override
  String storyAgeHours(int count) {
    return '$countس';
  }

  @override
  String storyAgeDays(int count) {
    return '$countي';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get storyPaused => 'متوقف مؤقتًا';

  @override
  String storyMute(String username) {
    return 'كتم @$username';
  }

  @override
  String get storyMuteHint => 'إخفاء قصصه من شريط القصص';

  @override
  String storyMuted(String username) {
    return 'تم إخفاء قصص @$username';
  }

  @override
  String get storyGoToProfile => 'الذهاب إلى الملف الشخصي';

  @override
  String get storySaveToDevice => 'الحفظ على الجهاز';

  @override
  String get storySaved => 'تم الحفظ في الصور';

  @override
  String get storyWhoCanSee => 'من يمكنه المشاهدة';

  @override
  String get storyAudienceFollowers => 'المتابعون';

  @override
  String get storyViewersItem => 'المشاهدون';

  @override
  String get storyViewersEmpty => 'لم يشاهد أحد هذه القصة بعد';

  @override
  String get storyDelete => 'حذف القصة';

  @override
  String get storyDeleteTitle => 'حذف هذه القصة؟';

  @override
  String storyDeleteBody(int count) {
    return 'ستُحذف للجميع مع مشاهداتها البالغ عددها $count. لا يمكن التراجع عن ذلك.';
  }

  @override
  String get storyDeleted => 'تم حذف القصة';

  @override
  String get storyViewersLoadFailed => 'تعذّر تحميل المزيد من المشاهدين';

  @override
  String get permAllowTitle => 'اسمح بالوصول إلى الكاميرا والميكروفون';

  @override
  String get permAllowBody =>
      'لالتقاط الصور وتسجيل القصص والمقاطع القصيرة بالصوت.';

  @override
  String get permAllowAccess => 'السماح بالوصول';

  @override
  String get permNotNow => 'ليس الآن';

  @override
  String get permCamera => 'الكاميرا';

  @override
  String get permMicrophone => 'الميكروفون';

  @override
  String get permNeeded => 'مطلوب';

  @override
  String get permOff => 'متوقف';

  @override
  String get permAllowed => 'مسموح';

  @override
  String get permCameraOffTitle => 'الوصول إلى الكاميرا متوقف';

  @override
  String get permCameraOffBody =>
      'فعّل الكاميرا لتطبيق Pulse من الإعدادات لالتقاط الصور وتسجيل الفيديو.';

  @override
  String get permCameraRestrictedBody =>
      'الوصول إلى الكاميرا مقيّد على هذا الجهاز، لذلك لا يستطيع Pulse استخدامها.';

  @override
  String get permMicOffPill => 'الميكروفون متوقف · ستكون الفيديوهات بدون صوت';

  @override
  String get permFix => 'إصلاح';

  @override
  String get permUnavailableTitle => 'الكاميرا غير متاحة';

  @override
  String get permUnavailableBody =>
      'قد يستخدمها تطبيق آخر. أغلق ذلك التطبيق ثم حاول مرة أخرى.';

  @override
  String get permOpenSettings => 'فتح الإعدادات';

  @override
  String get permChooseGallery => 'اختر من المعرض';

  @override
  String get permTryAgain => 'إعادة المحاولة';

  @override
  String get storyCameraTitle => 'قصة';

  @override
  String get storyHint => 'اضغط لالتقاط صورة، واستمر للضغط لتسجيل فيديو';

  @override
  String get storyShutter => 'زر الالتقاط';

  @override
  String get storyFlash => 'الفلاش';

  @override
  String get storyFlashOn => 'الفلاش يعمل';

  @override
  String get storyFlipCamera => 'قلب الكاميرا';

  @override
  String get storyGallery => 'اختر من المعرض';

  @override
  String storyRecordingTime(String time) {
    return 'جارٍ التسجيل، $time';
  }

  @override
  String get storyTrimHint => 'اسحب لاختيار الجزء الذي تريد مشاركته';

  @override
  String get storyCaptureFailed => 'تعذّر الالتقاط. حاول مرة أخرى.';

  @override
  String get storyShare => 'مشاركة';

  @override
  String get storyYourStoryPill => 'قصتك';

  @override
  String get storyToolText => 'نص';

  @override
  String get storyToolLocation => 'الموقع';

  @override
  String get storyToolMute => 'كتم الصوت';

  @override
  String get storyToolUnmute => 'تشغيل الصوت';

  @override
  String get storyTextHint => 'اكتب شيئًا…';

  @override
  String get storyTextDone => 'تم';

  @override
  String get storyRemoveSticker => 'اسحب هنا للحذف';

  @override
  String get storyDiscardTitle => 'تجاهل هذه القصة؟';

  @override
  String get storyDiscardBody => 'لن يتم نشر صورتك أو الفيديو.';

  @override
  String get storyDiscard => 'تجاهل';

  @override
  String get storyKeepEditing => 'متابعة التعديل';

  @override
  String get storyUploadBusy =>
      'قصتك السابقة ما زالت قيد النشر. حاول بعد قليل.';

  @override
  String get storyShareFailed => 'تعذّرت مشاركة قصتك. حاول مرة أخرى.';

  @override
  String storyStickerLimit(int max) {
    return 'يمكنك إضافة $max ملصقًا كحد أقصى';
  }

  @override
  String get storyRailTitle => 'القصص';

  @override
  String get storyPosting => 'جارٍ النشر…';

  @override
  String get storyAddToStory => 'أضف إلى قصتك';

  @override
  String get storyRailFailed => 'تعذّر تحميل القصص';

  @override
  String get storyPostOffline =>
      'لا يوجد اتصال. سيتم نشر قصتك عند عودة الإنترنت.';

  @override
  String storySavingVideo(int percent) {
    return 'جارٍ حفظ الفيديو… $percent٪';
  }

  @override
  String get storyPostFailed => 'تعذّر نشر قصتك';

  @override
  String get storyAudienceBody =>
      'تُطبَّق التغييرات على هذه القصة فورًا. من شاهدها بالفعل يبقى في قائمة المشاهدين.';

  @override
  String get storyAudienceCloseFriends => 'الأصدقاء المقربون';

  @override
  String get storyAudienceHideFrom => 'إخفاء القصة عن';

  @override
  String storyAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      many: '$count شخصًا',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String get storyAudienceEdit => 'تعديل';

  @override
  String get storyAudienceDone => 'تم';

  @override
  String get storyAudienceSaveFailed => 'تعذّر الحفظ. حاول مرة أخرى.';

  @override
  String get storyCloseFriendsTitle => 'الأصدقاء المقربون';

  @override
  String get storyCloseFriendsHint =>
      'أنت فقط من يرى هذه القائمة. لا يُبلَّغ الأشخاص عند إضافتهم أو إزالتهم.';

  @override
  String get storyHiddenTitle => 'إخفاء القصة عن';

  @override
  String get storyHiddenHint =>
      'لن يرى هؤلاء أيًّا من قصصك. ولا يُبلَّغون بذلك.';

  @override
  String storyAudienceSelected(int count) {
    return '$count محدد';
  }

  @override
  String get storyAudienceSearch => 'ابحث في المتابعين';

  @override
  String get storyAudienceTabSuggested => 'مقترح';

  @override
  String storyAudienceTabSelected(int count) {
    return 'المحدد · $count';
  }

  @override
  String get storyAudienceEmpty => 'لا يوجد متابعون';

  @override
  String get storyAudienceLoadFailed => 'تعذّر تحميل متابعيك';

  @override
  String storyAudienceSelectPerson(String name) {
    return 'تحديد $name';
  }

  @override
  String storyMoveToHiddenTitle(String name) {
    return 'إخفاء قصصك عن $name؟';
  }

  @override
  String storyMoveToHiddenBody(String name) {
    return '$name ضمن أصدقائك المقربين. إخفاء قصصك عنه يزيله من تلك القائمة.';
  }

  @override
  String get storyMoveToHiddenConfirm => 'إخفاء';

  @override
  String storyMoveToCloseTitle(String name) {
    return 'إضافة $name إلى الأصدقاء المقربين؟';
  }

  @override
  String storyMoveToCloseBody(String name) {
    return '$name ضمن قائمة إخفاء القصة عنهم. إضافته إلى الأصدقاء المقربين تزيله من تلك القائمة.';
  }

  @override
  String get storyMoveToCloseConfirm => 'إضافة';

  @override
  String get postMore => 'المزيد';

  @override
  String get postLess => 'أقل';

  @override
  String get postTimeNow => 'الآن';

  @override
  String postTimeMinutes(int count) {
    return '$countد';
  }

  @override
  String postTimeHours(int count) {
    return '$countس';
  }

  @override
  String postTimeDays(int count) {
    return '$countي';
  }

  @override
  String postTimeWeeks(int count) {
    return '$countأ';
  }

  @override
  String get postLike => 'إعجاب';

  @override
  String get postUnlike => 'إلغاء الإعجاب';

  @override
  String get postComment => 'تعليق';

  @override
  String get postShare => 'مشاركة';

  @override
  String get postSave => 'حفظ';

  @override
  String get postUnsave => 'إلغاء الحفظ';

  @override
  String get postOptions => 'خيارات المنشور';

  @override
  String get postMuteVideo => 'كتم';

  @override
  String get postUnmuteVideo => 'إلغاء الكتم';

  @override
  String postMediaCounter(int number, int total) {
    return 'الصورة $number من $total';
  }

  @override
  String get postMediaRetry => 'تعذر التحميل. اضغط لإعادة المحاولة';

  @override
  String get postSaved => 'تم الحفظ';

  @override
  String get postCopyLink => 'نسخ الرابط';

  @override
  String get postNotInterested => 'غير مهتم';

  @override
  String get postNotInterestedHint => 'شاهد منشورات أقل مثل هذا';

  @override
  String postUnfollow(String username) {
    return 'إلغاء متابعة @$username';
  }

  @override
  String postMute(String username) {
    return 'كتم @$username';
  }

  @override
  String get postMuteHint => 'إخفاء منشوراته دون إلغاء المتابعة';

  @override
  String get postReportTitle => 'الإبلاغ عن المنشور';

  @override
  String get postReportBody => 'لماذا تبلغ عن هذا المنشور؟ بلاغك مجهول.';

  @override
  String get postReportSent =>
      'سنراجع هذا المنشور ولن تراه في خلاصتك بعد الآن.';

  @override
  String get postReportNotePlaceholder => 'أخبرنا بما يزعجك في هذا المنشور…';

  @override
  String get postEditPost => 'تعديل المنشور';

  @override
  String get editPostTitle => 'تعديل المنشور';

  @override
  String get editPostSave => 'حفظ';

  @override
  String get postUpdated => 'تم تحديث المنشور';

  @override
  String get editPostSaveFailed => 'تعذّر حفظ تغييراتك';

  @override
  String get editPostDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get editPostDiscardBody => 'لن يتم حفظ تغييراتك على هذا المنشور.';

  @override
  String get postChangeWhoCanSee => 'تغيير من يمكنه المشاهدة';

  @override
  String get postCommentsOff => 'إيقاف التعليقات';

  @override
  String get postCommentsOn => 'تشغيل التعليقات';

  @override
  String get postDelete => 'حذف المنشور';

  @override
  String get postDeleteTitle => 'حذف هذا المنشور؟';

  @override
  String get postDeleteBody =>
      'ستتم إزالته من ملفك الشخصي ومن خلاصة الجميع. لا يمكنك التراجع.';

  @override
  String get postHidden => 'تم إخفاء المنشور';

  @override
  String get postHiddenHint => 'سترى منشورات أقل مثل هذا.';

  @override
  String postUnfollowed(String username) {
    return 'تم إلغاء متابعة @$username';
  }

  @override
  String postMuted(String username) {
    return 'تم كتم @$username';
  }

  @override
  String get postDeleted => 'تم حذف المنشور';

  @override
  String get newPostTitle => 'منشور جديد';

  @override
  String get newPostHint => 'بماذا تفكر؟';

  @override
  String get newPostAdd => 'إضافة';

  @override
  String get newPostAddToPost => 'أضف إلى منشورك';

  @override
  String get newPostPhotoVideo => 'صورة / فيديو';

  @override
  String newPostAdded(int count) {
    return 'تمت إضافة $count';
  }

  @override
  String get newPostTag => 'وسم الأشخاص';

  @override
  String get newPostLocation => 'الموقع';

  @override
  String get newPostFeeling => 'الشعور / النشاط';

  @override
  String get newPostAllowComments => 'السماح بالتعليقات';

  @override
  String get newPostShare => 'مشاركة المنشور';

  @override
  String get newPostShared => 'تمت مشاركة المنشور';

  @override
  String get newPostDraftTitle => 'حفظ كمسودة؟';

  @override
  String get newPostDraftBody =>
      'يمكنك إكماله في المرة القادمة التي تفتح فيها منشورًا جديدًا.';

  @override
  String get newPostSaveDraft => 'حفظ المسودة';

  @override
  String get newPostDiscardPost => 'تجاهل المنشور';

  @override
  String get newPostKeepEditing => 'متابعة التعديل';

  @override
  String get newPostDiscard => 'تجاهل';

  @override
  String get newPostShareFailed => 'تعذّرت مشاركة منشورك.';

  @override
  String newPostVideoTooLong(int minutes) {
    return 'يمكن أن يصل طول الفيديو إلى $minutes دقائق.';
  }

  @override
  String newPostVideoTooBig(int megabytes) {
    return 'يمكن أن يصل حجم الفيديو إلى $megabytes ميغابايت.';
  }

  @override
  String newPostMediaLimit(int count) {
    return 'يمكنك إضافة حتى $count صور وفيديوهات.';
  }

  @override
  String get newPostUploadFailed => 'تعذّر الرفع. اضغط لإعادة المحاولة';

  @override
  String newPostRemoveMedia(int number) {
    return 'إزالة الصورة $number';
  }

  @override
  String newPostCounterAtLimit(int count, int max) {
    return '$count من $max، تم بلوغ الحد';
  }

  @override
  String get postAudiencePublic => 'عام';

  @override
  String get postAudienceFollowers => 'المتابعون';

  @override
  String get postAudienceCloseFriends => 'الأصدقاء المقربون';

  @override
  String get postAudienceOnlyMe => 'أنا فقط';

  @override
  String newPostVisibilityLabel(String choice) {
    return 'من يمكنه رؤية هذا المنشور: $choice';
  }

  @override
  String get postVisibilityTitle => 'من يمكنه رؤية هذا المنشور؟';

  @override
  String get postVisibilityChangeTitle => 'تغيير من يمكنه الرؤية';

  @override
  String postVisibilityCurrently(String choice) {
    return 'الحالي: $choice';
  }

  @override
  String get postVisibilityPublicHint => 'أي شخص داخل Pulse أو خارجه';

  @override
  String get postVisibilityPublicOff => 'غير متاح لأن حسابك خاص';

  @override
  String get postVisibilityOnlyMeHint => 'محفوظ في ملفك الشخصي ومخفي عن الجميع';

  @override
  String postVisibilityPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get postVisibilityEdit => 'تعديل';

  @override
  String get postVisibilityFuture => 'استخدام للمنشورات القادمة';

  @override
  String get postVisibilityFutureHint => 'يمكنك تغييره من الإعدادات ← الخصوصية';

  @override
  String get postVisibilityPrivateNote =>
      'حسابك خاص، لذا يرى منشوراتك متابعوك فقط.';

  @override
  String get postVisibilityPrivacySettings => 'إعدادات الخصوصية';

  @override
  String get postVisibilityKeptNote =>
      'تبقى الإعجابات والتعليقات من الأشخاص الذين فقدوا الوصول لكنها تُخفى عنهم.';

  @override
  String get postVisibilityDone => 'تم';

  @override
  String get postVisibilitySave => 'حفظ';

  @override
  String get postVisibilityUpdated => 'تم تحديث الظهور';

  @override
  String get postVisibilityNoticeCloseFriendsTitle =>
      'المشاركة مع الأصدقاء المقربين';

  @override
  String postVisibilityNoticeCloseFriendsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيرى $count شخص هذا المنشور',
      one: 'سيرى شخص واحد هذا المنشور',
    );
    return '$_temp0';
  }

  @override
  String get postVisibilityNoticeOnlyMeTitle =>
      'أنت فقط من يمكنه رؤية هذا المنشور';

  @override
  String get postVisibilityNoticeOnlyMeBody =>
      'محفوظ في ملفك الشخصي ومخفي عن الجميع';

  @override
  String get locationTitle => 'إضافة موقع';

  @override
  String get locationRemove => 'إزالة';

  @override
  String get locationSearchHint => 'ابحث عن أماكن';

  @override
  String get locationUseCurrent => 'استخدام الموقع الحالي';

  @override
  String get locationNearby => 'بالقرب منك';

  @override
  String get locationRecent => 'الأخيرة';

  @override
  String get locationResults => 'النتائج';

  @override
  String get locationNoResults => 'لم يتم العثور على أماكن';

  @override
  String get locationOffline => 'البحث يحتاج إلى اتصال';

  @override
  String get locationSearchFailed => 'تعذر البحث. حاول مرة أخرى.';

  @override
  String get locationPrimerTitle => 'السماح بالوصول إلى الموقع';

  @override
  String get locationPrimerBody =>
      'شاهد الأماكن القريبة منك عند إضافة موقع. يستخدم Pulse موقعك فقط أثناء اختيارك لمكان.';

  @override
  String get locationAllow => 'السماح بالموقع';

  @override
  String get locationNotNow => 'ليس الآن';

  @override
  String get locationOpenSettings => 'فتح الإعدادات';

  @override
  String locationDistance(String km) {
    return '$km كم';
  }

  @override
  String get locationKindCity => 'مدينة';

  @override
  String get locationKindTown => 'بلدة';

  @override
  String get locationKindNeighborhood => 'حي';

  @override
  String get locationSelected => 'محدد';

  @override
  String get locationClearSearch => 'مسح البحث';

  @override
  String get homeSearch => 'بحث';

  @override
  String get homeActivity => 'النشاط';

  @override
  String get homeEmptyTitle => 'خلاصتك هادئة';

  @override
  String get homeEmptyBody => 'تابع أشخاصًا لترى منشوراتهم هنا.';

  @override
  String get homeFindPeople => 'ابحث عن أشخاص';

  @override
  String get homeLoadMoreError => 'تعذّر تحميل المزيد · أعد المحاولة';

  @override
  String get homeCaughtUp => 'لقد اطلعت على كل شيء';

  @override
  String get homeNewPosts => 'منشورات جديدة';

  @override
  String homeNewPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور جديد',
      many: '$count منشورًا جديدًا',
      few: '$count منشورات جديدة',
      two: 'منشوران جديدان',
      one: 'منشور جديد',
    );
    return '$_temp0';
  }

  @override
  String get homeNewPostsMany => '+9 منشورات جديدة';

  @override
  String homeNewPostsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور جديد',
      many: '$count منشورًا جديدًا',
      few: '$count منشورات جديدة',
      two: 'منشورين جديدين',
      one: 'منشور جديد',
    );
    return 'عرض $_temp0 والانتقال إلى الأعلى';
  }

  @override
  String get homeBackToTop => 'العودة إلى الأعلى';

  @override
  String get postPublishing => 'جارٍ النشر…';

  @override
  String get postPublishSaving => 'جارٍ حفظ التغييرات…';

  @override
  String get postPublishFailed => 'تعذّر النشر';

  @override
  String get postPublishDiscard => 'تجاهل';

  @override
  String get postDiscardTooLate => 'تمت مشاركة منشورك بالفعل، لذا لم يُحذف.';

  @override
  String get newPostPublishBusy =>
      'لديك 3 منشورات في الانتظار. حاول بعد نشر أحدها.';

  @override
  String postPublishingMany(int count) {
    return 'نشر $count منشورات…';
  }

  @override
  String postPublishProgress(int done, int total, int percent) {
    return 'اكتمل $done من $total · $percent٪';
  }

  @override
  String postPublishDoneOf(int done, int total) {
    return 'اكتمل $done من $total';
  }

  @override
  String postPublishRowTitle(int n) {
    return 'المنشور $n';
  }

  @override
  String get postPublishRowPosted => 'تم النشر';

  @override
  String get postPublishRowWaiting => 'في الانتظار';

  @override
  String get postPublishAllPosted => 'تم نشر الكل';

  @override
  String get postPublishOffline => 'بانتظار الاتصال';

  @override
  String postPublishOfflineSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشورات متوقفة',
      one: 'منشور واحد متوقف',
    );
    return '$_temp0 · يستأنف تلقائيًا';
  }

  @override
  String postPublishSomePosted(int done, int total) {
    return 'تم نشر $done من $total';
  }

  @override
  String postPublishSomeFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تعذر رفع $count منشورات',
      one: 'تعذر رفع منشور واحد',
    );
    return '$_temp0';
  }

  @override
  String get postPublishShowAll => 'عرض كل المنشورات';

  @override
  String get postPublishHideAll => 'إخفاء القائمة';

  @override
  String get postHeadlineYou => 'أنت';

  @override
  String postHeadlineFeeling(String emoji, String word) {
    return '$emoji $word';
  }

  @override
  String get postHeadlineWith => 'مع ';

  @override
  String get postHeadlineAnd => ' و';

  @override
  String postHeadlineOthers(int count) {
    return '$count آخرين';
  }

  @override
  String postSharedSemantics(String name) {
    return 'منشور مشارك من $name';
  }

  @override
  String get postUnavailableTitle => 'هذا المنشور غير متاح';

  @override
  String get postUnavailableBody => 'تم حذفه، أو تغيّر جمهوره ولا يمكنك رؤيته.';

  @override
  String get postUnavailableSemantics => 'المنشور غير متاح';

  @override
  String get shareTitle => 'مشاركة';

  @override
  String get shareAudienceLocked =>
      'هذا المنشور للمتابعين فقط، لذا تبقى مشاركته للمتابعين. لتغيير ذلك، غيّر جمهور المنشور الأصلي.';

  @override
  String get shareFieldHint => 'قل شيئًا عن هذا...';

  @override
  String get shareTagPeople => 'وسم الأشخاص';

  @override
  String get shareFeeling => 'المشاعر';

  @override
  String get shareLocation => 'الموقع';

  @override
  String get shareNow => 'شارك الآن';

  @override
  String shareCounter(int count) {
    return '$count / 2000';
  }

  @override
  String get shareAddToStory => 'أضف إلى القصة';

  @override
  String get shareCopyLink => 'نسخ الرابط';

  @override
  String get shareWhatsApp => 'واتساب';

  @override
  String get shareMore => 'المزيد...';

  @override
  String get sharedToFeedTitle => 'تمت المشاركة في صفحتك';

  @override
  String get sharedToFeedPublic => 'يمكن للجميع رؤيتها الآن.';

  @override
  String get sharedToFeedFollowers => 'يمكن لمتابعيك رؤيتها الآن.';

  @override
  String get sharedToFeedCloseFriends => 'يمكن لأصدقائك المقربين رؤيتها الآن.';

  @override
  String get sharedToFeedOnlyMe => 'أنت فقط من يمكنه رؤيتها.';

  @override
  String get sharedToFeedView => 'عرض';

  @override
  String get shareFailed => 'تعذّرت المشاركة. حاول مرة أخرى.';

  @override
  String get postCommentsOffTitle => 'التعليقات متوقفة';

  @override
  String postCommentsOffNotice(String name) {
    return 'أوقف $name التعليقات على هذا المنشور.';
  }

  @override
  String get postCommentsOffLine => 'التعليقات متوقفة';

  @override
  String get postCommentsOffHint => 'التعليقات متوقفة على هذا المنشور';

  @override
  String get postEditHint => 'التعليق، الشعور، الموقع، الوسوم';

  @override
  String get postFeelingHappy => 'سعادة';

  @override
  String get postFeelingExcited => 'حماس';

  @override
  String get postFeelingLoved => 'حب';

  @override
  String get postFeelingRelaxed => 'راحة';

  @override
  String get postFeelingGrateful => 'امتنان';

  @override
  String get postFeelingMotivated => 'تحفّز';

  @override
  String get postFeelingCool => 'روعة';

  @override
  String get postFeelingAmazed => 'دهشة';

  @override
  String get postFeelingTired => 'تعب';

  @override
  String get postFeelingSad => 'حزن';

  @override
  String get postFeelingDetermined => 'عزيمة';

  @override
  String get postFeelingSick => 'مرض';

  @override
  String get postFeelingFunny => 'مرح';

  @override
  String get postFeelingBlessed => 'بركة';

  @override
  String get postTagYoureTagged => 'تم وسمك في هذا المنشور';

  @override
  String get postTagRemoveMe => 'أزلني من هذا المنشور';

  @override
  String get postTagRemoveMeHint => 'لن يتم وسمك بعد الآن';

  @override
  String get postTagRemoveLabel => 'إزالة الوسم';

  @override
  String get postTagRemoveTitle => 'إزالة وسمك؟';

  @override
  String postTagRemoveBody(String name) {
    return 'لن يتم وسمك بعد الآن في منشور $name أو صوره. يبقى المنشور كما هو.';
  }

  @override
  String get postTagRemoveConfirm => 'إزالة';

  @override
  String get postTagRemoved => 'تمت إزالة الوسم';

  @override
  String get postTagRemovedBody => 'لم يعد وسمك في هذا المنشور.';

  @override
  String get postTagRemoveError => 'تعذّرت إزالة وسمك';

  @override
  String get postTaggedPeopleTitle => 'الأشخاص الموسومون';

  @override
  String get postTaggedFollow => 'متابعة';

  @override
  String get postTaggedFollowing => 'تتم متابعته';

  @override
  String get postTaggedRequested => 'تم الطلب';

  @override
  String get postTaggedLoadError => 'تعذّر تحميل الأشخاص';

  @override
  String get postTagBadge => 'الأشخاص الموسومون في هذه الصورة';

  @override
  String postTaggedPerson(String name, String state) {
    return '$name، $state';
  }

  @override
  String get postTagPeopleTitle => 'وسم الأشخاص';

  @override
  String get postTagPeopleSearch => 'ابحث عن أشخاص';

  @override
  String get postTagPeopleClear => 'مسح البحث';

  @override
  String get postTagPeopleSuggested => 'مقترحون';

  @override
  String get postTagPeopleDone => 'تم';

  @override
  String get postTagPeopleNoTags => 'لا يسمح بالوسم';

  @override
  String postTagPeopleMax(int max) {
    return 'يمكنك وسم $max شخصًا كحد أقصى';
  }

  @override
  String get postTagPeopleEmpty => 'لا يوجد أشخاص';

  @override
  String get postTagPeopleInPhoto => 'الوسم في الصورة';

  @override
  String get postTagPeopleError => 'تعذّر تحميل الأشخاص. أعد المحاولة';

  @override
  String postTagPeopleCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String postTagPeopleRemoveChip(String name) {
    return 'إزالة $name';
  }

  @override
  String postTagPersonTagged(String name) {
    return '$name، موسوم';
  }

  @override
  String postTagPersonNotTagged(String name) {
    return '$name، غير موسوم';
  }

  @override
  String get postTagInPhotoTitle => 'الوسم في الصورة';

  @override
  String get postTagInPhotoHint =>
      'اضغط على مكان الشخص ثم اخترْه. اسحب الوسم لتحريكه.';

  @override
  String postTagInPhotoNoSpot(String name) {
    return 'تم وسم $name في المنشور وليس في صورة';
  }

  @override
  String postTagInPhotoNoSpotMany(int count) {
    return 'تم وسم $count أشخاص في المنشور وليس في صورة';
  }

  @override
  String get postTagInPhotoAllPlaced => 'تم وضع الجميع';

  @override
  String postTagInPhotoLabel(String name) {
    return 'وسم $name، اسحب لتحريكه';
  }

  @override
  String postTagInPhotoRemoveSpot(String name) {
    return 'إزالة موضع $name';
  }

  @override
  String postTagInPhotoThumb(int number, int count) {
    return 'الصورة $number، $count موسوم';
  }

  @override
  String postTagValueTwo(String a, String b) {
    return '$a، $b';
  }

  @override
  String postTagValueMore(String a, String b, int count) {
    return '$a، $b و$count آخرين';
  }

  @override
  String get postFeelingTitle => 'كيف تشعر؟';

  @override
  String get postFeelingRemove => 'إزالة';

  @override
  String get postFeelingTabFeelings => 'المشاعر';

  @override
  String get postFeelingTabActivities => 'الأنشطة';

  @override
  String get postFeelingSearch => 'ابحث عن المشاعر';

  @override
  String get postFeelingClear => 'مسح البحث';

  @override
  String get postFeelingNoMatches => 'لا نتائج';

  @override
  String postFeelingSelected(String word) {
    return '$word، محدد';
  }

  @override
  String postFeelingValue(String emoji, String word) {
    return '$emoji $word';
  }

  @override
  String get storyToolBackground => 'الخلفية';

  @override
  String get storyPostStickerHint =>
      'اضغط على المنشور لتغيير شكله · اسحب بإصبعين لتغيير الحجم';

  @override
  String storyBackgroundOption(int number) {
    return 'الخلفية $number';
  }

  @override
  String storyPostSemantics(String username, String caption) {
    return 'منشور من $username: $caption';
  }

  @override
  String storyPostSemanticsNoCaption(String username) {
    return 'منشور من $username';
  }

  @override
  String get storyViewPost => 'عرض المنشور';

  @override
  String get storyPostUnavailableTitle => 'المنشور غير متاح';

  @override
  String get storyPostUnavailableBody => 'تم حذفه، أو لا يمكنك رؤيته.';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get commentsSortRelevant => 'الأكثر صلة';

  @override
  String get commentsSortNewest => 'الأحدث';

  @override
  String get commentsSortLabel => 'ترتيب التعليقات';

  @override
  String get commentsAuthorBadge => 'الكاتب';

  @override
  String get commentReply => 'رد';

  @override
  String commentLikes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعجابات',
      one: 'إعجاب',
    );
    return '$_temp0';
  }

  @override
  String commentsViewMoreReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count ردود أخرى',
      one: 'عرض رد آخر',
    );
    return '$_temp0';
  }

  @override
  String get commentsEdited => 'تم التعديل';

  @override
  String commentBy(String name) {
    return 'تعليق من $name';
  }

  @override
  String get commentsEmptyTitle => 'لا توجد تعليقات بعد';

  @override
  String get commentsEmptyBody => 'ابدأ المحادثة.';

  @override
  String get commentsLoadMoreFailed => 'تعذّر تحميل المزيد · إعادة المحاولة';

  @override
  String get commentsAddHint => 'أضف تعليقًا…';

  @override
  String commentsReplyingTo(String name) {
    return 'الرد على $name';
  }

  @override
  String get commentsReplyCancel => 'إلغاء الرد';

  @override
  String get commentsMentionSuggestions => 'أشخاص للإشارة إليهم';

  @override
  String get commentsSend => 'إرسال التعليق';

  @override
  String get commentsPosting => 'جارٍ النشر…';

  @override
  String get commentsCouldntPost => 'تعذّر النشر';

  @override
  String get commentsRetry => 'إعادة المحاولة';

  @override
  String get commentsDelete => 'حذف';

  @override
  String commentsCounter(int count) {
    return '$count / 1000';
  }

  @override
  String get commentsOff => 'التعليقات متوقفة لهذا المنشور';

  @override
  String get commentsEditing => 'تعديل التعليق';

  @override
  String get commentsEditCancel => 'إلغاء التعديل';

  @override
  String get commentsCopyText => 'نسخ النص';

  @override
  String get commentsEdit => 'تعديل';

  @override
  String get commentsHide => 'إخفاء التعليق';

  @override
  String get commentsReport => 'الإبلاغ عن التعليق';

  @override
  String get commentsDeleteTitle => 'حذف التعليق؟';

  @override
  String get commentsDeleteBody => 'سيتم حذف الردود أيضًا.';

  @override
  String get commentsHidden => 'تم إخفاء التعليق';

  @override
  String get commentsCopied => 'تم النسخ';

  @override
  String get commentsReportBody => 'لماذا تبلغ عن هذا التعليق؟ بلاغك مجهول.';

  @override
  String get commentsReportSent => 'سنراجع هذا التعليق.';

  @override
  String get commentsReportNotePlaceholder =>
      'أخبرنا بما يزعجك في هذا التعليق…';

  @override
  String get postPageTitle => 'المنشور';

  @override
  String get postFollow => 'متابعة';

  @override
  String get postFollowing => 'تتابعه';

  @override
  String get postFromNotification => 'من إشعارك';

  @override
  String get postPageUnavailableBody =>
      'ربما تم حذفه، أو قيّد صاحبه من يمكنه رؤيته.';

  @override
  String get postBackToHome => 'العودة إلى الرئيسية';

  @override
  String postDateLine(String date, String time) {
    return '$date · $time';
  }

  @override
  String postLikedBy(String name, String others) {
    return 'أعجب $name و$others';
  }

  @override
  String postLikedByOne(String name) {
    return 'أعجب $name';
  }

  @override
  String postLikedByOthers(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString شخص آخر',
      many: '$countString شخصًا آخر',
      few: '$countString أشخاص آخرين',
      two: 'شخصان آخران',
      one: 'شخص آخر',
    );
    return '$_temp0';
  }

  @override
  String get postLikesOpen => 'عرض كل من أعجبهم هذا المنشور';

  @override
  String postLikesTitle(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'الإعجابات · $countString';
  }

  @override
  String get postLikesTitleBare => 'الإعجابات';

  @override
  String get postLikesSearchHint => 'بحث';

  @override
  String get postLikesSearchClear => 'مسح البحث';

  @override
  String get postLikesEmpty => 'لم يتم العثور على أحد';

  @override
  String get postLikesFollowBack => 'رد المتابعة';

  @override
  String get postLikesLoadMoreError => 'تعذّر تحميل المزيد · أعد المحاولة';

  @override
  String get postLikesCaughtUp => 'هذا كل الأشخاص';

  @override
  String get postLikedByYou => 'أعجبك هذا المنشور';

  @override
  String get postLikedByYouName => 'أعجبك';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String get settingsPersonalInfo => 'المعلومات الشخصية';

  @override
  String get settingsPasswordSecurity => 'كلمة المرور والأمان';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get settingsBlocked => 'الحسابات المحظورة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsAutoplay => 'تشغيل الشورتس تلقائيًا';

  @override
  String get settingsAutoplaySub => 'شغّل الفيديوهات تلقائيًا عبر الواي فاي';

  @override
  String get settingsDataSaver => 'توفير البيانات';

  @override
  String get settingsDataSaverSub =>
      'حمّل وسائط بجودة أقل عند استخدام بيانات الجوال';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsDarkModeSub => 'أريح للعين ليلًا';

  @override
  String get settingsHelp => 'مركز المساعدة';

  @override
  String get settingsReport => 'الإبلاغ عن مشكلة';

  @override
  String get settingsTerms => 'الشروط والسياسات';

  @override
  String get settingsLogOut => 'تسجيل الخروج';

  @override
  String get settingsDelete => 'حذف الحساب';

  @override
  String settingsVersion(String version) {
    return 'بولس · الإصدار $version';
  }

  @override
  String get valuePublic => 'عام';

  @override
  String get valuePrivate => 'خاص';

  @override
  String get valueOn => 'مفعّل';

  @override
  String get valueOff => 'متوقف';

  @override
  String get profileTabPosts => 'المنشورات';

  @override
  String get profileTabShorts => 'الشورتس';

  @override
  String get profileTabSaved => 'المحفوظات';

  @override
  String get profilePosts => 'المنشورات';

  @override
  String get profileFollowers => 'المتابعون';

  @override
  String get profileFollowing => 'يتابع';

  @override
  String get profileNoPosts => 'لا توجد منشورات بعد';

  @override
  String get profileNoPostsBody => 'المنشورات التي تشاركها ستظهر هنا.';

  @override
  String get profileSharePost => 'شارك أول منشور لك';

  @override
  String get profileNoSaved => 'لا يوجد شيء محفوظ بعد';

  @override
  String get profileNoSavedBody =>
      'اضغط على علامة الحفظ في أي منشور ليظهر هنا. أنت وحدك من يراه.';

  @override
  String get profileShortsSoon => 'الشورتس قادمة قريبًا';

  @override
  String get profileShortsSoonBody => 'ستظهر مقاطع الفيديو القصيرة هنا.';

  @override
  String get profileShareA11y => 'مشاركة الملف الشخصي';

  @override
  String get profileSettingsA11y => 'الإعدادات';

  @override
  String get profileViewPhotoA11y => 'عرض صورة الملف الشخصي';

  @override
  String get profilePostA11y => 'فتح المنشور';

  @override
  String get profileLoadMoreError => 'تعذّر تحميل المزيد · أعد المحاولة';

  @override
  String get profileCaughtUp => 'هذا كل شيء';

  @override
  String get profileOfflineNumbers => 'اتصل بالإنترنت لعرض الأرقام.';

  @override
  String get peopleFollowersTitle => 'المتابعون';

  @override
  String get peopleFollowingTitle => 'يتابع';

  @override
  String get peopleMutualTitle => 'يتابعه';

  @override
  String get peopleSearchHint => 'بحث';

  @override
  String get peopleSearchClear => 'مسح البحث';

  @override
  String get peopleNoFollowers => 'لا يوجد متابعون بعد';

  @override
  String get peopleNoFollowersBody =>
      'عندما يتابع الناس هذا الحساب سيظهرون هنا.';

  @override
  String get peopleNoFollowing => 'لا يتابع أحدًا بعد';

  @override
  String get peopleNoFollowingBody =>
      'الحسابات التي يتابعها هذا الشخص ستظهر هنا.';

  @override
  String get peopleNoMutual => 'لا يوجد متابعون مشتركون';

  @override
  String get peopleNoMutualBody => 'لا تتابع أحدًا يتابع هذا الحساب.';

  @override
  String get peopleNoMatches => 'لم يتم العثور على أحد';

  @override
  String get peopleNoMatchesBody => 'جرّب اسمًا أو @اسم مستخدم آخر.';

  @override
  String get peoplePrivateTitle => 'هذا الحساب خاص';

  @override
  String get peoplePrivateBody => 'تابع هذا الحساب لترى من يتابعه ومن يتابع.';

  @override
  String get peopleLoadMoreError => 'تعذّر تحميل المزيد · أعد المحاولة';

  @override
  String get peopleCaughtUp => 'هذا كل الأشخاص';

  @override
  String get settingsLogOutTitle => 'تسجيل الخروج؟';

  @override
  String get settingsLogOutBody => 'ستحتاج إلى تسجيل الدخول مرة أخرى.';

  @override
  String get settingsDeleteTitle => 'حذف حسابك؟';

  @override
  String get settingsDeleteBody =>
      'سيؤدي هذا إلى حذف ملفك ومنشوراتك وقصصك نهائيًا ولا يمكن التراجع.';

  @override
  String get settingsDeletePasswordLabel => 'كلمة المرور';

  @override
  String get settingsDeletePasswordHint => 'أدخل كلمة المرور';

  @override
  String get settingsDeleteWrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get settingsDarkModeSoon => 'الوضع الداكن قادم قريبًا';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';
}
