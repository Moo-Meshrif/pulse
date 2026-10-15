import '../../../../core/utils/equatable.dart';
import '../../data/enums/mood_kind.dart';

/// What the author was feeling or doing: [key] is the feeling or verb, [text] is what, for an activity.
class PostMoodEntity extends Equatable {
  final MoodKind kind;
  final String key;
  final String? text;

  const PostMoodEntity({required this.kind, required this.key, this.text});

  @override
  List<Object?> get props => [kind, key, text];
}
