import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/presentation/utils/mood_value.dart';
import 'package:pulse/features/post/presentation/utils/post_feeling.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  test('every feeling has an emoji and a word in both languages', () {
    for (final key in postFeelingKeys) {
      expect(feelingEmoji(key), isNotNull, reason: key);
      expect(feelingWord(l10nEn, key), isNotEmpty, reason: key);
      expect(feelingWord(l10nAr, key), isNotEmpty, reason: key);
    }
    expect(postFeelingKeys.length, 14);
    expect(feelingEmoji('nope'), isNull);
    expect(feelingWord(l10nEn, 'nope'), isNull);
  });

  group('matchingFeelings', () {
    test('blank keeps them all, in order', () {
      expect(matchingFeelings(''), postFeelingKeys);
      expect(matchingFeelings('  '), postFeelingKeys);
    });

    test('finds by name in either language and by a common word', () {
      expect(matchingFeelings('hap'), ['happy']);
      expect(matchingFeelings('سعادة'), ['happy']);
      expect(matchingFeelings('LOL'), ['funny']);
      expect(matchingFeelings('zzz'), isEmpty);
    });
  });

  group('moodValue', () {
    const happy = PostMoodEntity(kind: MoodKind.feeling, key: 'happy');

    test('English says "feeling", Arabic says the noun', () {
      expect(moodValue(l10nEn, happy), '😊feeling happy');
      expect(moodValue(l10nAr, happy), '😊 ${l10nAr.postFeelingHappy}');
    });

    test('no mood, an activity or an unknown key show nothing', () {
      expect(moodValue(l10nEn, null), isNull);
      expect(
        moodValue(
          l10nEn,
          const PostMoodEntity(
            kind: MoodKind.activity,
            key: 'watching',
            text: 'a film',
          ),
        ),
        isNull,
      );
      expect(
        moodValue(
          l10nEn,
          const PostMoodEntity(kind: MoodKind.feeling, key: 'nope'),
        ),
        isNull,
      );
    });
  });
}
