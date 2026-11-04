import 'package:flutter/widgets.dart';

/// Corner radius tokens: 16 / 24 / 32 and pills (999).
abstract final class AppRadii {
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
