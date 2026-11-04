import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/data/datasources/contact_local_data_source.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';

/// [ContactRepository] over `contact.json`.
///
/// The CV falls back to the Spanish one when there is none for the language.
class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._source);

  final ContactLocalDataSource _source;

  @override
  Future<ContactInfo> getContactInfo(ContentLanguage language) async {
    final dto = await _source.contact();
    return ContactInfo(
      email: dto.email,
      github: dto.github,
      linkedin: dto.linkedin,
      cvAssetPath:
          dto.cv[language.code] ?? dto.cv[ContentLanguage.fallback.code],
    );
  }
}
