import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard: layout numbers in features and shared widgets come from the scaled tokens
/// (`AppSpacing`, `AppRadius`, `AppShadows`, a feature's `*Dimens`) or `AppScale.scale`, never a literal,
/// so every size follows the window. A literal that must stay fixed (a tap target, a hairline) carries
/// an `// unscaled: <reason>` comment on its line.
void main() {
  // A layout property followed by a non-zero number, or a constructor that takes sizes.
  final literals = <RegExp>[
    RegExp(
      r'\b(width|height|size|minWidth|minHeight|maxWidth|maxHeight|dimension|radius|blurRadius|spreadRadius|fontSize|strokeWidth|thickness|indent|iconSize|horizontal|vertical|top|bottom|left|right|start|end)\s*:\s*-?[1-9]\d*(\.\d+)?\b',
    ),
    RegExp(
      r'\b(EdgeInsets|EdgeInsetsDirectional)\.(all|symmetric|only|fromLTRB|fromSTEB)\([^)]*\b[1-9]\d*(\.\d+)?\b',
    ),
    RegExp(r'\b(BorderRadius|Radius)\.circular\(\s*[1-9]\d*(\.\d+)?\s*\)'),
    RegExp(r'\bSize(\.square|\.fromHeight|\.fromWidth)?\(\s*[1-9]\d*'),
    RegExp(r'\bOffset\(\s*-?[1-9]\d*'),
  ];

  final roots = [Directory('lib/features'), Directory('lib/core/widgets')];
  final files = [
    for (final root in roots)
      if (root.existsSync())
        ...root
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
  ];

  test('there are files to scan', () => expect(files, isNotEmpty));

  test('no layout literal outside the scaled tokens', () {
    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final code = line.split('//').first; // ignore comments
        if (line.contains('// unscaled:') || code.trim().isEmpty) continue;
        if (code.contains('AppScale.scale')) continue;
        if (literals.any((re) => re.hasMatch(code))) {
          violations.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'Use a scaled token or AppScale.scale, or mark a fixed value `// unscaled: <reason>`:\n${violations.join('\n')}',
    );
  });
}
