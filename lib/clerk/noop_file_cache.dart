import 'dart:io' show File;

// ignore: implementation_imports
import 'package:clerk_flutter/src/utils/clerk_file_cache.dart';

/// Simple file cache that disables persistence (used on web).
class NoopClerkFileCache extends ClerkFileCache {
  NoopClerkFileCache();

  @override
  Stream<File> stream(
    Uri uri, {
    Duration ttl = ClerkFileCache.defaultTTL,
    Map<String, String>? headers,
  }) async* {}
}
