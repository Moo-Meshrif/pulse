import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import '../cubit/story_viewer_cubit.dart';
import '../cubit/story_viewer_state.dart';
import '../utils/enums/story_pause_reason.dart';
import '../utils/enums/story_tap_action.dart';
import '../utils/enums/story_viewer_status.dart';
import '../utils/story_dismiss.dart';
import '../utils/story_tap_zone.dart';
import '../widgets/story_buffering_loader.dart';
import '../widgets/story_loading_top.dart';
import '../widgets/story_menus/story_menus.dart';
import '../widgets/story_person/story_person.dart';

class StoryViewerView extends StatefulWidget {
  const StoryViewerView({super.key, required this.authorId, this.person});

  final String authorId;

  /// Who was tapped, when the rail said (the loading screen shows them).
  final StoryRailItemEntity? person;

  @override
  State<StoryViewerView> createState() => _StoryViewerViewState();
}

class _StoryViewerViewState extends State<StoryViewerView>
    with WidgetsBindingObserver {
  PageController? _pages;
  double _drag = 0;

  /// The vertical travel of the drag, signed: down is positive.
  double _travel = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pages?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      _cubit.resume(StoryPauseReason.background);
    } else {
      _cubit.pause(StoryPauseReason.background);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusManager.instance.primaryFocus
          ?.unfocus(); // a tap beside the keyboard only closes it
      return;
    }
    final action = storyTapAction(
      dx: details.localPosition.dx,
      width: context.size?.width ?? MediaQuery.sizeOf(context).width,
      direction: Directionality.of(context),
    );
    switch (action) {
      case StoryTapAction.previous:
        _cubit.previous();
      case StoryTapAction.next:
        _cubit.next();
    }
  }

  void _onDragStart(DragStartDetails _) {
    _cubit.pause(StoryPauseReason.hold);
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Only downward moves the screen; upward is the viewers sheet of your own story.
    _travel += details.delta.dy;
    setState(() => _drag = _travel.clamp(0.0, double.infinity));
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final closes = storyDragCloses(distance: _drag, velocity: velocity);
    final opensViewers =
        _travel < -StoryGestures.closeDistance ||
        velocity < -StoryGestures.closeVelocity;
    _travel = 0;
    if (closes) {
      AppNavigator.back(context);
      return;
    }
    _cubit.resume(StoryPauseReason.hold);
    setState(() {
      _isDragging = false;
      _drag = 0;
    });
    if (opensViewers) StoryMenus.showViewers(context);
  }

  /// Moves the page to the person the Cubit moved to (a story ran out), unless a swipe already did.
  void _followPerson(StoryViewerState state) {
    final pages = _pages;
    if (pages == null || !pages.hasClients) return;
    if ((pages.page ?? state.personIndex.toDouble()).round() ==
        state.personIndex) {
      return;
    }
    pages.animateToPage(
      state.personIndex,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : StoryMotion.personSwipe,
      curve: StoryMotion.curve,
    );
  }

  StoryViewerCubit get _cubit => context.read<StoryViewerCubit>();

  bool _personChanged(StoryViewerState before, StoryViewerState state) =>
      before.personIndex != state.personIndex;

  bool _statusOrPeopleChanged(
    StoryViewerState before,
    StoryViewerState state,
  ) =>
      before.status != state.status ||
      before.people != state.people ||
      before.failure != state.failure;

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<StoryViewerCubit, StoryViewerState>(
    listenWhen: _personChanged,
    listener: (_, state) => _followPerson(state),
    buildWhen: _statusOrPeopleChanged,
    builder: (context, state) => switch (state.status) {
      // The close button shows at once: a slow load must not trap the person.
      StoryViewerStatus.loading => Stack(
        fit: StackFit.expand,
        children: [
          const StoryBufferingLoader(isWaiting: true),
          StoryLoadingTop(
            person: widget.person,
            onClose: () => AppNavigator.back(context),
          ),
        ],
      ),
      StoryViewerStatus.failed => AppEmpty.failed(
        tone: AppEmptyTone.onDark,
        onRetry: () => _cubit.retry(widget.authorId),
        onGoHome: () => AppNavigator.back(context),
        linkLabel: context.l10n.close,
      ),
      StoryViewerStatus.ready => _buildPeople(state),
    },
  );

  Widget _buildPeople(StoryViewerState state) {
    _pages ??= PageController(initialPage: state.personIndex);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _onTapUp,
      onLongPressStart: (_) => _cubit.pause(StoryPauseReason.hold),
      onLongPressEnd: (_) => _cubit.resume(StoryPauseReason.hold),
      onLongPressCancel: () => _cubit.resume(StoryPauseReason.hold),
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : StoryMotion.dragSnapBack,
        transform: Matrix4.translationValues(0, _drag, 0)
          ..scaleByDouble(storyDragScale(_drag), storyDragScale(_drag), 1, 1),
        transformAlignment: Alignment.center,
        child: Opacity(
          opacity: storyDragFade(_drag),
          child: PageView.builder(
            controller: _pages,
            allowImplicitScrolling: true,
            itemCount: state.people.length,
            onPageChanged: _cubit.showPerson,
            itemBuilder: (context, index) => StoryPerson(
              key: ValueKey(state.people[index].authorId),
              index: index,
              person: state.people[index],
            ),
          ),
        ),
      ),
    );
  }
}
