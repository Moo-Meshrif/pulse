import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/data/enums/suggestion_reason.dart';
import 'package:pulse/features/follow/data/enums/suggestion_tab.dart';

void main() {
  test('FollowStatus maps its wire values and gives none otherwise', () {
    expect(FollowStatus.fromJson('pending'), FollowStatus.pending);
    expect(FollowStatus.fromJson('accepted'), FollowStatus.accepted);
    expect(FollowStatus.fromJson('blocked'), FollowStatus.none);
    expect(FollowStatus.fromJson(null), FollowStatus.none);
  });

  test('SuggestionReason maps its wire values', () {
    expect(SuggestionReason.fromJson('mutual'), SuggestionReason.mutual);
    expect(SuggestionReason.fromJson('city'), SuggestionReason.city);
    expect(SuggestionReason.fromJson('popular'), SuggestionReason.popular);
    expect(SuggestionReason.fromJson('school'), isNull);
  });

  test('SuggestionTab values are the RPC arguments', () {
    expect(SuggestionTab.suggested.value, 'suggested');
    expect(SuggestionTab.popular.value, 'popular');
  });
}
