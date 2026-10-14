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
    required this.avatarBackgrounds,
    required this.storySheet,
    required this.storySheetRow,
    required this.dangerOnDark,
    required this.storyWarning,
    required this.storySuccess,
    required this.storyOnDark,
    required this.storyBlack,
    required this.storyTrack,
    required this.storyShadeTop,
    required this.storyShadeBottom,
    required this.storyControl,
    required this.storyTool,
    required this.storyCameraStart,
    required this.storyCameraEnd,
    required this.storyMicPill,
    required this.storyFixText,
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

  /// Connection-problem tone (offline page): button fill, icon and label.
  final Color warningSoft;
  final Color warningInk;
  final Color warningText;
  final Color scrim;
  final Color videoChip;

  /// Post chips on media (counter, mute, duration, remove): #161A19 @ 55%.
  final Color mediaChip;
  final Color glassFill;
  final Color glassBorder;
  final Color glassActive;
  final Color glassActiveRing;
  final Color glassFillFlat;
  final Color glassHighlightTop;
  final Color glassHighlightBottom;
  final Color badgeRing;

  /// Shimmer skeleton (Home first load): block and highlight (docs/specs/home/01-design-tokens.md > Loading).
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// White initials go on these backgrounds, rotated per user.
  final List<Color> avatarBackgrounds;

  /// Story sheet and dialog surface (#1F2423).
  final Color storySheet;

  /// Row group on the story sheet (#2A302F).
  final Color storySheetRow;

  /// Danger icon and text on a dark surface (#FF7A7F).
  final Color dangerOnDark;

  /// Amber: problem icon, "Off" label (permissions) (#F2B45A).
  final Color storyWarning;

  /// Granted check (permissions) (#5FD39A).
  final Color storySuccess;

  /// White on media and dark surfaces; fade with StoryOpacity (#FFFFFF).
  final Color storyOnDark;

  /// Viewer background, scrims and shades; fade with StoryOpacity (#000000).
  final Color storyBlack;

  /// Progress bar track (#FFFFFF @ 35%).
  final Color storyTrack;

  /// Top shade start, paused chip (#000000 @ 45%).
  final Color storyShadeTop;

  /// Bottom shade end, delete scrim (#000000 @ 55%).
  final Color storyShadeBottom;

  /// Round camera controls, grid lines, Your story pill (#FFFFFF @ 18%).
  final Color storyControl;

  /// Edit tool circles, viewers dim (#000000 @ 35%).
  final Color storyTool;

  /// Camera background gradient start (#1F2A2C).
  final Color storyCameraStart;

  /// Camera background gradient end (#3D4C4F).
  final Color storyCameraEnd;

  /// Microphone-off pill (#1B201F @ 86%).
  final Color storyMicPill;

  /// Fix chip text (#9ED3C9).
  final Color storyFixText;

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
    warningSoft: Color(0xFFFDF0DC),
    warningInk: Color(0xFFB26F12),
    warningText: Color(0xFF8A560C),
    scrim: Color(0x66161A19), // #161A19 @ 40%
    videoChip: Color(0x73161A19), // #161A19 @ 45%
    mediaChip: Color(0x8C161A19), // #161A19 @ 55%
    glassFill: Color(0x8CFFFFFF), // #FFFFFF @ 55%
    glassBorder: Color(0xCCFFFFFF), // #FFFFFF @ 80%
    glassActive: Color(0xD9FFFFFF), // #FFFFFF @ 85%
    glassActiveRing: Color(0x14161A19), // #161A19 @ 8%: hairline around the active tab bubble so its circle shows on any background
    glassFillFlat: Color(0xEBFFFFFF), // #FFFFFF @ 92%: low-tier fallback, defined but not used (no device detection)
    glassHighlightTop: Color(
      0xF2FFFFFF,
    ), // #FFFFFF @ 95%: inner top highlight of the nav bar
    glassHighlightBottom: Color(
      0x59FFFFFF,
    ), // #FFFFFF @ 35%: inner bottom highlight of the nav bar
    badgeRing: Color(
      0xE6FFFFFF,
    ), // #FFFFFF @ 90%: ring around the nav count badge
    skeletonBase: Color(0xFFE6E9E7),
    skeletonHighlight: Color(0xFFF1F3F2),
    avatarBackgrounds: [
      Color(0xFF7A4E3A),
      Color(0xFF3E5C76),
      Color(0xFF2E6B63),
      Color(0xFF5E4B7A),
      Color(0xFF6B5B2E),
      Color(0xFF8A3B4E),
      Color(0xFF4F6B4A),
    ],
    storySheet: Color(0xFF1F2423),
    storySheetRow: Color(0xFF2A302F),
    dangerOnDark: Color(0xFFFF7A7F),
    storyWarning: Color(0xFFF2B45A),
    storySuccess: Color(0xFF5FD39A),
    storyOnDark: Color(0xFFFFFFFF),
    storyBlack: Color(0xFF000000),
    storyTrack: Color(0x59FFFFFF),
    storyShadeTop: Color(0x73000000),
    storyShadeBottom: Color(0x8C000000),
    storyControl: Color(0x2EFFFFFF),
    storyTool: Color(0x59000000),
    storyCameraStart: Color(0xFF1F2A2C),
    storyCameraEnd: Color(0xFF3D4C4F),
    storyMicPill: Color(0xDB1B201F),
    storyFixText: Color(0xFF9ED3C9),
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
    List<Color>? avatarBackgrounds,
    Color? storySheet,
    Color? storySheetRow,
    Color? dangerOnDark,
    Color? storyWarning,
    Color? storySuccess,
    Color? storyOnDark,
    Color? storyBlack,
    Color? storyTrack,
    Color? storyShadeTop,
    Color? storyShadeBottom,
    Color? storyControl,
    Color? storyTool,
    Color? storyCameraStart,
    Color? storyCameraEnd,
    Color? storyMicPill,
    Color? storyFixText,
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
    avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
    storySheet: storySheet ?? this.storySheet,
    storySheetRow: storySheetRow ?? this.storySheetRow,
    dangerOnDark: dangerOnDark ?? this.dangerOnDark,
    storyWarning: storyWarning ?? this.storyWarning,
    storySuccess: storySuccess ?? this.storySuccess,
    storyOnDark: storyOnDark ?? this.storyOnDark,
    storyBlack: storyBlack ?? this.storyBlack,
    storyTrack: storyTrack ?? this.storyTrack,
    storyShadeTop: storyShadeTop ?? this.storyShadeTop,
    storyShadeBottom: storyShadeBottom ?? this.storyShadeBottom,
    storyControl: storyControl ?? this.storyControl,
    storyTool: storyTool ?? this.storyTool,
    storyCameraStart: storyCameraStart ?? this.storyCameraStart,
    storyCameraEnd: storyCameraEnd ?? this.storyCameraEnd,
    storyMicPill: storyMicPill ?? this.storyMicPill,
    storyFixText: storyFixText ?? this.storyFixText,
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
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningInk: Color.lerp(warningInk, other.warningInk, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      videoChip: Color.lerp(videoChip, other.videoChip, t)!,
      mediaChip: Color.lerp(mediaChip, other.mediaChip, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassActive: Color.lerp(glassActive, other.glassActive, t)!,
      glassActiveRing: Color.lerp(glassActiveRing, other.glassActiveRing, t)!,
      glassFillFlat: Color.lerp(glassFillFlat, other.glassFillFlat, t)!,
      glassHighlightTop: Color.lerp(
        glassHighlightTop,
        other.glassHighlightTop,
        t,
      )!,
      glassHighlightBottom: Color.lerp(
        glassHighlightBottom,
        other.glassHighlightBottom,
        t,
      )!,
      badgeRing: Color.lerp(badgeRing, other.badgeRing, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      avatarBackgrounds: [
        for (var i = 0; i < avatarBackgrounds.length; i++)
          Color.lerp(avatarBackgrounds[i], other.avatarBackgrounds[i], t)!,
      ],
      storySheet: Color.lerp(storySheet, other.storySheet, t)!,
      storySheetRow: Color.lerp(storySheetRow, other.storySheetRow, t)!,
      dangerOnDark: Color.lerp(dangerOnDark, other.dangerOnDark, t)!,
      storyWarning: Color.lerp(storyWarning, other.storyWarning, t)!,
      storySuccess: Color.lerp(storySuccess, other.storySuccess, t)!,
      storyOnDark: Color.lerp(storyOnDark, other.storyOnDark, t)!,
      storyBlack: Color.lerp(storyBlack, other.storyBlack, t)!,
      storyTrack: Color.lerp(storyTrack, other.storyTrack, t)!,
      storyShadeTop: Color.lerp(storyShadeTop, other.storyShadeTop, t)!,
      storyShadeBottom: Color.lerp(
        storyShadeBottom,
        other.storyShadeBottom,
        t,
      )!,
      storyControl: Color.lerp(storyControl, other.storyControl, t)!,
      storyTool: Color.lerp(storyTool, other.storyTool, t)!,
      storyCameraStart: Color.lerp(
        storyCameraStart,
        other.storyCameraStart,
        t,
      )!,
      storyCameraEnd: Color.lerp(storyCameraEnd, other.storyCameraEnd, t)!,
      storyMicPill: Color.lerp(storyMicPill, other.storyMicPill, t)!,
      storyFixText: Color.lerp(storyFixText, other.storyFixText, t)!,
    );
  }
}
