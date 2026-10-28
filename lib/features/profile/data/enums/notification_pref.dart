/// One switch of Settings > Notifications, with its column in `notification_prefs`. [defaultValue] is
/// what the server uses until the person saves a choice.
enum NotificationPref {
  push(wire: 'push_enabled', defaultValue: true),
  likes(wire: 'likes', defaultValue: true),
  comments(wire: 'comments', defaultValue: true),
  mentions(wire: 'mentions', defaultValue: true),
  followers(wire: 'followers', defaultValue: true),
  messages(wire: 'messages', defaultValue: true),
  groupChats(wire: 'group_chats', defaultValue: false),
  shorts(wire: 'shorts', defaultValue: true),
  emailDigest(wire: 'email_digest', defaultValue: false),
  product(wire: 'product', defaultValue: false);

  const NotificationPref({required this.wire, required this.defaultValue});

  final String wire;
  final bool defaultValue;
}
