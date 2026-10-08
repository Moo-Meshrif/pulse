import 'dart:ui';

/// Asset paths in one place: widgets never write `'assets/…'` strings.
abstract final class AppAssets {
  static const _icons = 'assets/icons';

  static const arrowBack = '$_icons/ic_arrow_back.svg';
  static const arrowForward = '$_icons/ic_arrow_forward.svg';
  static const bell = '$_icons/ic_bell.svg';
  static const block = '$_icons/ic_block.svg';
  static const bookmark = '$_icons/ic_bookmark.svg';
  static const cloudAlert = '$_icons/ic_cloud_alert.svg';
  static const camera = '$_icons/ic_camera.svg';
  static const chat = '$_icons/ic_chat.svg';
  static const chatFilled = '$_icons/ic_chat_filled.svg';
  static const check = '$_icons/ic_check.svg';
  static const chevronDown = '$_icons/ic_chevron_down.svg';
  static const chevronRight = '$_icons/ic_chevron_right.svg';
  static const close = '$_icons/ic_close.svg';
  static const comment = '$_icons/ic_comment.svg';
  static const document = '$_icons/ic_document.svg';
  static const edit = '$_icons/ic_edit.svg';
  static const eye = '$_icons/ic_eye.svg';
  static const eyeOff = '$_icons/ic_eye_off.svg';
  static const flag = '$_icons/ic_flag.svg';
  static const globe = '$_icons/ic_globe.svg';
  static const heart = '$_icons/ic_heart.svg';
  static const heartFilled = '$_icons/ic_heart_filled.svg';
  static const help = '$_icons/ic_help.svg';
  static const home = '$_icons/ic_home.svg';
  static const homeFilled = '$_icons/ic_home_filled.svg';
  static const image = '$_icons/ic_image.svg';
  static const laptop = '$_icons/ic_laptop.svg';
  static const location = '$_icons/ic_location.svg';
  static const key = '$_icons/ic_key.svg';
  static const lock = '$_icons/ic_lock.svg';
  static const logout = '$_icons/ic_logout.svg';
  static const mail = '$_icons/ic_mail.svg';
  static const moreHorizontal = '$_icons/ic_more_horizontal.svg';
  static const music = '$_icons/ic_music.svg';
  static const phone = '$_icons/ic_phone.svg';
  static const play = '$_icons/ic_play.svg';
  static const plus = '$_icons/ic_plus.svg';
  static const profile = '$_icons/ic_profile.svg';
  static const profileFilled = '$_icons/ic_profile_filled.svg';
  static const search = '$_icons/ic_search.svg';
  static const settings = '$_icons/ic_settings.svg';
  static const share = '$_icons/ic_share.svg';
  static const shorts = '$_icons/ic_shorts.svg';
  static const shortsFilled = '$_icons/ic_shorts_filled.svg';
  static const smile = '$_icons/ic_smile.svg';
  static const tagPerson = '$_icons/ic_tag_person.svg';
  static const trash = '$_icons/ic_trash.svg';
  static const upload = '$_icons/ic_upload.svg';
  static const verified = '$_icons/ic_verified.svg';
  static const videoCamera = '$_icons/ic_video_camera.svg';
  static const wifiOff = '$_icons/ic_wifi_off.svg';
  static const warning = '$_icons/ic_warning.svg';
  static const volume = '$_icons/ic_volume.svg';
  static const logo = '$_icons/logo.svg';

  // Onboarding illustrations: PNGs with the text baked in, one set per language.
  // Placeholder file names; the user will edit them (docs/specs/onboarding/assets.md).
  static const _onboarding = 'assets/images/onboarding';

  static String _onboardingImage(int page, Locale locale) =>
      '$_onboarding/${locale.languageCode == 'ar' ? 'ar' : 'en'}/onboarding_$page.png';

  static String onboarding1(Locale locale) => _onboardingImage(1, locale);
  static String onboarding2(Locale locale) => _onboardingImage(2, locale);
  static String onboarding3(Locale locale) => _onboardingImage(3, locale);
}
