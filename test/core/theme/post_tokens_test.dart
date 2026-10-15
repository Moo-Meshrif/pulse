import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_text_styles.dart';
import 'package:pulse/core/theme/colors/app_colors.dart';
import 'package:pulse/core/theme/dimens/search_field_dimens.dart';
import 'package:pulse/features/post/presentation/dimens/post_card_dimens.dart';
import 'package:pulse/features/post/presentation/dimens/post_composer_dimens.dart';
import 'package:pulse/features/post/presentation/dimens/post_options_dimens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const colors = AppColors.light;

  test('mediaChip is #161A19 at 55% and carried by copyWith and lerp', () {
    expect(colors.mediaChip, const Color(0x8C161A19));
    const red = Color(0xFFFF0000);
    expect(colors.copyWith(mediaChip: red).mediaChip, red);
    expect(colors.lerp(colors, 0.5).mediaChip, colors.mediaChip);
  });

  test('existing colors the post spec relies on', () {
    expect(colors.switchOff, const Color(0xFFC9D3D0));
    expect(colors.dashed, const Color(0xFF9AA6A2));
    expect(colors.storyRing, const Color(0xFF9DBDB7));
  });

  group('post text styles', () {
    for (final set in {
      'latin': AppTextStyles.latin,
      'arabic': AppTextStyles.arabic,
    }.entries) {
      test('${set.key}: sizes and weights', () {
        final t = set.value;
        expect(t.input.fontSize, 17);
        expect(t.input.fontWeight, FontWeight.w400);
        expect(t.chip.fontSize, 12);
        expect(t.chip.fontWeight, FontWeight.w600);
        expect(t.moreLink.fontSize, 14);
        expect(t.moreLink.fontWeight, FontWeight.w600);
        expect(t.optionTitle.fontSize, 16);
        expect(t.optionTitle.fontWeight, FontWeight.w500);
        expect(t.sheetTitle.fontSize, 18);
        expect(t.sheetTitle.fontWeight, FontWeight.w700);
      });
    }

    test('scaled carries them', () {
      expect(AppTextStyles.latin.scaled(2).input.fontSize, 34);
    });
  });

  testWidgets('post dimensions at the 390 dp design width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    expect(PostComposerDimens.avatar, 44);
    expect(PostComposerDimens.thumb, 104);
    expect(PostComposerDimens.shareHeight, 56);
    expect(PostCardDimens.avatar, 40);
    expect(PostCardDimens.actionBarHeight, 44);
    expect(VisibilityDimens.tile, 40);
    expect(SearchFieldDimens.height, 48);
    expect(PostMotion.hiddenCollapse, const Duration(milliseconds: 240));
  });
}
