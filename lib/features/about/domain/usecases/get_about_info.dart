import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';
import 'package:portfolio/features/about/domain/repositories/about_repository.dart';

/// Content of the "Sobre mí" section.
class GetAboutInfo {
  const GetAboutInfo(this._repository);

  final AboutRepository _repository;

  Future<AboutInfo> call(ContentLanguage language) =>
      _repository.getAboutInfo(language);
}
