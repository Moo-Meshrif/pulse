/// How a post's comments are ordered. [wire] is the `p_sort` value of `post_comments`.
enum CommentSort {
  relevant('relevant'),
  newest('newest');

  const CommentSort(this.wire);

  final String wire;
}
