import 'package:flutter/material.dart';

import '../../enums/report_reason.dart';
import '../../enums/sheet_tone.dart';
import '../../error/failures.dart';
import '../../theme/app_dimens.dart';
import '../app_bottom_sheet.dart';
import 'report_copy.dart';
import 'report_palette.dart';
import 'report_sent_row.dart';
import 'report_steps.dart';

/// Sends a report: [note] is set only for [ReportReason.other]. Throws a [Failure] when it cannot.
typedef ReportSubmit = Future<void> Function(ReportReason reason, String? note);

/// The report flow in a bottom sheet (docs/specs/story/screens/s6-viewer-menus.md > Panel 9, and the post
/// options sheet): reasons, then a note for "Something else", then the thanks step. The feature that opens
/// it supplies the words ([ReportCopy]) and the call that sends the report.
abstract final class ReportSheet {
  /// Resolves true when a report was sent (even if the sheet was dismissed on the thanks step), false when
  /// it was closed before.
  static Future<bool> show(
    BuildContext context, {
    required ReportCopy copy,
    required ReportSubmit onSubmit,
    SheetTone tone = SheetTone.light,
    List<ReportSentRow> sentRows = const [],
  }) async {
    var sent = false;
    await AppBottomSheet.show<void>(
      context,
      tone: tone,
      child: _ReportFlow(
        copy: copy,
        tone: tone,
        onSubmit: onSubmit,
        sentRows: sentRows,
        onSent: () => sent = true,
      ),
    );
    return sent;
  }
}

enum _Step { reasons, note, sent }

class _ReportFlow extends StatefulWidget {
  const _ReportFlow({
    required this.copy,
    required this.tone,
    required this.onSubmit,
    required this.sentRows,
    required this.onSent,
  });

  final ReportCopy copy;
  final SheetTone tone;
  final ReportSubmit onSubmit;
  final List<ReportSentRow> sentRows;
  final VoidCallback onSent;

  @override
  State<_ReportFlow> createState() => _ReportFlowState();
}

class _ReportFlowState extends State<_ReportFlow> {
  _Step _step = _Step.reasons;
  ReportReason? _submitting;
  Failure? _error;

  Future<void> _send(ReportReason reason, {String? note}) async {
    setState(() {
      _submitting = reason;
      _error = null;
    });
    try {
      await widget.onSubmit(reason, note);
    } on Failure catch (failure) {
      if (mounted) {
        setState(() {
          _submitting = null;
          _error = failure;
        });
      }
      return;
    } catch (_) {
      if (mounted) setState(() => _submitting = null);
      rethrow;
    }
    widget.onSent();
    if (!mounted) return;
    setState(() {
      _submitting = null;
      _step = _Step.sent;
    });
  }

  void _pick(ReportReason reason) {
    if (reason.needsNote) {
      setState(() {
        _step = _Step.note;
        _error = null;
      });
    } else {
      _send(reason);
    }
  }

  void _close() => Navigator.of(context).pop();

  void _closeThenRun(ReportSentRow row) {
    _close();
    row.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ReportPalette.of(context, widget.tone);
    final fromEnd = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AnimatedSize(
        duration: StoryMotion.sheetIn,
        curve: StoryMotion.curve,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: StoryMotion.sheetIn,
          switchInCurve: StoryMotion.curve,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween(
              begin: Offset(fromEnd, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: switch (_step) {
            _Step.reasons => ReportReasonsStep(
              key: const ValueKey(_Step.reasons),
              palette: palette,
              copy: widget.copy,
              submitting: _submitting,
              error: _error,
              onReason: _pick,
              onClose: _close,
            ),
            _Step.note => ReportNoteStep(
              key: const ValueKey(_Step.note),
              palette: palette,
              copy: widget.copy,
              submitting: _submitting != null,
              error: _error,
              onBack: () => setState(() {
                _step = _Step.reasons;
                _error = null;
              }),
              onSend: (note) => _send(ReportReason.other, note: note),
            ),
            _Step.sent => ReportSentStep(
              key: const ValueKey(_Step.sent),
              palette: palette,
              copy: widget.copy,
              rows: widget.sentRows,
              onRow: _closeThenRun,
              onDone: _close,
            ),
          },
        ),
      ),
    );
  }
}
