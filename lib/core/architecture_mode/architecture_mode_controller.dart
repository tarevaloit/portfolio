import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether "Modo arquitectura" is on.
///
/// Phase 3 only stores the state behind the nav toggle; the overlay and
/// layer badges that react to it arrive in Phase 5.
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
