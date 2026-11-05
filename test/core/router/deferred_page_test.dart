import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/router/deferred_page.dart';

import '../../helpers/pump_localized.dart';

void main() {
  testWidgets('shows a placeholder until the library loads', (tester) async {
    final download = Completer<void>();
    final library = DeferredLibrary(() => download.future);

    await tester.pumpLocalized(
      DeferredPage(library: library, builder: (_) => const Text('detail')),
      scrollable: false,
    );
    expect(find.byType(SkeletonBox), findsOneWidget);
    expect(find.text('detail'), findsNothing);

    download.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('detail'), findsOneWidget);
  });

  testWidgets('an already loaded library builds on the first frame', (
    tester,
  ) async {
    var calls = 0;
    final library = DeferredLibrary(() async => calls++);
    await tester.runAsync(library.load);
    // A second call joins the same download instead of starting another.
    await tester.runAsync(library.load);

    await tester.pumpLocalized(
      DeferredPage(library: library, builder: (_) => const Text('detail')),
      scrollable: false,
    );

    expect(find.text('detail'), findsOneWidget);
    expect(calls, 1, reason: 'the download happens once');
  });
}
