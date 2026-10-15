import '../../../../core/theme/app_scale.dart';

/// Auth form fields, tiles, chips, checkbox, avatars, OTP, progress and strength bars
/// (docs/specs/auth/01-design-tokens.md "New / differs", 02-components.md).
abstract final class AuthDimens {
  static double get iconTile => AppScale.scale(72);
  static double get iconTileIcon => AppScale.scale(32);
  static double get tileToTitleGap => AppScale.scale(24);
  // Sign-up progress: 6 segments, height 4, gap 4.
  static double get progressSegmentHeight => AppScale.scale(4);
  static double get progressSegmentGap => AppScale.scale(4);
  static const Duration progressDuration = Duration(milliseconds: 200);
  // Password strength: 4 segments, height 4, gap 6; the short S11 variant is 68 wide, gap 4.
  static double get strengthSegmentHeight => AppScale.scale(4);
  static double get strengthSegmentGap => AppScale.scale(6);
  static double get strengthShortSegmentWidth => AppScale.scale(68);
  static double get strengthShortSegmentGap => AppScale.scale(4);
  // OTP box ~50 x 60 [estimated], gap 8, radius 14; borders: idle 1, filled/error 1.5, focused 2.
  static double get otpBoxWidth => AppScale.scale(50);
  static double get otpBoxHeight => AppScale.scale(60);
  static double get otpBoxGap => AppScale.scale(8);
  static const double otpMinBoxWidth = 44; // tap target: fixed
  static const double otpIdleBorderWidth = 1; // unscaled: hairline
  static const double otpFilledBorderWidth = 1.5; // unscaled
  static const double otpFocusedBorderWidth = 2; // unscaled
  // Follow step (S8): the Follow pill is ~34 high (14 text + 8 v-padding), the tabs ~40, 20 between
  // the blocks; Interests (S7): skeleton chips.
  static double get followPillHeight => AppScale.scale(34);
  static double get followTabHeight => AppScale.scale(40);
  static double get followSectionGap => AppScale.scale(20);
  static double get followSkeletonName => AppScale.scale(120);
  static double get followSkeletonMeta => AppScale.scale(80);
  static double get skeletonLineHeight => AppScale.scale(12);
  static double get interestSkeletonWidth => AppScale.scale(96);
  // Checkbox: 24 square, radius 6, check 16 (20 on S11).
  static double get checkbox => AppScale.scale(24);
  static double get checkboxCompact => AppScale.scale(20);
  static double get checkboxCheck => AppScale.scale(16);
  static const double checkboxBorderWidth = 1; // unscaled: hairline
  static double get checkboxToLabelGap => AppScale.scale(12);
  // Password rules list (S11): a 6 dot, or a check once met, in a fixed slot so the text never shifts.
  static double get ruleDot => AppScale.scale(6);
  static double get ruleIconSlot => AppScale.scale(14);
  static double get ruleCheck => AppScale.scale(14);
  static double get ruleIconGap => AppScale.scale(8);
  static double get ruleRowGap => AppScale.scale(8);
  static double get checkboxCheckCompact => AppScale.scale(14);
  static double get stepBarSegmentsGap => AppScale.scale(8);
  // "or continue with" divider: 1 px lines, gap 12.
  static const double dividerLineWidth = 1; // unscaled: hairline
  static double get dividerGap => AppScale.scale(12);
  static const double dividerLabelMaxShare =
      0.6; // share of the row the label may take before it wraps
  static double get socialGap => AppScale.scale(12);
  // Sign in (S1): logo ~56 from the top [estimated], 32 above the form, 24 above the button and the
  // divider, 20 above the social row, the footer ~28 above the bottom.
  static double get signInTopGap => AppScale.scale(56);
  static double get signInFormGap => AppScale.scale(32);
  static double get signInSectionGap => AppScale.scale(24);
  static double get signInSocialGap => AppScale.scale(20);
  static double get signInFooterBottom => AppScale.scale(28);
  // Sign in after a session ended (S14), all [estimated] from the screenshots
  static double get signedOutBannerGap => AppScale.scale(28);
  static double get signedOutBannerPadding => AppScale.scale(14);
  static double get signedOutBannerIcon => AppScale.scale(18);
  static double get signedOutBannerIconNudge => AppScale.scale(2);
  static double get signedOutBannerTitleGap => AppScale.scale(2);
  static double get accountAvatar => AppScale.scale(40);
  static double get accountCardHeight => AppScale.scale(62);
  static const double linkTapHeight = 44; // tap target: fixed
  // Forgot password (S2): the lock tile ~24 under the back arrow [estimated], 32 above the field, 24
  // above the button. S9 footer: 20 above the links, 8 between them.
  static double get forgotTileTopGap => AppScale.scale(24);
  static double get headerToFormGap => AppScale.scale(32);
  static double get formToButtonGap => AppScale.scale(24);
  static double get linkRowTopGap => AppScale.scale(20);
  static double get linkRowGap => AppScale.scale(8);
  // Sign-up Account (S3) [estimated, ~ in the spec]: 24 under the step bar and above the fields, 10 under
  // the password, 18 above the terms line, 14 above the note, 24 above the divider, 16 above the social row.
  static double get signUpTopGap => AppScale.scale(24);
  static double get signUpMeterGap => AppScale.scale(10);
  static double get signUpTermsGap => AppScale.scale(18);
  static double get signUpNoteGap => AppScale.scale(14);
  static double get signUpDividerGap => AppScale.scale(24);
  static double get signUpSocialGap => AppScale.scale(16);
  // Verify email (S4): the code boxes ~32 under the header, the resend row ~24 under them, the link
  // under the button 12.
  static double get otpTopGap => AppScale.scale(32);
  static double get resendTopGap => AppScale.scale(24);
  static double get ctaLinkGap => AppScale.scale(12);
}
