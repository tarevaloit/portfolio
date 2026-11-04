import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/architecture_mode/layer_ref.dart';
import 'package:portfolio/core/architecture_mode/source_repository.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/link_opener.dart';

/// Color of [layer] in the current theme.
Color layerColor(BuildContext context, ArchitectureLayer layer) {
  final colors = AppLayerColors.of(context);
  return switch (layer) {
    ArchitectureLayer.presentation => colors.presentation,
    ArchitectureLayer.domain => colors.domain,
    ArchitectureLayer.data => colors.data,
  };
}

/// Wraps a widget of the site. With the architecture mode on, it draws a
/// border in the color of its layer and a label with the chain of real
/// classes behind it (widget → provider → use case → repository).
///
/// The overlay never changes the size or position of [child]: constraints
/// pass through untouched and the overlay is positioned on top.
class LayerBadge extends ConsumerWidget {
  const LayerBadge({
    required this.chain,
    required this.child,
    this.isMock = false,
    this.labelAlignment = Alignment.topRight,
    super.key,
  });

  /// The widget itself first, then what it depends on. Never empty
  /// (checked by `test/architecture/architecture_map_test.dart`).
  final List<LayerRef> chain;
  final Widget child;

  /// Marks hand-made mocks (the phone demos), which are not the real app.
  final bool isMock;

  /// Corner of the label. The label stays inside the widget (so its links
  /// can be tapped); pick the corner the content leaves empty.
  final Alignment labelAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(architectureModeProvider);
    final duration = context.reduceMotion ? Duration.zero : AppMotion.medium;

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: duration,
            child: enabled
                ? _Overlay(
                    chain: chain,
                    isMock: isMock,
                    alignment: labelAlignment,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _Overlay extends ConsumerWidget {
  const _Overlay({
    required this.chain,
    required this.isMock,
    required this.alignment,
  });

  final List<LayerRef> chain;
  final bool isMock;
  final Alignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = layerColor(context, chain.first.layer);
    final repository = ref.watch(sourceRepositoryUrlProvider).value;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadii.smAll,
                border: Border.all(color: color, width: 1.5),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Align(
              alignment: alignment,
              child: _Label(
                chain: chain,
                isMock: isMock,
                repository: repository,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends ConsumerWidget {
  const _Label({
    required this.chain,
    required this.isMock,
    required this.repository,
  });

  final List<LayerRef> chain;
  final bool isMock;
  final Uri? repository;

  /// Below this width only the ends of a long chain are drawn, so the label
  /// stays on one line on phones.
  static const double compactWidth = 420;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _build(context, ref, compact: constraints.maxWidth < compactWidth),
    );
  }

  Widget _build(BuildContext context, WidgetRef ref, {required bool compact}) {
    final l10n = context.l10n;
    final arrowStyle = AppTypography.monoStyle(
      size: 10,
      color: AppColors.textMuted,
    );
    final elided = compact && chain.length > 2;
    final shown = elided ? [chain.first, chain.last] : chain;

    final items = <Widget>[];
    for (final (index, layerRef) in shown.indexed) {
      if (index > 0) {
        items.add(
          ExcludeSemantics(
            child: Text(elided ? '→ … →' : '→', style: arrowStyle),
          ),
        );
      }
      items.add(
        _Chip(
          layerRef: layerRef,
          url: repository == null
              ? null
              : sourceFileUrl(repository!, layerRef.path),
          onOpen: (url) => ref.read(linkOpenerProvider).open(url),
        ),
      );
    }
    if (isMock) {
      items.add(
        Text(
          l10n.architectureMock,
          style: AppTypography.monoStyle(size: 10, color: AppColors.textMuted),
        ),
      );
    }

    final label = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: items,
        ),
      ),
    );
    if (!elided) return label;
    // Screen readers still get the whole chain.
    return Semantics(
      label: chain.map((r) => '${r.layer.name}: ${r.name}').join(', '),
      child: ExcludeSemantics(child: label),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.layerRef,
    required this.url,
    required this.onOpen,
  });

  final LayerRef layerRef;
  final Uri? url;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final color = layerColor(context, layerRef.layer);
    final text = Text(
      url == null ? layerRef.name : '${layerRef.name} ↗',
      style: AppTypography.monoStyle(
        size: 10,
        weight: FontWeight.w600,
        color: color,
      ),
    );
    final target = url;
    if (target == null) {
      return Semantics(
        label: '${layerRef.layer.name}: ${layerRef.name}',
        child: ExcludeSemantics(child: text),
      );
    }
    return Semantics(
      link: true,
      label: context.l10n.architectureOpenSource(layerRef.name),
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: () => onOpen(target), child: text),
        ),
      ),
    );
  }
}
