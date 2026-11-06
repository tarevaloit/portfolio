import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';
import 'package:portfolio/features/experience/presentation/widgets/experience_section.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_localized.dart';

void main() {
  const current = Experience(
    id: 'ueno',
    order: 1,
    company: 'ueno bank · itti',
    role: 'Flutter Developer — Mobile Core',
    highlights: ['Feature flags', 'Deploy'],
  );
  const past = Experience(
    id: 'old',
    order: 2,
    company: 'Old Co',
    role: 'Dev',
    highlights: ['Something'],
    startYear: 2019,
    endYear: 2021,
  );

  Future<void> pump(
    WidgetTester tester, {
    AppLocale locale = AppLocale.es,
    Size size = const Size(1440, 900),
  }) {
    return tester.pumpLocalized(
      const ExperienceSection(),
      locale: locale,
      size: size,
      overrides: [
        experienceRepositoryProvider.overrideWithValue(
          FakeExperienceRepository([past, current]),
        ),
      ],
    );
  }

  testWidgets('shows each position sorted, with role and highlights', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('ueno bank · itti'), findsOneWidget);
    expect(find.text('Flutter Developer — Mobile Core'), findsOneWidget);
    expect(find.text('→ Feature flags'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('ueno bank · itti')).dy,
      lessThan(tester.getTopLeft(find.text('Old Co')).dy),
    );
  });

  testWidgets('a missing start year shows no period, never a placeholder', (
    tester,
  ) async {
    await pump(tester);

    expect(find.textContaining('presente'), findsNothing);
    expect(find.textContaining('['), findsNothing);
    expect(find.text('2019 — 2021'), findsOneWidget);
  });

  testWidgets('stacks the highlights below on compact screens', (
    tester,
  ) async {
    await pump(tester, size: const Size(360, 800));

    expect(
      tester.getTopLeft(find.text('→ Feature flags')).dy,
      greaterThan(tester.getTopLeft(find.text('ueno bank · itti')).dy),
    );
    expect(
      tester.getTopLeft(find.text('→ Feature flags')).dx,
      tester.getTopLeft(find.text('ueno bank · itti')).dx,
    );
  });

  testWidgets('shows an error message when content fails', (tester) async {
    await tester.pumpLocalized(
      const ExperienceSection(),
      overrides: [
        experienceRepositoryProvider.overrideWithValue(
          FakeExperienceRepository.failing(),
        ),
      ],
    );
    await tester.pump();

    expect(find.text('No se pudo cargar la experiencia.'), findsOneWidget);
  });
}
