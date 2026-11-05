import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/media_carousel.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/phone_frame.dart';

import '../../../../helpers/pump_localized.dart';

const _media = [
  ProjectMedia(asset: 'assets/projects/fishar-feed.webp', caption: 'El feed'),
  ProjectMedia(asset: 'assets/projects/fishar-mapa.webp', caption: 'El mapa'),
  ProjectMedia(asset: 'assets/projects/fishar-clima.webp', caption: 'El clima'),
];

Widget _carousel([List<ProjectMedia> media = _media]) => Center(
  child: MediaCarousel(
    media: media,
    captionWidth: PhoneFrame.defaultWidth,
    frameBuilder: (context, images) => PhoneFrame(child: images),
  ),
);

Finder _button(String tooltip) =>
    find.widgetWithIcon(IconButton, switch (tooltip) {
      'prev' => Icons.arrow_back_rounded,
      _ => Icons.arrow_forward_rounded,
    });

bool _enabled(WidgetTester tester, Finder button) =>
    tester.widget<IconButton>(button).onPressed != null;

void main() {
  testWidgets('the arrows move between images and update the caption', (
    tester,
  ) async {
    await tester.pumpLocalized(_carousel(), scrollable: false);

    expect(find.textContaining('El feed', findRichText: true), findsOneWidget);
    expect(_enabled(tester, _button('prev')), isFalse);

    await tester.tap(_button('next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('El mapa', findRichText: true), findsOneWidget);
    expect(find.textContaining('02/03', findRichText: true), findsOneWidget);

    await tester.tap(_button('next'));
    await tester.pumpAndSettle();
    expect(_enabled(tester, _button('next')), isFalse);

    await tester.tap(_button('prev'));
    await tester.pumpAndSettle();
    expect(find.textContaining('El mapa', findRichText: true), findsOneWidget);
  });

  testWidgets('a swipe changes the image', (tester) async {
    await tester.pumpLocalized(_carousel(), scrollable: false);

    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('El mapa', findRichText: true), findsOneWidget);
  });

  testWidgets('the keyboard arrows work once focus is inside', (tester) async {
    await tester.pumpLocalized(_carousel(), scrollable: false);
    // Tab lands on "next" ("previous" is disabled on the first image).
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.textContaining('El mapa', findRichText: true), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.textContaining('El feed', findRichText: true), findsOneWidget);
  });

  testWidgets('screen readers hear the position and the caption', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpLocalized(_carousel(), scrollable: false);

    expect(find.bySemanticsLabel('Imagen 1 de 3: El feed'), findsOneWidget);
    expect(find.byTooltip('Imagen siguiente'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a single image has no controls', (tester) async {
    await tester.pumpLocalized(
      _carousel(const [ProjectMedia(asset: 'a.webp', caption: 'Sola')]),
      scrollable: false,
    );

    expect(find.byType(IconButton), findsNothing);
    expect(find.text('Sola'), findsOneWidget);
  });
}
