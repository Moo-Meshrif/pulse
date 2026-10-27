import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../cubit/share_sheet/share_sheet_cubit.dart';
import '../../cubit/share_sheet/share_sheet_state.dart';
import '../../dimens/share_sheet_dimens.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/post_pickers.dart';
import '../add_edit_post/visibility_chip.dart';
import '../post_ringed_avatar.dart';
import '../post_visibility/post_visibility_sheet.dart';
import 'share_tool_button.dart';

/// The box of the Share sheet: who is sharing and for whom, the words, the three tools and Share now.
class ShareComposer extends StatefulWidget {
  const ShareComposer({super.key});

  @override
  State<ShareComposer> createState() => _ShareComposerState();
}

class _ShareComposerState extends State<ShareComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  ShareSheetCubit get _cubit => context.read<ShareSheetCubit>();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _chooseAudience() async {
    if (_cubit.state.isAudienceLocked) {
      return Notices.info(context.l10n.shareAudienceLocked);
    }
    final result = await PostVisibilitySheet.choose(
      context,
      audience: _cubit.state.audience,
    );
    if (result != null) _cubit.audienceChosen(result);
  }

  Future<void> _chooseTags() async {
    final tags = await PostPickers.tags(context, _cubit.tagArgs);
    if (tags != null) _cubit.tagsChanged(tags);
  }

  Future<void> _chooseFeeling() async {
    final choice = await PostPickers.feeling(context, _cubit.state.mood);
    if (choice != null) _cubit.moodChanged(choice.mood);
  }

  Future<void> _chooseLocation() async {
    final choice = await PostPickers.place(context, _cubit.state.location);
    if (choice != null) _cubit.locationChanged(choice.name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListenableBuilder(
      listenable: _focus,
      builder: (context, child) => Container(
        padding: EdgeInsets.all(ShareSheetDimens.composerPadding),
        // Written in: white with a primary outline (board panel 2).
        decoration: BoxDecoration(
          color: _focus.hasFocus ? colors.surface : colors.background,
          borderRadius: BorderRadius.circular(ShareSheetDimens.composerRadius),
          border: Border.all(
            color: _focus.hasFocus ? colors.primary : Colors.transparent,
            width: ShareSheetDimens.composerFocusBorder,
          ),
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WhoRow(onAudience: _chooseAudience),
          SizedBox(height: ShareSheetDimens.toolGap),
          _Field(
            controller: _controller,
            focus: _focus,
            onChanged: _cubit.captionChanged,
          ),
          SizedBox(height: ShareSheetDimens.toolGap),
          // A wrap: with large text Share now drops under the tools instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: ShareSheetDimens.toolGap,
            runSpacing: ShareSheetDimens.toolGap,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: ShareSheetDimens.toolGap,
                children: [
                  _Tools(
                    onTags: _chooseTags,
                    onFeeling: _chooseFeeling,
                    onLocation: _chooseLocation,
                  ),
                  _Counter(controller: _controller, focus: _focus),
                ],
              ),
              const _ShareNowButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhoRow extends StatelessWidget {
  const _WhoRow({required this.onAudience});

  final VoidCallback onAudience;

  @override
  Widget build(BuildContext context) {
    final me = context.read<ShareSheetCubit>().me;
    final name = me?.fullName ?? me?.username;
    return Row(
      children: [
        _avatar(me?.id, name, me?.avatarUrl),
        SizedBox(width: ShareSheetDimens.avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name != null)
                AppText(
                  name,
                  style: context.text.name,
                  color: context.appColors.textPrimary,
                  maxLines: 1,
                ),
              BlocSelector<
                ShareSheetCubit,
                ShareSheetState,
                ({ContentAudience audience, bool isNarrowed, bool isLocked})
              >(
                selector: (state) => (
                  audience: state.audience,
                  isNarrowed: state.isAudienceNarrowed,
                  isLocked: state.isAudienceLocked,
                ),
                builder: (context, chip) => VisibilityChip(
                  audience: chip.audience,
                  isNarrowed: chip.isNarrowed,
                  showChevron: !chip.isLocked,
                  height: ShareSheetDimens.chipHeight,
                  color: context.appColors.surface,
                  onTap: onAudience,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(String? id, String? name, String? url) =>
      id != null && url != null && name != null
      ? PostRingedAvatar(
          authorId: id,
          name: name,
          avatarUrl: url,
          size: ShareSheetDimens.avatar,
        )
      : AvatarInitials(name: name, seed: id, size: ShareSheetDimens.avatar);
}

/// The words: a borderless field that grows to four lines and then scrolls. Done and a tap outside close
/// the keyboard.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = context.text.body.copyWith(
      color: colors.textPrimary,
      textBaseline: TextBaseline
          .alphabetic, // TextField asserts on it when inherit is false
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: ShareSheetDimens.fieldMinHeight),
      child: TextField(
        controller: controller,
        focusNode: focus,
        onChanged: onChanged,
        onTapOutside: (_) => focus.unfocus(),
        minLines: 1,
        maxLines: ShareSheetDimens.fieldMaxLines,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [
          LengthLimitingTextInputFormatter(NewPostLimits.maxCaption),
        ],
        style: style,
        decoration: InputDecoration.collapsed(
          hintText: context.l10n.shareFieldHint,
          hintStyle: style.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _Tools extends StatelessWidget {
  const _Tools({
    required this.onTags,
    required this.onFeeling,
    required this.onLocation,
  });

  final VoidCallback onTags;
  final VoidCallback onFeeling;
  final VoidCallback onLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ShareSheetCubit, ShareSheetState>(
      buildWhen: (before, now) =>
          before.tags.isEmpty != now.tags.isEmpty ||
          (before.mood == null) != (now.mood == null) ||
          (before.location == null) != (now.location == null),
      builder: (context, state) => Row(
        spacing: ShareSheetDimens.toolGap,
        children: [
          ShareToolButton(
            icon: AppAssets.tagPerson,
            label: l10n.shareTagPeople,
            hasValue: state.tags.isNotEmpty,
            onTap: onTags,
          ),
          ShareToolButton(
            icon: AppAssets.smile,
            label: l10n.shareFeeling,
            hasValue: state.mood != null,
            onTap: onFeeling,
          ),
          ShareToolButton(
            icon: AppAssets.location,
            label: l10n.shareLocation,
            hasValue: state.location != null,
            onTap: onLocation,
          ),
        ],
      ),
    );
  }
}

/// "48 / 2000" while the field is being written in; announced from 1900 characters on.
class _Counter extends StatelessWidget {
  const _Counter({required this.controller, required this.focus});

  final TextEditingController controller;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([controller, focus]),
    builder: (context, _) {
      if (!focus.hasFocus) return const SizedBox.shrink();
      final length = controller.text.length;
      final atLimit = length >= NewPostLimits.maxCaption;
      final label = context.l10n.shareCounter(length);
      return Semantics(
        liveRegion: length >= ShareSheetDimens.counterAnnounceFrom,
        label: label,
        excludeSemantics: true,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppText(
            label,
            style: context.text.caption,
            color: atLimit
                ? context.appColors.danger
                : context.appColors.textSecondary,
            maxLines: 1,
          ),
        ),
      );
    },
  );
}

class _ShareNowButton extends StatelessWidget {
  const _ShareNowButton();

  @override
  Widget build(BuildContext context) => PrimaryButton(
    label: context.l10n.shareNow,
    buttonHeight: ShareSheetDimens.shareNowHeight,
    horizontalPadding: ShareSheetDimens.shareNowPadding,
    onPressed: context.read<ShareSheetCubit>().share,
  );
}
