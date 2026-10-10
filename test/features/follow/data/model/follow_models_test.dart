import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/follow/data/model/follow_request_model.dart';
import 'package:pulse/features/follow/data/model/suggested_profile_model.dart';

void main() {
  test('FollowRequestModel parses a follow_requests row', () {
    final model = FollowRequestModel.fromJson({
      'id': 'u2',
      'username': 'nour.adel',
      'full_name': 'Nour Adel',
      'avatar_url': null,
      'city': 'Cairo',
      'mutual_count': 12,
      'requested_at': '2026-10-10T08:00:00Z',
    });
    expect(model.fullName, 'Nour Adel');
    expect(model.mutualCount, 12);
    expect(model.requestedAt, DateTime.utc(2026, 10, 10, 8));
    expect(FollowRequestModel.fromJson(model.toJson()), model);
  });

  test('SuggestedProfileModel reads is_private', () {
    expect(
      SuggestedProfileModel.fromJson({'id': 'u2', 'is_private': true})
          .isPrivate,
      isTrue,
    );
    expect(SuggestedProfileModel.fromJson({'id': 'u2'}).isPrivate, isNull);
  });
}
