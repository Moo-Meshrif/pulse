import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/theme/app_dimens.dart';
import 'package:pulse/core/theme/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const colors = AppColors.light;

  group('story colors (source-tokens.md §9)', () {
    test('dark surfaces and states', () {
      expect(colors.storySheet, const Color(0xFF1F2423));
      expect(colors.storySheetRow, const Color(0xFF2A302F));
      expect(colors.dangerOnDark, const Color(0xFFFF7A7F));
      expect(colors.storyWarning, const Color(0xFFF2B45A));
      expect(colors.storySuccess, const Color(0xFF5FD39A));
    });

    test('white and black alphas', () {
      expect(colors.storyTrack, const Color(0x59FFFFFF));
      expect(colors.storyShadeTop, const Color(0x73000000));
      expect(colors.storyShadeBottom, const Color(0x8C000000));
      expect(colors.storyControl, const Color(0x2EFFFFFF));
      expect(colors.storyTool, const Color(0x59000000));
    });

    test('single-use values', () {
      expect(colors.storyCameraStart, const Color(0xFF1F2A2C));
      expect(colors.storyCameraEnd, const Color(0xFF3D4C4F));
      expect(colors.storyMicPill, const Color(0xDB1B201F));
      expect(colors.storyFixText, const Color(0xFF9ED3C9));
    });

    test('copyWith and lerp carry the story tokens', () {
      const red = Color(0xFFFF0000);
      expect(colors.copyWith(storySheet: red).storySheet, red);
      expect(colors.lerp(colors, 0.5).storyFixText, colors.storyFixText);
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
      expect(StorySheetDimens.groupRadius, 18);
      expect(StoryPermissionDimens.buttonHeight, 52);
    });

    test('tap targets stay fixed', () {
      expect(StoryDimens.headerButton, 44);
      expect(StorySheetDimens.rowMinHeight, 56);
      expect(StoryCameraDimens.roundControl, 48);
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
