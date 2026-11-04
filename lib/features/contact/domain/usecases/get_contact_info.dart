import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';

/// Contact channels for the contact block and the "Descargar CV" button.
class GetContactInfo {
  const GetContactInfo(this._repository);

  final ContactRepository _repository;

  Future<ContactInfo> call(ContentLanguage language) =>
      _repository.getContactInfo(language);
}
