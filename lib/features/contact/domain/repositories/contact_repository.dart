import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';

/// Source of contact data. Implemented in the data layer.
abstract interface class ContactRepository {
  /// Throws a [ContentFailure] if the content cannot be loaded.
  Future<ContactInfo> getContactInfo(ContentLanguage language);
}
