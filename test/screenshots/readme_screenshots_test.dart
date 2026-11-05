@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';

import '../helpers/pump_app.dart';

/// Renders the README images with the real fonts and content:
///   flutter test --run-skipped --tags screenshots
///   python3 tool/make_gif.py
const _out = 'docs/screenshots';

Future<void> _save(WidgetTester tester, String name) async {
  final app = find.byType(PortfolioApp).evaluate().single;
  await tester.runAsync(() async {
    final image = await captureImage(app);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$_out/$name.png')..createSync(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
  });
}

/// Lets asset images (icons, burndown) decode before capturing.
Future<void> _settleImages(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }
}

void main() {
  testWidgets('home, desktop', (tester) async {
    await tester.pumpPortfolio();
    await _settleImages(tester);
    await _save(tester, 'home-desktop');
  });

  testWidgets('home, mobile', (tester) async {
    await tester.pumpPortfolio(size: const Size(390, 844));
    await _settleImages(tester);
    await _save(tester, 'home-mobile');
  });

  testWidgets('project detail, desktop', (tester) async {
    await tester.pumpPortfolio(location: '/projects/fishar');
    await _settleImages(tester);
    await _save(tester, 'detail-desktop');
  });

  testWidgets('architecture mode, frames for the GIF', (tester) async {
    await tester.pumpPortfolio(reduceMotion: false);
    await tester.pump(const Duration(seconds: 2));
    await _settleImages(tester);
    final frames = Directory('$_out/frames');
    if (frames.existsSync()) frames.deleteSync(recursive: true);

    // Off for a beat, then the transition, then on for a beat.
    for (var i = 0; i < 4; i++) {
      await _save(tester, 'frames/${i.toString().padLeft(2, '0')}');
    }
    ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    ).read(architectureModeProvider.notifier).toggle();
    for (var i = 4; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      await _save(tester, 'frames/${i.toString().padLeft(2, '0')}');
    }
    await _save(tester, 'architecture-mode');
  });
}
