import '../../../../l10n/app_localizations.dart';
import '../../data/enums/mood_kind.dart';
import '../../domain/entity/post_mood_entity.dart';
import 'post_feeling.dart';

/// The value on the "Feeling / activity" row: "😊feeling happy" (Arabic "😊 سعادة"). Null with no mood;
/// activities show nothing until they are built.
String? moodValue(AppLocalizations l10n, PostMoodEntity? mood) {
  if (mood == null || mood.kind != MoodKind.feeling) return null;
  final emoji = feelingEmoji(mood.key);
  final word = feelingWord(l10n, mood.key);
  if (emoji == null || word == null) return null;
  return l10n.postFeelingValue(emoji, word);
}
