import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../data/auth_repository.dart';

/// Authentication state for routing and UI.
class AuthState {
  const AuthState({this.user, this.initializing = true});

  final AppUser? user;
  final bool initializing;

  bool get isSignedIn => user != null;
  bool get isLocalMode => user?.isLocal ?? false;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? initializing,
  }) => AuthState(
    user: clearUser ? null : (user ?? this.user),
    initializing: initializing ?? this.initializing,
  );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required this.repository,
    required this.localModeEnabled,
    required this.onLocalModeChanged,
  }) : super(const AuthState()) {
    _init();
  }

  final AuthRepository repository;

  /// Reads the persisted local-mode flag.
  final bool Function() localModeEnabled;

  /// Persists the local-mode flag.
  final Future<void> Function(bool) onLocalModeChanged;

  final _log = Logger('AuthController');
  StreamSubscription<AppUser?>? _sub;

  void _init() {
    final current = repository.currentUser;
    if (current != null) {
      state = AuthState(user: current, initializing: false);
    } else if (localModeEnabled()) {
      state = const AuthState(user: AppUser.localUser, initializing: false);
    } else {
      state = const AuthState(initializing: false);
    }
    _sub = repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState(user: user, initializing: false);
      } else if (!localModeEnabled()) {
        state = const AuthState(initializing: false);
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    final user = await repository.signIn(email: email, password: password);
    await onLocalModeChanged(false);
    state = AuthState(user: user, initializing: false);
  }

  Future<void> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    final user = await repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    await onLocalModeChanged(false);
    state = AuthState(user: user, initializing: false);
  }

  Future<void> resetPassword(String email) => repository.resetPassword(email);

  Future<void> enterLocalMode() async {
    await onLocalModeChanged(true);
    state = const AuthState(user: AppUser.localUser, initializing: false);
  }

  Future<void> signOut() async {
    try {
      await repository.signOut();
    } catch (e) {
      _log.warning('signOut failed', e);
    }
    await onLocalModeChanged(false);
    state = const AuthState(initializing: false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
