import 'package:flutter/widgets.dart';
import 'package:portfolio/l10n/generated/app_localizations.dart';

export 'package:portfolio/core/l10n/app_locale.dart';
export 'package:portfolio/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Shorthand for `AppLocalizations.of(context)`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
