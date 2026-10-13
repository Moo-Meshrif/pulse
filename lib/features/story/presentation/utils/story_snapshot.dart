import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../data/model/story_overlay_model.dart';
import '../widgets/story_overlays_layer.dart';

/// Draws a photo story with its stickers and text on it, as the viewer shows it (cover-fit in the screen
/// frame), and returns the PNG bytes; null when it cannot be drawn. The picture is built off screen in the
/// root overlay for a frame, then taken out again.
Future<Uint8List?> renderStoryImage(
  BuildContext context, {
  required ImageProvider image,
  required List<StoryOverlayModel> overlays,
  int? width,
}) async {
  final size = MediaQuery.sizeOf(context);
  final deviceRatio = MediaQuery.devicePixelRatioOf(context);
  final overlay = Overlay.of(context, rootOverlay: true);
  final provider = image;
  try {
    await precacheImage(provider, context);
  } catch (_) {
    return null;
  }
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -size.width * 2, // off screen: only the repaint boundary is read
      top: 0,
      width: size.width,
      height: size.height,
      child: RepaintBoundary(
        key: key,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              Image(image: provider, fit: BoxFit.cover),
              StoryOverlaysLayer(overlays: overlays),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ratio = width == null
        ? deviceRatio
        : (width / size.width).clamp(1.0, 3.0);
    final image = await boundary.toImage(pixelRatio: ratio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
