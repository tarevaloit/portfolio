import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/architecture_mode/blueprint_grid.dart';
import 'package:portfolio/core/architecture_mode/layer_badge.dart';
import 'package:portfolio/core/architecture_mode/layer_ref.dart';
import 'package:portfolio/core/architecture_mode/source_repository.dart';
import 'package:portfolio/core/platform/link_opener.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_localized.dart';

const _chain = [
  LayerRef.presentation('ProjectsSection', 'lib/a/presentation/s.dart'),
  LayerRef.domain('GetProjects', 'lib/a/domain/g.dart'),
  LayerRef.data('ProjectsRepositoryImpl', 'lib/a/data/r.dart'),
];

class _On extends ArchitectureModeController {
  @override
  bool build() => true;
}

void main() {
  const box = SizedBox(width: 400, height: 200, key: Key('child'));

  Future<void> pumpBadge(
    WidgetTester tester, {
    required bool on,
    Uri? repository,
    LinkOpener? opener,
    bool isMock = false,
  }) {
    return tester.pumpLocalized(
      const Center(
        child: LayerBadge(chain: _chain, child: box),
      ).withMock(isMock: isMock),
      scrollable: false,
      overrides: [
        if (on) architectureModeProvider.overrideWith(_On.new),
        sourceRepositoryUrlProvider.overrideWith((ref) async => repository),
        if (opener != null) linkOpenerProvider.overrideWithValue(opener),
      ],
    );
  }

  testWidgets('off: draws nothing over the child', (tester) async {
    await pumpBadge(tester, on: false);

    expect(find.text('ProjectsSection'), findsNothing);
  });

  testWidgets('on: shows the whole chain without resizing the child', (
    tester,
  ) async {
    await pumpBadge(tester, on: true);
    await tester.pump();

    expect(find.text('ProjectsSection'), findsOneWidget);
    expect(find.text('GetProjects'), findsOneWidget);
    expect(find.text('ProjectsRepositoryImpl'), findsOneWidget);
    expect(
      find.byType(LayerBadge).evaluate().single.size,
      const Size(400, 200),
    );
    expect(
      tester.getSize(find.byKey(const Key('child'))),
      const Size(400, 200),
    );
  });

  testWidgets('with the repo URL, each class opens its file', (tester) async {
    final opener = RecordingLinkOpener();
    await pumpBadge(
      tester,
      on: true,
      repository: Uri.parse('https://github.com/example/portfolio/'),
      opener: opener,
    );
    await tester.pump();

    await tester.tap(find.text('GetProjects ↗'));

    expect(
      opener.opened.single,
      Uri.parse(
        'https://github.com/example/portfolio/blob/main/lib/a/domain/g.dart',
      ),
    );
  });

  testWidgets('mocks are labelled as such', (tester) async {
    await pumpBadge(tester, on: true, isMock: true);
    await tester.pump();

    expect(find.text('maqueta'), findsOneWidget);
  });

  Future<double> gridOpacity(WidgetTester tester, {required bool on}) async {
    await tester.pumpLocalized(
      const ArchitectureModeHost(child: SizedBox.expand()),
      scrollable: false,
      overrides: [if (on) architectureModeProvider.overrideWith(_On.new)],
    );
    return tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter is BlueprintGridPainter,
            ),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
  }

  testWidgets('the grid is hidden while the mode is off', (tester) async {
    expect(await gridOpacity(tester, on: false), 0);
  });

  testWidgets('the grid shows while the mode is on', (tester) async {
    expect(await gridOpacity(tester, on: true), 1);
  });
}

extension on Widget {
  /// Rebuilds the badge with `isMock` when asked; keeps tests short.
  Widget withMock({required bool isMock}) {
    if (!isMock) return this;
    return const Center(
      child: LayerBadge(
        chain: _chain,
        isMock: true,
        child: SizedBox(width: 400, height: 200),
      ),
    );
  }
}
