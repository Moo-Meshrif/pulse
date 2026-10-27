import 'package:flutter/material.dart';

import '../../../../post/presentation/utils/feed_post.dart';
import 'feed_post_item.dart';

/// The post cards of the feed.
class FeedPostList extends StatelessWidget {
  const FeedPostList({super.key, required this.posts});

  final List<FeedPost> posts;

  Widget _buildPost(BuildContext context, int index) {
    final post = posts[index];
    return FeedPostItem(key: ValueKey(post.id), post: post);
  }

  @override
  Widget build(BuildContext context) =>
      SliverList.builder(itemCount: posts.length, itemBuilder: _buildPost);
}
