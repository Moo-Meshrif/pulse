import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_option.dart';
import 'package:pulse/features/post/presentation/utils/post_option_layout.dart';
import 'package:pulse/features/post/presentation/utils/post_options_data.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

void main() {
  PostOptionLayout layout({bool isMine = false, bool isPublic = true}) =>
      PostOptionLayout.of(
        PostOptionsData(
          postId: 'p1',
          isMine: isMine,
          username: 'sara',
          visibility: isPublic
              ? ContentAudience.public
              : ContentAudience.followers,
        ),
      );

  test("someone else's post: not interested, unfollow, mute, then report", () {
    final l = layout();
    expect(l.groupA, [
      PostOption.notInterested,
      PostOption.unfollow,
      PostOption.mute,
    ]);
    expect(l.groupB, [PostOption.report]);
  });

  test(
    'your share can be edited: edit, who can see, comments, then delete',
    () {
      final l = PostOptionLayout.of(
        const PostOptionsData(
          postId: 's1',
          isMine: true,
          username: 'sara',
          isShare: true,
        ),
      );
      expect(l.groupA, [
        PostOption.edit,
        PostOption.changeAudience,
        PostOption.toggleComments,
      ]);
      expect(l.groupB, [PostOption.delete]);
    },
  );

  test('your post: edit caption, who can see, comments, then delete', () {
    final l = layout(isMine: true);
    expect(l.groupA, [
      PostOption.edit,
      PostOption.changeAudience,
      PostOption.toggleComments,
    ]);
    expect(l.groupB, [PostOption.delete]);
  });

  test('a public post offers save, copy link and share', () {
    expect(layout().quick, [
      PostOption.save,
      PostOption.copyLink,
      PostOption.share,
    ]);
  });

  test("someone else's Followers post offers neither Share nor Copy link", () {
    expect(layout(isPublic: false).quick, [PostOption.save]);
  });

  test('your own Followers post offers Share but no Copy link', () {
    expect(layout(isMine: true, isPublic: false).quick, [
      PostOption.save,
      PostOption.share,
    ]);
  });

  test('a public post offers Copy link and Share', () {
    expect(layout().quick, [
      PostOption.save,
      PostOption.copyLink,
      PostOption.share,
    ]);
  });

  test('your Only me post has no comments switch', () {
    final l = PostOptionLayout.of(
      const PostOptionsData(
        postId: 'p1',
        isMine: true,
        username: 'sara',
        visibility: ContentAudience.onlyMe,
      ),
    );
    expect(l.groupA, [PostOption.edit, PostOption.changeAudience]);
  });

  test('your Only me post has no save, copy link or share', () {
    final l = PostOptionLayout.of(
      const PostOptionsData(
        postId: 'p1',
        isMine: true,
        username: 'sara',
        visibility: ContentAudience.onlyMe,
      ),
    );
    expect(l.quick, isEmpty);
  });
}
