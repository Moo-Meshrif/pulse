import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Text styles from docs/specs/_theme/typography.md. `inherit: false`, so the Material text theme never
/// alters them; no color, add it from `AppColors`.
///
/// Arabic locales get their own set (docs/specs/_theme/rtl.md): letterSpacing 0, because negative tracking
/// breaks letter joins.
@immutable
class AppTextStyles {
  const AppTextStyles._({
    required this.logo,
    required this.display,
    required this.onboardingTitle,
    required this.title,
    required this.titleSm,
    required this.messagesTitle,
    required this.stat,
    required this.otpDigit,
    required this.button,
    required this.body,
    required this.subtitle,
    required this.bodySm,
    required this.bodyXs,
    required this.name,
    required this.label,
    required this.section,
    required this.meta,
    required this.caption,
    required this.badge,
    required this.action,
    required this.overlayLabel,
    required this.overlayPercent,
    required this.overlayText,
    required this.cameraTitle,
    required this.stickerLabel,
    required this.chipLabel,
    required this.countLabel,
    required this.input,
    required this.chip,
    required this.moreLink,
    required this.optionTitle,
    required this.sheetTitle,
  });

  static const _sora = 'Sora';
  static const _noto = 'NotoSans';
  static const _arabic = 'NotoSansArabic';

  final TextStyle logo;
  final TextStyle display;
  final TextStyle onboardingTitle;
  final TextStyle title;
  final TextStyle titleSm;
  final TextStyle messagesTitle;
  final TextStyle stat;

  /// Verification-code digit (auth S4): Sora 24/700.
  final TextStyle otpDigit;
  final TextStyle button;
  final TextStyle body;
  final TextStyle subtitle;
  final TextStyle bodySm;

  /// 13/400: row subtitles under a title (the Create sheet options).
  final TextStyle bodyXs;
  final TextStyle name;
  final TextStyle label;
  final TextStyle section;
  final TextStyle meta;
  final TextStyle caption;
  final TextStyle badge;

  /// 14/700: compact actions (Follow, Follow all).
  final TextStyle action;

  /// 17/600: the message under the loading overlay's line ("Saving...").
  final TextStyle overlayLabel;

  /// 13/600 with tabular figures: the progress percentage, so its digits do not jitter.
  final TextStyle overlayPercent;

  /// Story text sticker and overlay (30/700, shadow from `AppShadows.textOverlay`).
  final TextStyle overlayText;

  /// Camera top bar title.
  final TextStyle cameraTitle;

  /// Location sticker text, UPPERCASE (800 is not bundled: renders as 700).
  final TextStyle stickerLabel;

  /// Paused chip.
  final TextStyle chipLabel;

  /// Viewer count chip, "Off" label.
  final TextStyle countLabel;

  /// Post composer input and placeholder: 17/400.
  final TextStyle input;

  /// Post chips: visibility chip, duration chip: 12/600.
  final TextStyle chip;

  /// The caption's "more" / "less": 14/600.
  final TextStyle moreLink;

  /// Option row title (New post options card): 16/500.
  final TextStyle optionTitle;

  /// Visibility picker sheet title: Sora 18/700.
  final TextStyle sheetTitle;

  static const latin = AppTextStyles._(
    logo: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    display: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.2,
    ),
    onboardingTitle: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.2,
    ),
    title: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    titleSm: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    messagesTitle: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    stat: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    otpDigit: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    button: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    body: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    subtitle: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodySm: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    bodyXs: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
    name: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    label: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    section: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
    meta: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    caption: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    badge: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
    action: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    overlayLabel: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    overlayPercent: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    overlayText: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.2,
    ),
    cameraTitle: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    stickerLabel: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
    chipLabel: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    countLabel: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    input: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    chip: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    moreLink: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    optionTitle: TextStyle(
      inherit: false,
      fontFamily: _noto,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    sheetTitle: TextStyle(
      inherit: false,
      fontFamily: _sora,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
  );

  static const arabic = AppTextStyles._(
    logo: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    display: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
    ),
    onboardingTitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
    ),
    title: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    titleSm: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    messagesTitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    stat: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    otpDigit: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    button: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    body: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.6,
    ),
    subtitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.65,
    ),
    bodySm: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.55,
    ),
    bodyXs: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    name: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    label: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    section: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    meta: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    caption: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    badge: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    action: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    overlayLabel: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    overlayPercent: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    overlayText: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.3,
    ),
    cameraTitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    stickerLabel: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
    chipLabel: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    countLabel: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    input: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    chip: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    moreLink: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    optionTitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    ),
    sheetTitle: TextStyle(
      inherit: false,
      fontFamily: _arabic,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
  );

  /// Every style with its size multiplied by [factor] (the responsive scale; see [AppScale]).
  AppTextStyles scaled(double factor) {
    TextStyle f(TextStyle t) => t.copyWith(fontSize: t.fontSize! * factor);
    return AppTextStyles._(
      logo: f(logo),
      display: f(display),
      onboardingTitle: f(onboardingTitle),
      title: f(title),
      titleSm: f(titleSm),
      messagesTitle: f(messagesTitle),
      stat: f(stat),
      otpDigit: f(otpDigit),
      button: f(button),
      body: f(body),
      subtitle: f(subtitle),
      bodySm: f(bodySm),
      bodyXs: f(bodyXs),
      name: f(name),
      label: f(label),
      section: f(section),
      meta: f(meta),
      caption: f(caption),
      badge: f(badge),
      action: f(action),
      overlayLabel: f(overlayLabel),
      overlayPercent: f(overlayPercent),
      overlayText: f(overlayText),
      cameraTitle: f(cameraTitle),
      stickerLabel: f(stickerLabel),
      chipLabel: f(chipLabel),
      countLabel: f(countLabel),
      input: f(input),
      chip: f(chip),
      moreLink: f(moreLink),
      optionTitle: f(optionTitle),
      sheetTitle: f(sheetTitle),
    );
  }

  static AppTextStyles forLocale(Locale locale) =>
      locale.languageCode == 'ar' ? arabic : latin;
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get text {
    // Reading the size subscribes to window changes, so text rescales on resize and rotation.
    MediaQuery.sizeOf(this);
    return AppTextStyles.forLocale(Localizations.localeOf(this))
        .scaled(AppScale.factor);
  }
}
