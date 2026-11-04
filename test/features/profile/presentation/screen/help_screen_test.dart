import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/extensions/context_extensions.dart';
import 'package:pulse/features/profile/data/datasource/help_datasource.dart';
import 'package:pulse/features/profile/data/model/help_topic_model.dart';
import 'package:pulse/features/profile/presentation/cubit/help/help_cubit.dart';
import 'package:pulse/features/profile/presentation/screen/help_screen.dart';

import '../../../../helpers/pump_app.dart';

class _HelpDatasource extends Mock implements HelpDatasource {}

void main() {
  setUp(() async {
    await getIt.reset();
    final datasource = _HelpDatasource();
    when(datasource.getTopics).thenAnswer(
      (_) async => [
        const HelpTopicModel(
          id: 1,
          slug: 'messages',
          titleEn: 'Messages',
          titleAr: 'الرسائل',
        ),
      ],
    );
    when(() => datasource.getTopicQuestions(1)).thenAnswer((_) async => []);
    getIt.registerFactory<HelpCubit>(() => HelpCubit(datasource));
  });

  tearDown(() => getIt.reset());

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('empty help topic is readable in ${locale.languageCode}', (
      tester,
    ) async {
      setUpView(tester);
      await tester.pumpApp(
        const HelpScreen(slug: 'messages'),
        locale: locale,
        settle: false,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final message = locale.languageCode == 'ar'
          ? l10nAr.helpTopicEmpty
          : l10nEn.helpTopicEmpty;
      final finder = find.text(message);
      expect(finder, findsOneWidget);
      final text = tester.widget<Text>(finder);
      final color = text.style!.color!;
      final background = tester.element(finder).appColors.background;
      final foregroundLuminance = color.computeLuminance();
      final backgroundLuminance = background.computeLuminance();
      final contrast = foregroundLuminance > backgroundLuminance
          ? (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05)
          : (backgroundLuminance + 0.05) / (foregroundLuminance + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5));
    });
  }
}
