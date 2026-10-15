import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Text styles from docs/specs/_theme/typography.md. `inherit: false`, so the Material text theme never
/// alters them; no color, add it from `AppColors`.
///
/// Each style is defined once in [_build]; the Latin and Arabic sets are derived from that one line.
/// Arabic locales (docs/specs/_theme/rtl.md) use Noto Sans Arabic with letterSpacing 0, because negative
/// tracking breaks letter joins.
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
    required this.noticeTitle,
    required this.noticeAction,
    required this.headline,
    required this.headlineName,
    required this.tileLabel,
    required this.emojiTile,
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

  /// Verification-code digit (auth S4).
  final TextStyle otpDigit;
  final TextStyle button;
  final TextStyle body;
  final TextStyle subtitle;
  final TextStyle bodySm;

  /// Row subtitles under a title (the Create sheet options).
  final TextStyle bodyXs;
  final TextStyle name;
  final TextStyle label;
  final TextStyle section;
  final TextStyle meta;
  final TextStyle caption;
  final TextStyle badge;

  /// Compact actions (Follow, Follow all).
  final TextStyle action;

  /// The message under the loading overlay's line ("Saving...").
  final TextStyle overlayLabel;

  /// Progress percentage; tabular figures so the digits do not jitter.
  final TextStyle overlayPercent;

  /// Story text sticker and overlay (shadow from `AppShadows.textOverlay`).
  final TextStyle overlayText;

  /// Camera top bar title.
  final TextStyle cameraTitle;

  /// Location sticker text, UPPERCASE (800 is not bundled: renders as 700).
  final TextStyle stickerLabel;

  /// Paused chip.
  final TextStyle chipLabel;

  /// Viewer count chip, "Off" label.
  final TextStyle countLabel;

  /// Post composer input and placeholder.
  final TextStyle input;

  /// Post chips: visibility chip, duration chip.
  final TextStyle chip;

  /// The caption's "more" / "less".
  final TextStyle moreLink;

  /// Option row title (New post options card).
  final TextStyle optionTitle;

  /// Visibility picker sheet title.
  final TextStyle sheetTitle;

  /// Notice card title (14/600) and its action pill (13/700).
  final TextStyle noticeTitle;
  final TextStyle noticeAction;

  /// Post card headline (14, line 1.35): connector words 400, names 700.
  final TextStyle headline;
  final TextStyle headlineName;

  /// A feeling tile's word (15/600) and its emoji (22).
  final TextStyle tileLabel;
  final TextStyle emojiTile;

  static final latin = _build(arabic: false);
  static final arabic = _build(arabic: true);

  static AppTextStyles _build({required bool arabic}) {
    // [spacing] and [height] are the Latin values; Arabic always has letterSpacing 0 and takes [arHeight].
    TextStyle s(
      double size,
      FontWeight weight, {
      bool sora = false,
      double? spacing,
      double? height,
      double? arHeight,
      List<FontFeature>? features,
    }) => TextStyle(
      inherit: false,
      fontFamily: arabic ? _arabic : (sora ? _sora : _noto),
      fontSize: size,
      fontWeight: weight,
      letterSpacing: arabic ? 0 : spacing,
      height: arabic ? arHeight : height,
      fontFeatures: features,
    );

    return AppTextStyles._(
      logo: s(24, FontWeight.w700, sora: true, spacing: -0.5),
      display: s(
        30,
        FontWeight.w700,
        sora: true,
        spacing: -0.6,
        height: 1.2,
        arHeight: 1.3,
      ),
      onboardingTitle: s(
        28,
        FontWeight.w700,
        sora: true,
        spacing: -0.6,
        height: 1.2,
        arHeight: 1.3,
      ),
      title: s(22, FontWeight.w700, sora: true, spacing: -0.4),
      titleSm: s(20, FontWeight.w700, sora: true, spacing: -0.3),
      messagesTitle: s(26, FontWeight.w700, sora: true, spacing: -0.5),
      stat: s(18, FontWeight.w700, sora: true),
      otpDigit: s(24, FontWeight.w700, sora: true),
      button: s(16, FontWeight.w700),
      body: s(15, FontWeight.w500, height: 1.5, arHeight: 1.6),
      subtitle: s(15, FontWeight.w400, height: 1.55, arHeight: 1.65),
      bodySm: s(14, FontWeight.w400, height: 1.45, arHeight: 1.55),
      bodyXs: s(13, FontWeight.w400),
      name: s(15, FontWeight.w700),
      label: s(13, FontWeight.w600),
      section: s(13, FontWeight.w700, spacing: 0.4),
      meta: s(13, FontWeight.w600),
      caption: s(12, FontWeight.w400),
      badge: s(11, FontWeight.w700),
      action: s(14, FontWeight.w700, spacing: 0),
      overlayLabel: s(17, FontWeight.w600, sora: true, spacing: -0.2),
      overlayPercent: s(
        13,
        FontWeight.w600,
        features: [FontFeature.tabularFigures()],
      ),
      overlayText: s(
        30,
        FontWeight.w700,
        sora: true,
        spacing: 0,
        height: 1.2,
        arHeight: 1.3,
      ),
      cameraTitle: s(17, FontWeight.w700, sora: true, spacing: 0),
      stickerLabel: s(15, FontWeight.w800, spacing: 0),
      chipLabel: s(12, FontWeight.w700, spacing: 0),
      countLabel: s(13, FontWeight.w700, spacing: 0),
      input: s(17, FontWeight.w400, spacing: 0),
      chip: s(12, FontWeight.w600, spacing: 0),
      moreLink: s(14, FontWeight.w600, spacing: 0),
      optionTitle: s(16, FontWeight.w500, spacing: 0),
      sheetTitle: s(18, FontWeight.w700, sora: true, spacing: -0.2),
      noticeTitle: s(14, FontWeight.w600, spacing: 0),
      noticeAction: s(13, FontWeight.w700, spacing: 0),
      headline: s(14, FontWeight.w400, spacing: 0, height: 1.35, arHeight: 1.5),
      headlineName: s(
        14,
        FontWeight.w700,
        spacing: 0,
        height: 1.35,
        arHeight: 1.5,
      ),
      tileLabel: s(15, FontWeight.w600, spacing: 0),
      emojiTile: s(22, FontWeight.w400, spacing: 0),
    );
  }

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
      noticeTitle: f(noticeTitle),
      noticeAction: f(noticeAction),
      headline: f(headline),
      headlineName: f(headlineName),
      tileLabel: f(tileLabel),
      emojiTile: f(emojiTile),
    );
  }

  static AppTextStyles forLocale(Locale locale) =>
      locale.languageCode == 'ar' ? arabic : latin;

  // The last result: `context.text` runs in many build methods, and the factor only changes on resize.
  static AppTextStyles? _lastScaled;
  static AppTextStyles? _lastBase;
  static double? _lastFactor;

  static AppTextStyles forLocaleScaled(Locale locale, double factor) {
    final base = forLocale(locale);
    if (!identical(base, _lastBase) || factor != _lastFactor) {
      _lastScaled = base.scaled(factor);
      _lastBase = base;
      _lastFactor = factor;
    }
    return _lastScaled!;
  }
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get text {
    // Reading the size subscribes to window changes, so text rescales on resize and rotation.
    MediaQuery.sizeOf(this);
    return AppTextStyles.forLocaleScaled(
      Localizations.localeOf(this),
      AppScale.factor,
    );
  }
}
