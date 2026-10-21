import 'package:flutter/material.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/extensions/l10n.dart';
import '../../../../../../shared/content/domain/entity/content_publish_line.dart';
import '../../../dimens/home_dimens.dart';
import 'publish_card_frame.dart';
import 'publish_line_header.dart';
import 'publish_line_row.dart';

/// Several posts in the line: the stacked pictures, the whole line's progress and a chevron that opens
/// one row per post. A post that failed stays visible when the card is closed.
class PublishLineCard extends StatefulWidget {
  const PublishLineCard({super.key, required this.line});

  final ContentPublishLine line;

  @override
  State<PublishLineCard> createState() => _PublishLineCardState();
}

class _PublishLineCardState extends State<PublishLineCard> {
  bool _isOpen = false;

  ContentPublishLine get _line => widget.line;

  List<ContentLineItem> get _pending => [
    for (final item in _line.items)
      if (item.state != ContentLineState.done) item,
  ];

  /// Every post still to go is waiting for the connection.
  bool get _isOffline =>
      _pending.isNotEmpty && _pending.every((i) => i.isOffline);

  bool get _hasFailed => _line.items.any(
    (item) => item.state == ContentLineState.failed && !item.isOffline,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final failedRows = [
      for (final item in _line.items)
        if (item.state == ContentLineState.failed && !item.isOffline) item,
    ];
    final rows = _isOpen ? _line.items : failedRows;
    return PublishCardFrame(
      outline: _hasFailed ? colors.warning : null,
      child: Column(
        children: [
          PublishLineHeader(
            line: _line,
            title: _title(context),
            sub: _sub(context),
            isOpen: _isOpen,
            isOffline: _isOffline,
            hasFailed: _hasFailed,
            onToggle: () => setState(() => _isOpen = !_isOpen),
          ),
          AnimatedSize(
            duration: HomeDimens.publishExpand,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (final (i, item) in _line.items.indexed)
                  if (rows.contains(item))
                    PublishLineRow(item: item, number: i + 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    if (_line.isAllDone) return l10n.postPublishAllPosted;
    if (_isOffline) return l10n.postPublishOffline;
    if (_hasFailed) {
      return l10n.postPublishSomePosted(_line.doneCount, _line.items.length);
    }
    return l10n.postPublishingMany(_line.items.length);
  }

  String _sub(BuildContext context) {
    final l10n = context.l10n;
    if (_line.isAllDone) {
      return l10n.postPublishDoneOf(_line.doneCount, _line.items.length);
    }
    if (_isOffline) return l10n.postPublishOfflineSub(_pending.length);
    if (_hasFailed) return l10n.postPublishSomeFailed(_line.failedCount);
    return l10n.postPublishProgress(
      _line.doneCount,
      _line.items.length,
      (_line.progress * 100).round(),
    );
  }
}
