/// What a post's place in the feed shows: the card, the "Not interested" row, or nothing. [deleting] is
/// nothing too, but the delete can still be undone; [removed] is gone for good.
enum PostRow { card, hidden, deleting, removed }
