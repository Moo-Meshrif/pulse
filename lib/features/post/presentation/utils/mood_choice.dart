import '../../../../core/utils/equatable.dart';
import '../../domain/entity/post_mood_entity.dart';

/// What the Feeling page hands back: the mood picked, or none when the person pressed Remove or tapped the
/// chosen feeling again. Going back with the arrow hands back nothing at all.
class MoodChoice extends Equatable {
  final PostMoodEntity? mood;

  const MoodChoice(this.mood);

  @override
  List<Object?> get props => [mood];
}
