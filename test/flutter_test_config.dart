import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Runs before every test file.
///
/// - Loads the real fonts and the Material icons so layout and golden
///   tests match the site (Flutter tests use a box-glyph font by default).
/// - Makes VisibilityDetector report synchronously, so it leaves no timers.
/// - Golden comparisons tolerate tiny anti-aliasing differences.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  await _loadFont('BricolageGrotesque', 'assets/fonts/BricolageGrotesque.ttf');
  await _loadFont('JetBrainsMono', 'assets/fonts/JetBrainsMono.ttf');
  // Bundled by `uses-material-design`, so icons are not boxes either.
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();

  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenComparator(
      comparator.basedir.resolve('golden_test.dart'),
    );
  }

  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

/// Accepts goldens that differ by less than [tolerance] (0.02 % of the
/// pixels): enough for anti-aliasing noise, not for a changed word.
class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.tolerance = 0.0002});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
