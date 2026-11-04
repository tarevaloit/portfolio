import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/app/di/repository_overrides.dart';

void main() {
  // Clean URLs (`/projects/fishar` instead of `/#/projects/fishar`).
  usePathUrlStrategy();
  runApp(
    ProviderScope(
      overrides: repositoryOverrides(),
      child: const PortfolioApp(),
    ),
  );
}
