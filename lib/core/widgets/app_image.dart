import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/cached_picture.dart';

/// The one image widget of the app: a picture from the network, a file, memory or the assets, with the same
/// few options for all. A network picture is cached on the device (memory and disk) through
/// `cached_picture.dart`; pass [cacheKey] (a storage path) when the link is signed, so a new link does not
/// download it again. An asset ending in `.svg` is drawn as a vector. A picture that fails to load, or has
/// not loaded yet, shows [errorBuilder] / [placeholder] (nothing by default).
class AppImage extends StatelessWidget {
  const AppImage.network(
    String this.url, {
    super.key,
    this.cacheKey,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.placeholder,
    this.errorBuilder,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.semanticLabel,
  }) : path = null,
       bytes = null,
       _source = _Source.network;

  const AppImage.file(
    String this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.placeholder,
    this.errorBuilder,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.semanticLabel,
  }) : url = null,
       cacheKey = null,
       bytes = null,
       _source = _Source.file;

  const AppImage.memory(
    Uint8List this.bytes, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.placeholder,
    this.errorBuilder,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.semanticLabel,
  }) : url = null,
       path = null,
       cacheKey = null,
       _source = _Source.memory;

  const AppImage.asset(
    String this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.placeholder,
    this.errorBuilder,
    this.frameBuilder,
    this.gaplessPlayback = false,
    this.semanticLabel,
  }) : url = null,
       cacheKey = null,
       bytes = null,
       _source = _Source.asset;

  final String? url;
  final String? path;
  final Uint8List? bytes;
  final _Source _source;

  /// Network only: the key the picture is cached under (default: the link).
  final String? cacheKey;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Decode the picture no wider than this many pixels (an avatar needs no more than twice its size).
  final int? cacheWidth;

  /// Shown until the first frame of the picture.
  final Widget? placeholder;

  /// Shown when the picture could not be loaded; nothing when null.
  final Widget Function(BuildContext context)? errorBuilder;

  /// Called for every frame (to know when the picture is ready); replaces [placeholder].
  final ImageFrameBuilder? frameBuilder;
  final bool gaplessPlayback;

  /// Read by a screen reader; without it the picture is decoration and skipped.
  final String? semanticLabel;

  ImageProvider get _provider {
    final ImageProvider provider = switch (_source) {
      _Source.network => cachedPicture(url!, cacheKey: cacheKey),
      _Source.file => FileImage(File(path!)),
      _Source.memory => MemoryImage(bytes!),
      _Source.asset => AssetImage(path!),
    };
    return ResizeImage.resizeIfNeeded(cacheWidth, null, provider);
  }

  @override
  Widget build(BuildContext context) {
    if (_source == _Source.asset && path!.endsWith('.svg')) {
      return SvgPicture.asset(
        path!,
        width: width,
        height: height,
        fit: fit,
        semanticsLabel: semanticLabel,
        placeholderBuilder: placeholder == null ? null : (_) => placeholder!,
      );
    }
    return Image(
      image: _provider,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: gaplessPlayback,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder:
          frameBuilder ??
          (placeholder == null
              ? null
              : (context, child, frame, sync) =>
                    frame == null && !sync ? placeholder! : child),
      errorBuilder: (context, error, stack) =>
          errorBuilder?.call(context) ?? const SizedBox.shrink(),
    );
  }
}

enum _Source { network, file, memory, asset }
