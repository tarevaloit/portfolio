import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';
import 'package:portfolio/features/contact/presentation/widgets/contact_section.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_localized.dart';

void main() {
  testWidgets('without data shows placeholders that are not links', (
    tester,
  ) async {
    final opener = RecordingLinkOpener();
    await tester.pumpLocalized(
      const ContactSection(),
      overrides: [
        contactRepositoryProvider.overrideWithValue(FakeContactRepository()),
        linkOpenerProvider.overrideWithValue(opener),
      ],
    );

    expect(find.text('¿Armamos algo juntos?'), findsOneWidget);
    expect(find.text('[TU EMAIL]'), findsOneWidget);

    await tester.tap(find.text('[TU EMAIL]'));
    await tester.tap(find.text('GitHub ↗'));
    expect(opener.opened, isEmpty);
  });

  testWidgets('with data, each channel opens its link', (tester) async {
    final opener = RecordingLinkOpener();
    await tester.pumpLocalized(
      const ContactSection(),
      locale: AppLocale.en,
      overrides: [
        contactRepositoryProvider.overrideWithValue(
          FakeContactRepository(
            ContactInfo(
              email: 'test@example.com',
              github: Uri.parse('https://github.com/example'),
              linkedin: Uri.parse('https://www.linkedin.com/in/example'),
            ),
          ),
        ),
        linkOpenerProvider.overrideWithValue(opener),
      ],
    );
    await tester.pump();

    expect(find.text('Shall we build something together?'), findsOneWidget);

    await tester.tap(find.text('test@example.com'));
    await tester.tap(find.text('GitHub ↗'));
    await tester.tap(find.text('LinkedIn ↗'));

    expect(opener.opened, [
      Uri.parse('mailto:test@example.com'),
      Uri.parse('https://github.com/example'),
      Uri.parse('https://www.linkedin.com/in/example'),
    ]);
  });
}
