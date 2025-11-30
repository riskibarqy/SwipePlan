import 'package:uuid/uuid.dart';

/// Provides a consistent identifier format for Supabase storage.
///
/// Supabase-authenticated users already have UUID primary keys, but Clerk IDs
/// are alphanumeric strings. The database schema expects UUID values, so
/// Clerk IDs are deterministically converted into a UUID v5 using a fixed
/// namespace to keep the mapping stable across sessions.
class UserIdMapper {
  UserIdMapper._();

  static const _uuid = Uuid();

  /// Returns a UUID-safe identifier for persistence.
  static String normalize(String userId) {
    if (Uuid.isValidUUID(fromString: userId)) {
      return userId;
    }
    return _uuid.v5(Namespace.url.value, 'swipeplan:$userId');
  }
}
