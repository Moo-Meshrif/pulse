import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_text_styles.dart';
import 'package:pulse/core/theme/colors/app_colors.dart';
import 'package:pulse/core/theme/dimens/app_dimens.dart';
import 'package:pulse/features/auth/presentation/dimens/auth_dimens.dart';

/// Auth spec deltas (docs/specs/auth/01-design-tokens.md). At the design width the scale factor is 1,
/// so scaled tokens equal the spec values.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dangerSoft is #FBE4E5', () {
    expect(AppColors.light.dangerSoft, const Color(0xFFFBE4E5));
  });

  test(
    'otpDigit is Sora 24/700 (Arabic: Noto Sans Arabic, letterSpacing 0)',
    () {
      expect(AppTextStyles.latin.otpDigit.fontFamily, 'Sora');
      expect(AppTextStyles.latin.otpDigit.fontSize, 24);
      expect(AppTextStyles.latin.otpDigit.fontWeight, FontWeight.w700);
      expect(AppTextStyles.arabic.otpDigit.fontFamily, 'NotoSansArabic');
      expect(AppTextStyles.arabic.otpDigit.letterSpacing, 0);
      expect(AppTextStyles.latin.otpDigit.inherit, isFalse);
    },
  );

  testWidgets('dialog tokens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    expect(DialogDimens.backdropBlurSigma, 12);
    expect(
      DialogDimens.padding,
      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    );
    expect(AppRadius.dialog, 28);
    expect(AppRadius.dialog, AppRadius.bottomSheetTop);
    expect(AppShadows.dialog, AppShadows.onboardingCards);
    expect(DialogDimens.iconCircle, 56);
    expect(DialogDimens.maxWidth, 342);
    expect(ButtonDimens.pillHeight, 48);
    expect(ButtonDimens.disabledOpacity, 0.4);
    expect(ButtonDimens.outlineVerticalPadding, 15);
  });

  testWidgets('field, tile, chip, avatar, checkbox, progress, otp tokens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    expect(
      InputDimens.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
    expect(LogoDimens.authTile, 48);
    expect(AppRadius.logoTile, 14);
    expect(AuthDimens.iconTile, 72);
    expect(AppRadius.iconTile, 22);
    expect(AuthDimens.iconTileIcon, 32);
    expect(AuthDimens.progressSegmentHeight, 4);
    expect(AuthDimens.progressSegmentGap, 4);
    expect(AuthDimens.strengthSegmentHeight, 4);
    expect(AuthDimens.strengthSegmentGap, 6);
    expect(AuthDimens.otpBoxWidth, 50);
    expect(AuthDimens.otpBoxHeight, 60);
    expect(AuthDimens.otpBoxGap, 8);
    expect(ChipDimens.interestHeight, 44);
    expect(ChipDimens.genderHeight, 40);
    expect(ChipDimens.horizontalPadding, 18);
    expect(ChipDimens.wrapSpacing, 10);
    expect(ChipDimens.interestRunSpacing, 12);
    expect(AvatarDimens.upload, 88);
    expect(AvatarDimens.list, 48);
    expect(AuthDimens.checkbox, 24);
    expect(AppRadius.checkbox, 6);
    expect(InputDimens.activeBorderWidth, 1.5);
  });
}
