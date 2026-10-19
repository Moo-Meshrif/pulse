import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../services/device_tier.dart';
import 'device_tier_scope.dart';

/// Blurs what is behind [child]; a low-tier device gets a lighter blur ([DeviceTier.lowSigmaFactor]).
class BackdropBlur extends StatelessWidget {
  const BackdropBlur({super.key, required this.sigma, required this.child});

  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strength = context.isLowTier ? sigma * DeviceTier.lowSigmaFactor : sigma;
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: strength, sigmaY: strength),
      child: child,
    );
  }
}
