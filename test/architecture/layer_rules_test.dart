import 'package:flutter_test/flutter_test.dart';

import 'layer_rules.dart';

void main() {
  test('lib/features respects the clean-architecture import rules', () {
    final violations = scanFeatures();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  group('rules', () {
    const domainFile =
        'lib/features/projects/domain/usecases/get_projects.dart';
    const dataFile = 'lib/features/projects/data/repositories/impl.dart';
    const presentationFile =
        'lib/features/projects/presentation/pages/projects_page.dart';

    test('domain can import core Dart, annotations and other domain files', () {
      expect(
        violationsFor(domainFile, [
          'dart:async',
          'package:meta/meta.dart',
          'package:freezed_annotation/freezed_annotation.dart',
          '../entities/project.dart',
          'package:portfolio/features/experience/domain/experience.dart',
        ]),
        isEmpty,
      );
    });

    test('domain cannot import Flutter, dart:ui or I/O', () {
      expect(
        violationsFor(domainFile, ['package:flutter/widgets.dart']),
        hasLength(1),
      );
      expect(violationsFor(domainFile, ['dart:ui']), hasLength(1));
      expect(violationsFor(domainFile, ['dart:io']), hasLength(1));
      expect(
        violationsFor(domainFile, [
          'package:flutter_riverpod/flutter_riverpod.dart',
        ]),
        hasLength(1),
      );
    });

    test('domain cannot import data, presentation or core', () {
      expect(
        violationsFor(domainFile, ['../../data/dtos/project_dto.dart']),
        hasLength(1),
      );
      expect(
        violationsFor(domainFile, [
          'package:portfolio/features/projects/presentation/widgets/card.dart',
        ]),
        hasLength(1),
      );
      expect(
        violationsFor(domainFile, [
          'package:portfolio/core/router/app_router.dart',
        ]),
        hasLength(1),
      );
    });

    test('data can import domain and Flutter but not presentation', () {
      expect(
        violationsFor(dataFile, [
          'package:flutter/services.dart',
          '../../domain/repositories/projects_repository.dart',
        ]),
        isEmpty,
      );
      expect(
        violationsFor(dataFile, [
          '../../presentation/pages/projects_page.dart',
        ]),
        hasLength(1),
      );
    });

    test('presentation can import domain but not data', () {
      expect(
        violationsFor(presentationFile, ['../../domain/entities/project.dart']),
        isEmpty,
      );
      expect(
        violationsFor(presentationFile, [
          'package:portfolio/features/projects/data/repositories/impl.dart',
        ]),
        hasLength(1),
      );
    });

    test('files outside feature layers are not checked', () {
      expect(
        violationsFor('lib/app/app.dart', ['package:flutter/material.dart']),
        isEmpty,
      );
    });

    test('directivesOf finds imports and exports', () {
      const source = '''
import 'dart:async';
import "package:meta/meta.dart";
export 'src/project.dart' show Project;
''';
      expect(directivesOf(source), [
        'dart:async',
        'package:meta/meta.dart',
        'src/project.dart',
      ]);
    });
  });
}
