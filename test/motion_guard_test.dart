import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  test('flutter_animate is used only by motion.dart', () {
    for (final file in files) {
      if (file.path.endsWith('motion.dart')) continue;
      final source = file.readAsStringSync();
      expect(source.contains('package:flutter_animate/flutter_animate.dart'),
          isFalse,
          reason: file.path);
      expect(source.contains('.animate('), isFalse, reason: file.path);
    }
  });

  test('feature screen design literals do not increase', () {
    final source = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_screen.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');
    final limits = <RegExp, int>{
      RegExp(r'Duration\(milliseconds:'): 1,
      RegExp(r'fontSize:'): 0,
      RegExp(r'BorderRadius\.circular\(\d+'): 12,
      RegExp(r'Color\(0x'): 9,
    };
    for (final entry in limits.entries) {
      expect(
          entry.key.allMatches(source).length, lessThanOrEqualTo(entry.value),
          reason: entry.key.pattern);
    }
  });
}
