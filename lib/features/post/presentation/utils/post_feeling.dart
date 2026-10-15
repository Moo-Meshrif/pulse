import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_localizations_ar.dart';
import '../../../../l10n/app_localizations_en.dart';

/// The feelings a post can show, by the wire key of `posts.mood_key`, in the order of the picker.
const postFeelingKeys = [
  'happy',
  'excited',
  'loved',
  'relaxed',
  'grateful',
  'motivated',
  'cool',
  'amazed',
  'tired',
  'sad',
  'determined',
  'sick',
  'funny',
  'blessed',
];

const _emoji = {
  'happy': '😊',
  'excited': '🥳',
  'loved': '😍',
  'relaxed': '😌',
  'grateful': '🙏',
  'motivated': '💪',
  'cool': '😎',
  'amazed': '🤩',
  'tired': '😴',
  'sad': '😢',
  'determined': '😤',
  'sick': '🤒',
  'funny': '😂',
  'blessed': '😇',
};

/// The emoji of feeling [key]; null for a key this app does not know.
String? feelingEmoji(String key) => _emoji[key];

/// The word of feeling [key] in the app's language (a noun in Arabic); null for an unknown key.
String? feelingWord(AppLocalizations l10n, String key) => switch (key) {
  'happy' => l10n.postFeelingHappy,
  'excited' => l10n.postFeelingExcited,
  'loved' => l10n.postFeelingLoved,
  'relaxed' => l10n.postFeelingRelaxed,
  'grateful' => l10n.postFeelingGrateful,
  'motivated' => l10n.postFeelingMotivated,
  'cool' => l10n.postFeelingCool,
  'amazed' => l10n.postFeelingAmazed,
  'tired' => l10n.postFeelingTired,
  'sad' => l10n.postFeelingSad,
  'determined' => l10n.postFeelingDetermined,
  'sick' => l10n.postFeelingSick,
  'funny' => l10n.postFeelingFunny,
  'blessed' => l10n.postFeelingBlessed,
  _ => null,
};

/// Words people may type for a feeling besides its name, in English and Arabic.
const _keywords = {
  'happy': ['joy', 'glad', 'smile', 'فرح', 'مبسوط'],
  'excited': ['party', 'thrilled', 'celebrate', 'متحمس', 'احتفال'],
  'loved': ['love', 'heart', 'adore', 'حب', 'عشق'],
  'relaxed': ['calm', 'chill', 'peace', 'هدوء', 'استرخاء'],
  'grateful': ['thanks', 'thankful', 'شكر', 'ممتن'],
  'motivated': ['strong', 'gym', 'energy', 'نشاط', 'قوة'],
  'cool': ['nice', 'awesome', 'رائع', 'جميل'],
  'amazed': ['wow', 'surprised', 'star', 'مندهش', 'انبهار'],
  'tired': ['sleepy', 'exhausted', 'نعسان', 'إرهاق'],
  'sad': ['cry', 'down', 'upset', 'بكاء', 'زعلان'],
  'determined': ['focus', 'angry', 'strong', 'إصرار', 'تركيز'],
  'sick': ['ill', 'unwell', 'fever', 'مريض', 'تعبان'],
  'funny': ['laugh', 'lol', 'haha', 'ضحك', 'نكتة'],
  'blessed': ['angel', 'pray', 'lucky', 'نعمة', 'حمد'],
};

/// The feelings whose name (in English or Arabic, whichever the app speaks) or a common word contains
/// [query], in the picker's order. A blank [query] keeps them all.
List<String> matchingFeelings(String query) {
  final text = query.trim().toLowerCase();
  if (text.isEmpty) return postFeelingKeys;
  final english = AppLocalizationsEn();
  final arabic = AppLocalizationsAr();
  return [
    for (final key in postFeelingKeys)
      if ((feelingWord(english, key) ?? '').toLowerCase().contains(text) ||
          (feelingWord(arabic, key) ?? '').contains(text) ||
          (_keywords[key] ?? const []).any(
            (word) => word.toLowerCase().contains(text),
          ))
        key,
  ];
}
