import 'package:flutter/widgets.dart';

import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/location_choice.dart';
import '../../domain/entity/post_mood_entity.dart';
import 'mood_choice.dart';
import 'tag_choice.dart';
import 'tag_people_args.dart';

/// The pages the New post, Edit post and Share screens open to fill in a place, a feeling and tagged people.
/// Each resolves with what the page handed back, or null when it was left with the back arrow.
abstract final class PostPickers {
  // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.

  /// The place name picked, an empty result when it was removed; null when nothing was chosen.
  static Future<LocationChoice?> place(
    BuildContext context,
    String? current,
  ) async {
    final choice = await AppNavigator.push<Object?>(
      context,
      AppRoutes.pickPlace,
      arguments: current,
    );
    return choice is LocationChoice ? choice : null;
  }

  static Future<List<TagChoice>?> tags(
    BuildContext context,
    TagPeopleArgs args,
  ) async {
    final tags = await AppNavigator.push<Object?>(
      context,
      AppRoutes.tagPeople,
      rootNavigator: true,
      arguments: args,
    );
    return tags is List<TagChoice> ? tags : null;
  }

  /// A [MoodChoice] whose mood is null means Remove; null means nothing was chosen.
  static Future<MoodChoice?> feeling(
    BuildContext context,
    PostMoodEntity? current,
  ) async {
    final choice = await AppNavigator.push<Object?>(
      context,
      AppRoutes.feeling,
      rootNavigator: true,
      arguments: current,
    );
    return choice is MoodChoice ? choice : null;
  }
}
