import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether "Modo arquitectura" is on. App-wide, so it stays on while
/// navigating. `ArchitectureModeHost` draws the blueprint grid and every
/// `LayerBadge` its overlay when it is.
class ArchitectureModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final architectureModeProvider =
    NotifierProvider<ArchitectureModeController, bool>(
      ArchitectureModeController.new,
      name: 'architectureModeProvider',
    );
