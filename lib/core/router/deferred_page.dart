import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// A part of the app compiled into its own file (`deferred as`), loaded on
/// first use and remembered afterwards.
class DeferredLibrary {
  DeferredLibrary(this._load);

  final Future<void> Function() _load;
  Future<void>? _loading;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Starts (or joins) the download. Safe to call many times.
  Future<void> load() => _loading ??= _load().then((_) => _loaded = true);
}

/// Builds [builder] once [library] is loaded. If it already is, it builds
/// on the first frame (no flash), which keeps Hero transitions working;
/// otherwise it shows a placeholder while downloading.
class DeferredPage extends StatefulWidget {
  const DeferredPage({required this.library, required this.builder, super.key});

  final DeferredLibrary library;
  final WidgetBuilder builder;

  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  @override
  void initState() {
    super.initState();
    if (!widget.library.isLoaded) {
      unawaited(
        widget.library.load().then((_) {
          if (mounted) setState(() {});
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.library.isLoaded) return widget.builder(context);
    return const Scaffold(
      body: Center(
        child: SizedBox(width: 320, child: SkeletonBox(height: 320)),
      ),
    );
  }
}
