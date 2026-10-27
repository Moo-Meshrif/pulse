import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

/// The comments sheet (docs/specs/post/screens/s14-comments-sheet.md, "Tokens"). Values the board does not
/// give are estimated: the sort popup, the header gaps, the empty tile gaps, the retry and loader bands.
abstract final class CommentsDimens {
  /// Gap between the top of the screen and the sheet.
  static double get topGap => AppScale.scale(88);
  static double get headerGap => AppScale.scale(10); // estimated
  static double get sortChipHeight => AppScale.scale(32);
  static double get sortChipSide => AppScale.scale(12); // estimated
  static double get sortChipIcon => AppScale.scale(14); // estimated
  static double get sortChipGap => AppScale.scale(4); // estimated
  static double get sortMenuRadius => AppScale.scale(14); // estimated
  static double get sortCheck => AppScale.scale(16); // estimated
  static const double divider = 1; // unscaled: hairline
  static double get dividerGap => AppScale.scale(8); // estimated

  static EdgeInsets get rowPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(4),
    vertical: AppScale.scale(8),
  );
  static double get rowRadius => AppScale.scale(14); // board: highlight r14
  static double get avatar => AppScale.scale(36);
  static double get replyAvatar => AppScale.scale(28);
  static double get replyIndent => AppScale.scale(50);
  static double get avatarGap => AppScale.scale(10);
  static double get nameGap => AppScale.scale(6); // estimated
  static double get lineGap => AppScale.scale(2); // estimated
  static double get actionsGap => AppScale.scale(14); // estimated
  static const double heartTarget = 48; // tap target: fixed
  static double get heart =>
      AppScale.scale(18); // estimated: board 16 looked small

  static double get badgeHeight => AppScale.scale(18);
  static double get badgeSide => AppScale.scale(6); // estimated
  static double get badgeRadius => AppScale.scale(6); // estimated

  static double get viewRepliesLine => AppScale.scale(24);
  static double get viewRepliesGap => AppScale.scale(8); // estimated
  static const double viewRepliesMinHeight = 36; // tap target: fixed
  // First-load skeleton: one comment row.
  static double get skeletonNameWidth => AppScale.scale(96); // estimated
  static double get skeletonLineGap => AppScale.scale(6); // estimated
  static double get loadingBand => AppScale.scale(56); // estimated

  static double get emptyIcon => AppScale.scale(56);
  static double get emptyGap => AppScale.scale(12); // estimated
  static double get emptyBodyGap => AppScale.scale(4); // estimated

  // Composer (S14 Tokens: emoji row 22, avatar 36, field 44 r22, send 40; the rest is estimated).
  static double get composerGap => AppScale.scale(10); // estimated
  static double get composerTop => AppScale.scale(8); // estimated
  static const double emojiTarget = 48; // tap target: fixed
  static double get emoji => AppScale.scale(22);
  static double get fieldMinHeight => AppScale.scale(44);
  static double get fieldRadius => AppScale.scale(22);
  static double get fieldSide => AppScale.scale(16); // estimated
  static double get fieldVertical => AppScale.scale(12); // estimated
  static const double fieldRing = 1.5; // unscaled: stroke
  static const int fieldMaxLines = 4; // estimated
  static const double sendTarget = 48; // tap target: fixed
  static double get send => AppScale.scale(40);
  static double get sendIcon => AppScale.scale(18); // estimated
  static double get counterGap => AppScale.scale(4); // estimated

  // Mention suggestions (S14 panel 6: rows with a 36 avatar; the card's radius and padding are estimated).
  static double get mentionRadius => AppScale.scale(14); // estimated
  static const double mentionRowMinHeight = 52; // tap target: fixed
  static EdgeInsets get mentionRowPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(12), // estimated
    vertical: AppScale.scale(8), // estimated
  );

  static double get stripSide => AppScale.scale(12); // estimated
  static const double stripHeight = 40; // tap target: fixed
  static double get stripRadius => AppScale.scale(12); // estimated

  /// A comment being sent.
  static const double postingOpacity = 0.55; // unscaled: board 55%
  static double get stateIcon => AppScale.scale(14); // estimated
  static double get stateGap => AppScale.scale(6); // estimated
  static const double stateTarget = 36; // tap target: fixed

  static double get offBarPadding => AppScale.scale(14); // estimated

  // Long-press menu (S14 panel 3; sizes estimated from the board).
  static const double menuEmojiTarget = 48; // tap target: fixed
  static double get menuEmojiCircle => AppScale.scale(44); // estimated
  static double get menuEmoji => AppScale.scale(22);
  static double get menuGap => AppScale.scale(12); // estimated
  static double get menuGroupRadius => AppScale.scale(18); // estimated
  static const double menuRowMinHeight = 56; // tap target: fixed
  static double get menuRowIcon => AppScale.scale(22); // estimated
}
