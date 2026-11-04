import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/design_system/design_system.dart';

void main() {
  Widget buildLogo({required bool disableAnimations}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(body: BrandLogo(text: 'tobias.dev')),
      ),
    );
  }

  double cursorOpacity(WidgetTester tester) {
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('_'), matching: find.byType(Opacity)),
    );
    return opacity.opacity;
  }

  testWidgets('exposes the full brand name to screen readers', (tester) async {
    await tester.pumpWidget(buildLogo(disableAnimations: true));

    expect(find.bySemanticsLabel('tobias.dev'), findsOneWidget);
  });

  testWidgets('the cursor blinks', (tester) async {
    await tester.pumpWidget(buildLogo(disableAnimations: false));

    expect(cursorOpacity(tester), 1);
    await tester.pump(const Duration(milliseconds: 700));
    expect(cursorOpacity(tester), 0);
  });

  testWidgets('the cursor stays solid with reduced motion', (tester) async {
    await tester.pumpWidget(buildLogo(disableAnimations: true));

    await tester.pump(const Duration(milliseconds: 700));
    expect(cursorOpacity(tester), 1);
  });
}
