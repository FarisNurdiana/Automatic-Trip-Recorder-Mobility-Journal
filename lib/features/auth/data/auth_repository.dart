import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';

/// Minimal app-level user identity.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.isLocal = false,
  });

  final String id;
  final String email;
  final String? displayName;

  /// True in local mode (no Supabase account; sync disabled).
  final bool isLocal;

  static const localUser = AppUser(
    id: 'local-user',
    email: 'local@device',
    displayName: 'Pengguna Lokal',
    isLocal: true,
  );
}

/// Authentication contract. Implementations must never log tokens.
abstract interface class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

/// Supabase implementation with session persistence (handled internally by
/// the Supabase SDK via local storage).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  AppUser? _map(supabase.User? user) => user == null
      ? null
      : AppUser(
          id: user.id,
          email: user.email ?? '',
          displayName: user.userMetadata?['display_name'] as String?,
        );

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => _map(event.session?.user));

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      final user = _map(response.user);
      if (user == null) {
        throw const AuthException('Sign up returned no user');
      }
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      final user = _map(response.user);
      if (user == null) {
        throw const AuthException('Sign in returned no user');
      }
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message, e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message, e);
    }
  }
}

/// Used when Supabase is not configured: no accounts, everything local.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async =>
      throw const AuthException('Supabase is not configured');

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async =>
      throw const AuthException('Supabase is not configured');

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async =>
      throw const AuthException('Supabase is not configured');
}
