import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external links (mail, GitHub, LinkedIn, CV). Behind a provider so
/// widget tests can check what would be opened.
abstract interface class LinkOpener {
  Future<void> open(Uri uri);
}

class UrlLauncherLinkOpener implements LinkOpener {
  const UrlLauncherLinkOpener();

  @override
  Future<void> open(Uri uri) async {
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }
}

final linkOpenerProvider = Provider<LinkOpener>(
  (ref) => const UrlLauncherLinkOpener(),
  name: 'linkOpenerProvider',
);
