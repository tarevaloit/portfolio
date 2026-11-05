import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/app/di/repository_overrides.dart';
import 'package:portfolio/core/router/app_router.dart';

void main() {
  // Clean URLs (`/projects/fishar` instead of `/#/projects/fishar`).
  usePathUrlStrategy();
  // On the web Flutter only builds the accessibility tree after the user
  // presses a hidden "Enable accessibility" button. Turn it on from the
  // start so screen readers work right away.
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(
    ProviderScope(
      overrides: repositoryOverrides(),
      child: const PortfolioApp(),
    ),
  );
  // Once the first frame is up, fetch the deferred project detail.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(preloadDeferredRoutes()),
  );
}
