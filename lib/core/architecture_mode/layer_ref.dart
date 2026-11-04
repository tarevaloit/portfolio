import 'package:flutter/foundation.dart';

/// Clean-architecture layer of a class.
enum ArchitectureLayer { presentation, domain, data }

/// A real class (or provider) of this repo and the file that declares it.
@immutable
class LayerRef {
  const LayerRef(this.layer, this.name, this.path);

  const LayerRef.presentation(this.name, this.path)
    : layer = ArchitectureLayer.presentation;
  const LayerRef.domain(this.name, this.path)
    : layer = ArchitectureLayer.domain;
  const LayerRef.data(this.name, this.path) : layer = ArchitectureLayer.data;

  final ArchitectureLayer layer;
  final String name;

  /// Path from the repo root, e.g. `lib/features/projects/...dart`.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is LayerRef &&
      other.layer == layer &&
      other.name == name &&
      other.path == path;

  @override
  int get hashCode => Object.hash(layer, name, path);
}
