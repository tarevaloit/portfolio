import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';

/// Source of the "Sobre mí" content. Implemented in the data layer.
abstract interface class AboutRepository {
  /// Throws a [ContentFailure] if the content cannot be loaded.
  Future<AboutInfo> getAboutInfo(ContentLanguage language);
}
