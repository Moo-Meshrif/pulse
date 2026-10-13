import '../../../../core/utils/equatable.dart';
import '../utils/enums/main_tab.dart';

/// What the main shell shows: the selected tab, the Chat badge and, once, where to go instead.
class ControlState extends Equatable {
  const ControlState({
    this.selected = MainTab.home,
    this.chatUnread = 0,
    this.redirect,
  });

  final MainTab selected;

  /// Unread chats on the Chat tab's badge; 0 hides it.
  final int chatUnread;

  /// A route the shell must leave to at once (a password reset that was started and not finished).
  final String? redirect;

  ControlState copyWith({
    MainTab? selected,
    int? chatUnread,
    String? redirect,
  }) => ControlState(
    selected: selected ?? this.selected,
    chatUnread: chatUnread ?? this.chatUnread,
    redirect: redirect ?? this.redirect,
  );

  @override
  List<Object?> get props => [selected, chatUnread, redirect];
}
