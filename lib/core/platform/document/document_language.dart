import 'package:flutter/widgets.dart';
import 'package:portfolio/core/platform/document/document_language_stub.dart'
    if (dart.library.js_interop) 'package:portfolio/core/platform/document/document_language_web.dart'
    as impl;

/// Keeps `<html lang>` in sync with the language of the current route, so
/// screen readers and translators know which language the page is in.
/// Does nothing outside the web.
class DocumentLanguage extends StatelessWidget {
  const DocumentLanguage({
    required this.languageCode,
    required this.child,
    super.key,
  });

  final String languageCode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    impl.setDocumentLanguage(languageCode);
    return child;
  }
}
