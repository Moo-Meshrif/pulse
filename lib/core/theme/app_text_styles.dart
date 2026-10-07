import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Text styles from docs/specs/_theme/typography.md. They are `inherit: false`, so the
/// ambient Material text theme (which adds its own letter spacing and line height) never
/// changes their exact values. They carry no color: widgets
/// add it from `AppColors` (`style.copyWith(color: context.appColors.textPrimary)`).
///
/// Read them with `context.text.<style>`: Arabic locales get the Arabic set
/// (docs/specs/_theme/rtl.md): Noto Sans Arabic, same size and weight,
/// letterSpacing 0 (negative tracking breaks the letter joins) and line height +0.1.
/// The UPPERCASE `section` style is uppercased by the widget in Latin only; Arabic has no letter case.
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
    required this.button,
    required this.body,
    required this.subtitle,
    required this.bodySm,
    required this.name,
    required this.label,
    required this.section,
    required this.meta,
    required this.caption,
    required this.badge,
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
  final TextStyle button;
  final TextStyle body;
  final TextStyle subtitle;
  final TextStyle bodySm;
  final TextStyle name;
  final TextStyle label;
  final TextStyle section;
  final TextStyle meta;
  final TextStyle caption;
  final TextStyle badge;

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
      button: f(button),
      body: f(body),
      subtitle: f(subtitle),
      bodySm: f(bodySm),
      name: f(name),
      label: f(label),
      section: f(section),
      meta: f(meta),
      caption: f(caption),
      badge: f(badge),
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
