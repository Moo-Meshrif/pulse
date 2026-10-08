import 'package:flutter/material.dart';

/// Light color tokens (docs/specs/_theme/colors.md). Read them with `context.appColors.<token>`. Dark
/// values are not defined yet.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryPressed,
    required this.primarySoft,
    required this.storyRing,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.segmentTrack,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconInactive,
    required this.textOnPrimary,
    required this.border,
    required this.divider,
    required this.switchOff,
    required this.dashed,
    required this.like,
    required this.danger,
    required this.dangerSoft,
    required this.online,
    required this.warning,
    required this.scrim,
    required this.videoChip,
    required this.glassFill,
    required this.glassBorder,
    required this.glassActive,
    required this.avatarBackgrounds,
  });

  final Color primary;
  final Color primaryPressed;
  final Color primarySoft;
  final Color storyRing;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color segmentTrack;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconInactive;
  final Color textOnPrimary;
  final Color border;
  final Color divider;
  final Color switchOff;
  final Color dashed;
  final Color like;
  final Color danger;

  /// Leave-dialog icon circle fill (danger @ ~12% on white). Auth spec delta.
  final Color dangerSoft;
  final Color online;
  final Color warning;
  final Color scrim;
  final Color videoChip;
  final Color glassFill;
  final Color glassBorder;
  final Color glassActive;

  /// White initials go on these backgrounds, rotated per user.
  final List<Color> avatarBackgrounds;

  static const light = AppColors(
    primary: Color(0xFF2E6B63),
    primaryPressed: Color(0xFF1F4D47),
    primarySoft: Color(0xFFE2EEEB),
    storyRing: Color(0xFF9DBDB7),
    background: Color(0xFFF3F4F3),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF7F8F7),
    segmentTrack: Color(0xFFE3E7E5),
    textPrimary: Color(0xFF161A19),
    textSecondary: Color(0xFF5B6461),
    iconInactive: Color(0xFF3D4644),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFD5DAD8),
    divider: Color(0xFFE3E6E4),
    switchOff: Color(0xFFC9D3D0),
    dashed: Color(0xFF9AA6A2),
    like: Color(0xFFE0323C),
    danger: Color(0xFFC42B34),
    dangerSoft: Color(0xFFFBE4E5),
    online: Color(0xFF2FA864),
    warning: Color(0xFFD98A1E),
    scrim: Color(0x66161A19), // #161A19 @ 40%
    videoChip: Color(0x73161A19), // #161A19 @ 45%
    glassFill: Color(0x8CFFFFFF), // #FFFFFF @ 55%
    glassBorder: Color(0xCCFFFFFF), // #FFFFFF @ 80%
    glassActive: Color(0xD9FFFFFF), // #FFFFFF @ 85%
    avatarBackgrounds: [
      Color(0xFF7A4E3A),
      Color(0xFF3E5C76),
      Color(0xFF2E6B63),
      Color(0xFF5E4B7A),
      Color(0xFF6B5B2E),
      Color(0xFF8A3B4E),
      Color(0xFF4F6B4A),
    ],
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? primarySoft,
    Color? storyRing,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? segmentTrack,
    Color? textPrimary,
    Color? textSecondary,
    Color? iconInactive,
    Color? textOnPrimary,
    Color? border,
    Color? divider,
    Color? switchOff,
    Color? dashed,
    Color? like,
    Color? danger,
    Color? dangerSoft,
    Color? online,
    Color? warning,
    Color? scrim,
    Color? videoChip,
    Color? glassFill,
    Color? glassBorder,
    Color? glassActive,
    List<Color>? avatarBackgrounds,
  }) => AppColors(
    primary: primary ?? this.primary,
    primaryPressed: primaryPressed ?? this.primaryPressed,
    primarySoft: primarySoft ?? this.primarySoft,
    storyRing: storyRing ?? this.storyRing,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    segmentTrack: segmentTrack ?? this.segmentTrack,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    iconInactive: iconInactive ?? this.iconInactive,
    textOnPrimary: textOnPrimary ?? this.textOnPrimary,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    switchOff: switchOff ?? this.switchOff,
    dashed: dashed ?? this.dashed,
    like: like ?? this.like,
    danger: danger ?? this.danger,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    online: online ?? this.online,
    warning: warning ?? this.warning,
    scrim: scrim ?? this.scrim,
    videoChip: videoChip ?? this.videoChip,
    glassFill: glassFill ?? this.glassFill,
    glassBorder: glassBorder ?? this.glassBorder,
    glassActive: glassActive ?? this.glassActive,
    avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      storyRing: Color.lerp(storyRing, other.storyRing, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      segmentTrack: Color.lerp(segmentTrack, other.segmentTrack, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      switchOff: Color.lerp(switchOff, other.switchOff, t)!,
      dashed: Color.lerp(dashed, other.dashed, t)!,
      like: Color.lerp(like, other.like, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      online: Color.lerp(online, other.online, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      videoChip: Color.lerp(videoChip, other.videoChip, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassActive: Color.lerp(glassActive, other.glassActive, t)!,
      avatarBackgrounds: [
        for (var i = 0; i < avatarBackgrounds.length; i++)
          Color.lerp(avatarBackgrounds[i], other.avatarBackgrounds[i], t)!,
      ],
    );
  }
}
