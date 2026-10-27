import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/post/data/datasource/post_draft_datasource.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/repository/post_publishing_repository.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/shared/content/data/datasource/pending_content_datasource.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';

/// Stands in for [PostPublishingRepository.share], so tests of what surrounds it control how a share ends.
abstract class Sharer {
  Future<PostEntity?> share(
    NewPostEntity post, {
    Future<void> Function()? beforeUpload,
    void Function(double progress)? onProgress,
  });
}

class MockSharer extends Mock implements Sharer {}

class _Media extends Mock implements ContentMediaRepository {}

class _Posts extends Mock implements PostsDatasource {}

/// The real publishing repository, except that sharing is answered by [sharer].
class PublishingWithSharer extends PostPublishingRepositoryImpl {
  PublishingWithSharer(
    PostDraftDatasource local,
    PendingContentDatasource server,
    ContentPublishRepository publish,
    EventBus events,
    this.sharer,
  ) : super(local, server, _Media(), _Posts(), publish, events);

  final Sharer sharer;

  @override
  Future<PostEntity?> share(
    NewPostEntity post, {
    Future<void> Function()? beforeUpload,
    void Function(double progress)? onProgress,
  }) => sharer.share(post, beforeUpload: beforeUpload, onProgress: onProgress);
}
