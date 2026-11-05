import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// The real code of a feature: one tab per file, in the color of its layer,
/// and next to it the tree of the feature's files. Files of the tree that
/// have an excerpt open it.
class FeatureCode extends StatefulWidget {
  const FeatureCode({required this.snippets, this.files = const [], super.key});

  /// Below this width the tree goes under the code.
  static const double sideBySideMinWidth = 1000;
  static const double treeWidth = 340;

  final List<CodeSnippet> snippets;
  final List<String> files;

  @override
  State<FeatureCode> createState() => _FeatureCodeState();
}

class _FeatureCodeState extends State<FeatureCode> {
  int _selected = 0;

  void _select(int index) => setState(() => _selected = index);

  @override
  Widget build(BuildContext context) {
    final snippets = widget.snippets;
    final current = snippets[_selected.clamp(0, snippets.length - 1)];

    final code = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (snippets.length > 1) ...[
          _Tabs(snippets: snippets, selected: _selected, onSelect: _select),
          const SizedBox(height: AppSpacing.md),
        ],
        CodeBlock(path: current.path, code: current.code),
      ],
    );
    if (widget.files.isEmpty) return code;

    final tree = FeatureTree(
      files: widget.files,
      selectedPath: current.path,
      snippetPaths: [for (final s in snippets) s.path],
      onOpen: (path) {
        final index = snippets.indexWhere((s) => s.path == path);
        if (index != -1) _select(index);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < FeatureCode.sideBySideMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              code,
              const SizedBox(height: AppSpacing.lg),
              tree,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: FeatureCode.treeWidth, child: tree),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: code),
          ],
        );
      },
    );
  }
}

Color _layerColor(BuildContext context, CodeLayer layer) {
  final colors = AppLayerColors.of(context);
  return switch (layer) {
    CodeLayer.presentation => colors.presentation,
    CodeLayer.domain => colors.domain,
    CodeLayer.data => colors.data,
  };
}

String _layerName(BuildContext context, CodeLayer layer) {
  final l10n = context.l10n;
  return switch (layer) {
    CodeLayer.presentation => l10n.layerPresentation,
    CodeLayer.domain => l10n.layerDomain,
    CodeLayer.data => l10n.layerData,
  };
}

/// Layer a path belongs to, from its folders; `null` for anything else
/// (tests, core).
CodeLayer? _layerOfPath(String path) {
  if (path.startsWith('test/')) return null;
  for (final layer in CodeLayer.values) {
    if (path.contains('/${layer.name}/')) return layer;
  }
  return null;
}

String _fileName(String path) => path.substring(path.lastIndexOf('/') + 1);

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.snippets,
    required this.selected,
    required this.onSelect,
  });

  final List<CodeSnippet> snippets;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (index, snippet) in snippets.indexed)
          _Tab(
            label: _fileName(snippet.path),
            layerName: _layerName(context, snippet.layer),
            color: _layerColor(context, snippet.layer),
            selected: index == selected,
            idleBorder: theme.colorScheme.outline,
            onTap: () => onSelect(index),
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.layerName,
    required this.color,
    required this.selected,
    required this.idleBorder,
    required this.onTap,
  });

  final String label;
  final String layerName;
  final Color color;
  final bool selected;
  final Color idleBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$layerName: $label',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.pillAll,
          side: BorderSide(color: selected ? color : idleBorder),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 8),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.monoStyle(
                    size: 13,
                    color: selected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Folder tree of a feature. Chains of single folders are joined
/// (`lib/features/pedidos/`), files are colored by layer and tests muted.
class FeatureTree extends StatelessWidget {
  const FeatureTree({
    required this.files,
    this.selectedPath,
    this.snippetPaths = const [],
    this.onOpen,
    super.key,
  });

  static const double indent = 16;
  static const double rowHeight = 26;

  final List<String> files;
  final String? selectedPath;

  /// Files that have an excerpt; tapping them calls [onOpen].
  final List<String> snippetPaths;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    void walk(_Folder folder, int depth) {
      for (final entry in folder.folders.entries) {
        final name = StringBuffer(entry.key);
        var child = entry.value;
        // Join folders that only hold one folder.
        while (child.files.isEmpty && child.folders.length == 1) {
          final only = child.folders.entries.single;
          name.write('/${only.key}');
          child = only.value;
        }
        rows.add(_folderRow(context, '$name/', depth));
        walk(child, depth + 1);
      }
      for (final path in folder.files) {
        rows.add(_fileRow(context, path, depth));
      }
    }

    walk(_Folder.of(files), 0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              context.l10n.detailFiles,
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Deep paths scroll inside the box, never the page.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _folderRow(BuildContext context, String name, int depth) {
    return SizedBox(
      height: rowHeight,
      child: Padding(
        padding: EdgeInsets.only(left: depth * indent),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            name,
            style: AppTypography.monoStyle(
              size: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fileRow(BuildContext context, String path, int depth) {
    final theme = Theme.of(context);
    final layer = _layerOfPath(path);
    final color = layer == null
        ? AppColors.textMuted
        : _layerColor(context, layer);
    final selected = path == selectedPath;
    final openable = onOpen != null && snippetPaths.contains(path);
    final name = _fileName(path);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: AppTypography.monoStyle(
            size: 13,
            color: selected ? theme.colorScheme.onSurface : color,
            weight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        if (openable) ...[
          const SizedBox(width: AppSpacing.sm),
          // Marks the files with an excerpt; filled when it is the open one.
          DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? color : null,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: const SizedBox.square(dimension: 7),
          ),
        ],
      ],
    );

    final row = SizedBox(
      height: rowHeight,
      child: Padding(
        padding: EdgeInsets.only(left: depth * indent),
        child: Align(alignment: Alignment.centerLeft, child: label),
      ),
    );
    if (!openable) return row;
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.detailOpenFile(name),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onOpen!(path),
        borderRadius: AppRadii.smAll,
        child: row,
      ),
    );
  }
}

/// Folders and files of a list of paths, in the order they come.
class _Folder {
  _Folder();

  _Folder.of(List<String> paths) {
    for (final path in paths) {
      final parts = path.split('/');
      var folder = this;
      for (final part in parts.sublist(0, parts.length - 1)) {
        folder = folder.folders.putIfAbsent(part, _Folder.new);
      }
      folder.files.add(path);
    }
  }

  final Map<String, _Folder> folders = {};
  final List<String> files = [];
}
