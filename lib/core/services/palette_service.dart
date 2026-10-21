import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:injectable/injectable.dart';

/// The colors a picture is mostly made of.
abstract interface class PaletteService {
  /// Up to [count] dominant colors of the picture at [url], most common first; empty when it cannot be
  /// read in time (the caller uses its own colors).
  Future<List<Color>> dominantColors(String url, {int count = 2});
}

/// [PaletteService] that counts the pixels of a small copy of the picture, grouped by color.
@LazySingleton(as: PaletteService)
final class PixelPaletteService implements PaletteService {
  static const _timeout = Duration(seconds: 5);

  /// Colors are read from a copy this many pixels wide.
  static const _side = 100;

  /// Each channel is cut to this many bits, so near colors count as one.
  static const _bits = 4;

  /// A color this close to another one already chosen (sum of channel differences) is skipped, so the
  /// two colors of a gradient are not two shades of the same one.
  static const _minDistance = 90;

  /// Pixels this transparent are not counted.
  static const _minAlpha = 128;

  @override
  Future<List<Color>> dominantColors(String url, {int count = 2}) async {
    try {
      final image = await _decode(url).timeout(_timeout);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      return data == null ? const [] : _top(data, count);
    } on Object {
      return const [];
    }
  }

  Future<ui.Image> _decode(String url) {
    final done = Completer<ui.Image>();
    final stream = ResizeImage(
      NetworkImage(url),
      width: _side,
    ).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        // The stream's image is shared with its cache: this one is a copy that can be disposed.
        if (!done.isCompleted) done.complete(info.image.clone());
        stream.removeListener(listener);
      },
      onError: (error, stack) {
        if (!done.isCompleted) done.completeError(error, stack);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return done.future;
  }

  List<Color> _top(ByteData data, int count) {
    const shift = 8 - _bits;
    final counts = <int, int>{};
    for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
      if (data.getUint8(i + 3) < _minAlpha) continue;
      final key =
          (data.getUint8(i) >> shift) << (2 * _bits) |
          (data.getUint8(i + 1) >> shift) << _bits |
          (data.getUint8(i + 2) >> shift);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final chosen = <Color>[];
    for (final entry in ranked) {
      final color = _colorOf(entry.key);
      if (chosen.every((other) => _distance(color, other) >= _minDistance)) {
        chosen.add(color);
      }
      if (chosen.length == count) break;
    }
    return chosen;
  }

  /// The middle of the group of colors [key] stands for.
  Color _colorOf(int key) {
    const mask = (1 << _bits) - 1;
    const step = 1 << (8 - _bits);
    int channel(int value) => (value & mask) * step + step ~/ 2;
    return Color.fromARGB(
      255,
      channel(key >> (2 * _bits)),
      channel(key >> _bits),
      channel(key),
    );
  }

  int _distance(Color a, Color b) =>
      ((a.r - b.r).abs() * 255).round() +
      ((a.g - b.g).abs() * 255).round() +
      ((a.b - b.b).abs() * 255).round();
}
