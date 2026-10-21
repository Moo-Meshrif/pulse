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
  final provider = image;
  try {
    await precacheImage(provider, context);
  } catch (_) {
    return null;
  }
  if (!context.mounted) return null;
  return _capture(
    context,
    size: size,
    pixelRatio: width == null
        ? deviceRatio
        : (width / size.width).clamp(1.0, 3.0),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        Image(image: provider, fit: BoxFit.cover),
        StoryOverlaysLayer(overlays: overlays),
      ],
    ),
  );
}

/// A story picture drawn off screen: PNG bytes and their size in pixels.
typedef StoryImage = ({Uint8List bytes, int width, int height});

/// Draws the background of a story that shows a post, a top to bottom gradient of [colors], with the text
/// stickers on it, at the size of the screen; null when it cannot be drawn. The post sticker is drawn only
/// when [post] is given (a saved picture): a posted story leaves it out, the viewer draws it from its saved
/// data.
Future<StoryImage?> renderStoryBackdrop(
  BuildContext context, {
  required List<Color> colors,
  required List<StoryOverlayModel> overlays,
  Widget? post,
}) async {
  final size = MediaQuery.sizeOf(context);
  final ratio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
  final bytes = await _capture(
    context,
    size: size,
    pixelRatio: ratio,
    child: Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),
        ?post,
        StoryOverlaysLayer(overlays: overlays),
      ],
    ),
  );
  if (bytes == null) return null;
  return (
    bytes: bytes,
    width: (size.width * ratio).round(),
    height: (size.height * ratio).round(),
  );
}

/// Draws only the stickers and text of a video story on a transparent picture of the video's shape
/// ([width] x [height], any size with the same ratio), and returns the PNG bytes; null when it cannot be
/// drawn. Positions are fractions of the frame, and the sticker size follows the screen width, so it looks
/// like the viewer's.
Future<Uint8List?> renderStoryOverlay(
  BuildContext context, {
  required List<StoryOverlayModel> overlays,
  required int width,
  required int height,
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  return _capture(
    context,
    size: Size(screenWidth, screenWidth * height / width),
    pixelRatio: (width / screenWidth).clamp(1.0, 3.0),
    child: StoryOverlaysLayer(overlays: overlays),
  );
}

/// Builds [child] off screen in the root overlay for a frame, reads it as a PNG, and takes it out again.
Future<Uint8List?> _capture(
  BuildContext context, {
  required Size size,
  required double pixelRatio,
  required Widget child,
}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -size.width * 2, // off screen: only the repaint boundary is read
      top: 0,
      width: size.width,
      height: size.height,
      child: RepaintBoundary(
        key: key,
        child: Material(type: MaterialType.transparency, child: child),
      ),
    ),
  );
  overlay.insert(entry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final picture = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await picture.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}
