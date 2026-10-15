import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_text_styles.dart';
import 'package:pulse/core/theme/colors/app_colors.dart';
import 'package:pulse/core/theme/dimens/app_dimens.dart';
import 'package:pulse/features/story/presentation/dimens/story_constants.dart';
import 'package:pulse/features/story/presentation/dimens/story_dimens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('story colors (source-tokens.md §9)', () {
    test('dark surfaces and states', () {
      expect(AppColors.light.darkSurface, const Color(0xFF1F2423));
      expect(AppColors.light.darkSurfaceRow, const Color(0xFF2A302F));
      expect(AppColors.light.dangerOnDark, const Color(0xFFFF7A7F));
      expect(AppColors.light.warningOnDark, const Color(0xFFF2B45A));
      expect(AppColors.light.successOnDark, const Color(0xFF5FD39A));
    });

    test('white and black alphas', () {
      expect(StoryColors.track, const Color(0x59FFFFFF));
      expect(StoryColors.shadeTop, const Color(0x73000000));
      expect(StoryColors.shadeBottom, const Color(0x8C000000));
      expect(StoryColors.control, const Color(0x2EFFFFFF));
      expect(StoryColors.tool, const Color(0x59000000));
    });

    test('single-use values', () {
      expect(StoryColors.cameraStart, const Color(0xFF1F2A2C));
      expect(StoryColors.cameraEnd, const Color(0xFF3D4C4F));
      expect(AppColors.light.micOffPill, const Color(0xDB1B201F));
      expect(AppColors.light.fixChipText, const Color(0xFF9ED3C9));
    });
  });

  group('story text styles', () {
    test('Latin', () {
      final s = AppTextStyles.latin;
      expect(s.overlayText.fontFamily, 'Sora');
      expect(s.overlayText.fontSize, 30);
      expect(s.overlayText.height, 1.2);
      expect(s.cameraTitle.fontSize, 17);
      expect(s.stickerLabel.fontWeight, FontWeight.w800);
      expect(s.chipLabel.fontSize, 12);
      expect(s.countLabel.fontWeight, FontWeight.w700);
    });

    test('Arabic uses Noto Sans Arabic with no letter spacing', () {
      final s = AppTextStyles.arabic;
      for (final style in [
        s.overlayText,
        s.cameraTitle,
        s.stickerLabel,
        s.chipLabel,
        s.countLabel,
      ]) {
        expect(style.fontFamily, 'NotoSansArabic');
        expect(style.letterSpacing, 0);
        expect(style.inherit, isFalse);
      }
    });
  });

  group('story dimensions and timings', () {
    testWidgets('design values at the 390 dp design width', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      expect(StoryDimens.barHeight, 3);
      expect(StoryDimens.barTop, 54);
      expect(StoryCameraDimens.shutter, 80);
      expect(StoryCameraDimens.recordRing, 92);
      expect(OptionSheetDimens.groupRadius, 18);
      expect(CameraPermissionDimens.buttonHeight, 52);
    });

    test('tap targets stay fixed', () {
      expect(StoryDimens.headerButton, 44);
      expect(OptionSheetDimens.rowMinHeight, 56);
      expect(CameraPermissionDimens.roundControl, 48);
    });

    test('timings', () {
      expect(StoryTiming.image, const Duration(seconds: 5));
      expect(StoryTiming.maxVideo, const Duration(seconds: 60));
      expect(StoryTiming.minVideo, const Duration(seconds: 1));
      expect(StoryTiming.markSeenAfter, const Duration(seconds: 1));
      expect(StoryTiming.bufferLoaderDelay, const Duration(milliseconds: 400));
      expect(StoryMotion.uiFade, const Duration(milliseconds: 150));
      expect(StoryMotion.uploadRing, const Duration(milliseconds: 240));
    });

    testWidgets('shadows', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final sticker = AppShadows.sticker.single;
      expect(sticker.color, const Color(0x40000000));
      expect(sticker.offset, const Offset(0, 6));
      expect(sticker.blurRadius, 16);
      final text = AppShadows.textOverlay.single;
      expect(text.color, const Color(0x59000000));
      expect(text.offset, const Offset(0, 2));
      expect(text.blurRadius, 12);
    });
  });
}
