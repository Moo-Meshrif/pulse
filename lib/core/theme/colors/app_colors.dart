import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart';
export 'notice_colors.dart';
export 'story_colors.dart';

/// Light color tokens (docs/specs/_theme/colors.md). Read them with `context.appColors.<token>`. Dark
/// values are not defined yet. Colors that never change with the theme (the story viewer is always dark)
/// are in `StoryColors`.
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
    required this.warningSoft,
    required this.warningInk,
    required this.warningText,
    required this.scrim,
    required this.videoChip,
    required this.mediaChip,
    required this.glassFill,
    required this.glassBorder,
    required this.glassActive,
    required this.glassActiveRing,
    required this.glassFillFlat,
    required this.glassHighlightTop,
    required this.glassHighlightBottom,
    required this.badgeRing,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.addFill,
    required this.avatarBackgrounds,
    required this.darkSurface,
    required this.darkSurfaceRow,
    required this.onDark,
    required this.black,
    required this.dangerOnDark,
    required this.warningOnDark,
    required this.successOnDark,
    required this.micOffPill,
    required this.fixChipText,
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

  /// Leave-dialog icon circle fill (danger @ ~12% on white).
  final Color dangerSoft;
  final Color online;
  final Color warning;

  /// Connection-problem tone (offline page): button fill.
  final Color warningSoft;

  /// Connection-problem tone: icon.
  final Color warningInk;

  /// Connection-problem tone: label.
  final Color warningText;
  final Color scrim;
  final Color videoChip;

  /// Post chips on media (counter, mute, duration, remove).
  final Color mediaChip;
  final Color glassFill;
  final Color glassBorder;
  final Color glassActive;

  /// Hairline around the active tab bubble so its circle shows on any background.
  final Color glassActiveRing;

  /// Low-tier fallback; defined but not used (no device detection).
  final Color glassFillFlat;

  /// Inner top highlight of the nav bar.
  final Color glassHighlightTop;

  /// Inner bottom highlight of the nav bar.
  final Color glassHighlightBottom;

  /// Ring around the nav count badge.
  final Color badgeRing;

  /// Shimmer skeleton block (docs/specs/home/01-design-tokens.md > Loading).
  final Color skeletonBase;

  /// Shimmer skeleton highlight.
  final Color skeletonHighlight;

  /// Fill of the dashed add-media tile (new post).
  final Color addFill;

  /// White initials go on these backgrounds, rotated per user.
  final List<Color> avatarBackgrounds;

  /// Story sheet and dialog surface (#1F2423).
  final Color darkSurface;

  /// Row group on the story sheet (#2A302F).
  final Color darkSurfaceRow;

  /// White on media and dark surfaces; fade with StoryOpacity (#FFFFFF).
  final Color onDark;

  /// Viewer background, scrims and shades; fade with StoryOpacity (#000000).
  final Color black;

  /// Danger icon and text on a dark surface (#FF7A7F).
  final Color dangerOnDark;

  /// Amber: problem icon, "Off" label (permissions) (#F2B45A).
  final Color warningOnDark;

  /// Granted check (permissions) (#5FD39A).
  final Color successOnDark;

  /// Microphone-off pill (#1B201F @ 86%).
  final Color micOffPill;

  /// Fix chip text (#9ED3C9).
  final Color fixChipText;

  static const light = AppColors(
    primary: AppPalette.brand,
    primaryPressed: Color(0xFF1F4D47),
    primarySoft: Color(0xFFE2EEEB),
    storyRing: Color(0xFF9DBDB7),
    background: Color(0xFFF3F4F3),
    surface: AppPalette.white,
    surfaceMuted: Color(0xFFF7F8F7),
    segmentTrack: Color(0xFFE3E7E5),
    textPrimary: AppPalette.ink,
    textSecondary: Color(0xFF5B6461),
    iconInactive: Color(0xFF3D4644),
    textOnPrimary: AppPalette.white,
    border: Color(0xFFD5DAD8),
    divider: Color(0xFFE3E6E4),
    switchOff: Color(0xFFC9D3D0),
    dashed: Color(0xFF9AA6A2),
    like: Color(0xFFE0323C),
    danger: Color(0xFFC42B34),
    dangerSoft: Color(0xFFFBE4E5),
    online: Color(0xFF2FA864),
    warning: Color(0xFFD98A1E),
    warningSoft: Color(0xFFFDF0DC),
    warningInk: Color(0xFFB26F12),
    warningText: Color(0xFF8A560C),
    scrim: Color(0x66161A19), // #161A19 @ 40%
    videoChip: Color(0x73161A19), // #161A19 @ 45%
    mediaChip: Color(0x8C161A19), // #161A19 @ 55%
    glassFill: Color(0x8CFFFFFF), // #FFFFFF @ 55%
    glassBorder: Color(0xCCFFFFFF), // #FFFFFF @ 80%
    glassActive: Color(0xD9FFFFFF), // #FFFFFF @ 85%
    glassActiveRing: Color(0x14161A19), // #161A19 @ 8%
    glassFillFlat: Color(0xEBFFFFFF), // #FFFFFF @ 92%
    glassHighlightTop: Color(0xF2FFFFFF), // #FFFFFF @ 95%
    glassHighlightBottom: AppPalette.white35,
    badgeRing: Color(0xE6FFFFFF), // #FFFFFF @ 90%
    skeletonBase: Color(0xFFE6E9E7),
    skeletonHighlight: Color(0xFFF1F3F2),
    addFill: Color(0xFFF8F9F8),
    avatarBackgrounds: [
      Color(0xFF7A4E3A),
      Color(0xFF3E5C76),
      AppPalette.brand,
      Color(0xFF5E4B7A),
      Color(0xFF6B5B2E),
      Color(0xFF8A3B4E),
      Color(0xFF4F6B4A),
    ],
    darkSurface: Color(0xFF1F2423),
    darkSurfaceRow: Color(0xFF2A302F),
    onDark: AppPalette.white,
    black: AppPalette.black,
    dangerOnDark: Color(0xFFFF7A7F),
    warningOnDark: Color(0xFFF2B45A),
    successOnDark: Color(0xFF5FD39A),
    micOffPill: Color(0xDB1B201F),
    fixChipText: Color(0xFF9ED3C9),
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
    Color? warningSoft,
    Color? warningInk,
    Color? warningText,
    Color? scrim,
    Color? videoChip,
    Color? mediaChip,
    Color? glassFill,
    Color? glassBorder,
    Color? glassActive,
    Color? glassActiveRing,
    Color? glassFillFlat,
    Color? glassHighlightTop,
    Color? glassHighlightBottom,
    Color? badgeRing,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? addFill,
    List<Color>? avatarBackgrounds,
    Color? darkSurface,
    Color? darkSurfaceRow,
    Color? onDark,
    Color? black,
    Color? dangerOnDark,
    Color? warningOnDark,
    Color? successOnDark,
    Color? micOffPill,
    Color? fixChipText,
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
    warningSoft: warningSoft ?? this.warningSoft,
    warningInk: warningInk ?? this.warningInk,
    warningText: warningText ?? this.warningText,
    scrim: scrim ?? this.scrim,
    videoChip: videoChip ?? this.videoChip,
    mediaChip: mediaChip ?? this.mediaChip,
    glassFill: glassFill ?? this.glassFill,
    glassBorder: glassBorder ?? this.glassBorder,
    glassActive: glassActive ?? this.glassActive,
    glassActiveRing: glassActiveRing ?? this.glassActiveRing,
    glassFillFlat: glassFillFlat ?? this.glassFillFlat,
    glassHighlightTop: glassHighlightTop ?? this.glassHighlightTop,
    glassHighlightBottom: glassHighlightBottom ?? this.glassHighlightBottom,
    badgeRing: badgeRing ?? this.badgeRing,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    addFill: addFill ?? this.addFill,
    avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
    darkSurface: darkSurface ?? this.darkSurface,
    darkSurfaceRow: darkSurfaceRow ?? this.darkSurfaceRow,
    onDark: onDark ?? this.onDark,
    black: black ?? this.black,
    dangerOnDark: dangerOnDark ?? this.dangerOnDark,
    warningOnDark: warningOnDark ?? this.warningOnDark,
    successOnDark: successOnDark ?? this.successOnDark,
    micOffPill: micOffPill ?? this.micOffPill,
    fixChipText: fixChipText ?? this.fixChipText,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      primaryPressed: mix(primaryPressed, other.primaryPressed),
      primarySoft: mix(primarySoft, other.primarySoft),
      storyRing: mix(storyRing, other.storyRing),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      segmentTrack: mix(segmentTrack, other.segmentTrack),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      iconInactive: mix(iconInactive, other.iconInactive),
      textOnPrimary: mix(textOnPrimary, other.textOnPrimary),
      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      switchOff: mix(switchOff, other.switchOff),
      dashed: mix(dashed, other.dashed),
      like: mix(like, other.like),
      danger: mix(danger, other.danger),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      online: mix(online, other.online),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      warningInk: mix(warningInk, other.warningInk),
      warningText: mix(warningText, other.warningText),
      scrim: mix(scrim, other.scrim),
      videoChip: mix(videoChip, other.videoChip),
      mediaChip: mix(mediaChip, other.mediaChip),
      glassFill: mix(glassFill, other.glassFill),
      glassBorder: mix(glassBorder, other.glassBorder),
      glassActive: mix(glassActive, other.glassActive),
      glassActiveRing: mix(glassActiveRing, other.glassActiveRing),
      glassFillFlat: mix(glassFillFlat, other.glassFillFlat),
      glassHighlightTop: mix(glassHighlightTop, other.glassHighlightTop),
      glassHighlightBottom: mix(
        glassHighlightBottom,
        other.glassHighlightBottom,
      ),
      badgeRing: mix(badgeRing, other.badgeRing),
      skeletonBase: mix(skeletonBase, other.skeletonBase),
      skeletonHighlight: mix(skeletonHighlight, other.skeletonHighlight),
      addFill: mix(addFill, other.addFill),
      avatarBackgrounds: [
        for (var i = 0; i < avatarBackgrounds.length; i++)
          mix(avatarBackgrounds[i], other.avatarBackgrounds[i]),
      ],
      darkSurface: mix(darkSurface, other.darkSurface),
      darkSurfaceRow: mix(darkSurfaceRow, other.darkSurfaceRow),
      onDark: mix(onDark, other.onDark),
      black: mix(black, other.black),
      dangerOnDark: mix(dangerOnDark, other.dangerOnDark),
      warningOnDark: mix(warningOnDark, other.warningOnDark),
      successOnDark: mix(successOnDark, other.successOnDark),
      micOffPill: mix(micOffPill, other.micOffPill),
      fixChipText: mix(fixChipText, other.fixChipText),
    );
  }
}
