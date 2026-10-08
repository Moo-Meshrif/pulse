import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/onboarding_top_bar_leading.dart';
import '../utils/onboarding_page.dart';
import '../widgets/onboarding_footer.dart';
import '../widgets/onboarding_panel.dart';
import '../widgets/onboarding_text_block.dart';
import '../widgets/onboarding_top_bar.dart';

/// The onboarding flow: one scaffold hosting a swipeable `PageView`. The page index is a local
/// `ValueNotifier`, so only the top bar and footer rebuild.
class OnboardingView extends StatefulWidget {
  const OnboardingView({
    super.key,
    required this.onSkip,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onSkip;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  final _index = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _index.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= onboardingPages.length) return;
    // Reduce motion: jump. (`animateToPage` with a zero duration does not move the page.)
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
      return;
    }
    _controller.animateToPage(
      page,
      duration: OnboardingDimens.pageAnimationDuration,
      curve: OnboardingDimens.pageAnimationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = context.l10n;
    final colors = context.appColors;

    return ValueListenableBuilder<int>(
      valueListenable: _index,
      builder: (context, index, _) => PopScope(
        // System back steps to the previous page; on the first page it leaves the app.
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goTo(index - 1);
        },
        // Web and desktop: Left / Right arrows step through the pages (Right is "next" in LTR, Left in RTL).
        child: CallbackShortcuts(
          bindings: {
            SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _goTo(index + (isRtl ? -1 : 1)),
            SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _goTo(index + (isRtl ? 1 : -1)),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: SafeArea(
                child: ContentWidth(
                  child: Column(
                    children: [
                      OnboardingTopBar(
                        leading: index == 0
                            ? OnboardingTopBarLeading.logo
                            : OnboardingTopBarLeading.back,
                        onBack: () => _goTo(index - 1),
                        onSkip: index == onboardingPages.length - 1
                            ? null
                            : widget.onSkip,
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: onboardingPages.length,
                          onPageChanged: (page) => _index.value = page,
                          itemBuilder: (context, page) {
                            final data = onboardingPages[page];
                            return CustomScrollView(
                              physics: const ClampingScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      OnboardingPanel(
                                        fill: data.fill(colors),
                                        imageAsset: data.imageAsset(locale),
                                      ),
                                      OnboardingTextBlock(
                                        title: data.title(l10n),
                                        body: data.body(l10n),
                                      ),
                                      // Takes the free height, so the footer sits at the bottom on tall
                                      // screens; with no free height it just follows the text and scrolls.
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: OnboardingFooter(
                                            index: page,
                                            count: onboardingPages.length,
                                            onNext: () => _goTo(page + 1),
                                            onGetStarted: widget.onGetStarted,
                                            onSignIn: widget.onSignIn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
