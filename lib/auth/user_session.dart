import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class UserSession extends ChangeNotifier {
  String? get userId;
}

class SupabaseUserSession extends UserSession {
  SupabaseUserSession(this._client) {
    _currentUserId = _client.auth.currentUser?.id;
    _sub = _client.auth.onAuthStateChange.listen((event) {
      final nextId = event.session?.user.id;
      if (nextId == _currentUserId) return;
      _currentUserId = nextId;
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  StreamSubscription<AuthState>? _sub;
  String? _currentUserId;

  @override
  String? get userId => _currentUserId;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class ClerkUserSession extends UserSession {
  ClerkUserSession(this._authState) {
    _currentUserId = _authState.user?.id;
    _authState.addListener(_handleAuthChange);
  }

  final ClerkAuthState _authState;
  String? _currentUserId;

  void _handleAuthChange() {
    final nextId = _authState.user?.id;
    if (nextId == _currentUserId) return;
    _currentUserId = nextId;
    notifyListeners();
  }

  @override
  String? get userId => _currentUserId;

  @override
  void dispose() {
    _authState.removeListener(_handleAuthChange);
    super.dispose();
  }
}
