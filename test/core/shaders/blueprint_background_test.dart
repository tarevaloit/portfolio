import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/shaders/blueprint_background.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required bool effects,
    bool reduceMotion = false,
  }) async {
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backgroundEffectsEnabledProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: BlueprintPage(
              child: SingleChildScrollView(child: SizedBox(height: 3000)),
            ),
          ),
        ),
      ),
    );
    // The shader asset loads outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }

  Finder shaderPaint() => find.descendant(
    of: find.byType(BlueprintBackground),
    matching: find.byType(CustomPaint),
  );

  testWidgets('loads the shader and paints it behind the page', (tester) async {
    await pumpPage(tester, effects: true);

    expect(tester.takeException(), isNull);
    expect(shaderPaint(), findsOneWidget);

    // Pointer and scroll only update uniforms; nothing throws.
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: const Offset(100, 100));
    await gesture.moveTo(const Offset(400, 300));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('with reduced motion it paints a still frame', (tester) async {
    await pumpPage(tester, effects: true, reduceMotion: true);

    expect(shaderPaint(), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('when disabled it paints nothing', (tester) async {
    await pumpPage(tester, effects: false);

    expect(shaderPaint(), findsNothing);
  });
}
