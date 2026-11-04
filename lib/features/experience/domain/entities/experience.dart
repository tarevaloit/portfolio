import 'package:freezed_annotation/freezed_annotation.dart';

part 'experience.freezed.dart';

/// A position in the experience timeline, resolved for one language.
@freezed
abstract class Experience with _$Experience {
  const factory Experience({
    required String id,

    /// Position in the timeline (ascending).
    required int order,
    required String company,
    required String role,
    required List<String> highlights,

    /// `null` while the date is not filled in yet.
    int? startYear,

    /// `null` means the position is current ("presente").
    int? endYear,
  }) = _Experience;

  const Experience._();

  bool get isCurrent => endYear == null;
}
