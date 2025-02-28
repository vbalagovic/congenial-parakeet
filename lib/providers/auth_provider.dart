import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  debugPrint("Creating supabaseClientProvider");
  try {
    final client = Supabase.instance.client;
    debugPrint("Supabase client retrieved: $client");
    return client;
  } catch (e) {
    debugPrint("Error getting Supabase client: $e");
    rethrow;
  }
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  debugPrint("Creating authProvider");
  try {
    final notifier = AuthNotifier(ref.read(supabaseClientProvider));
    debugPrint("AuthNotifier created");
    return notifier;
  } catch (e) {
    debugPrint("Error creating AuthNotifier: $e");
    rethrow;
  }
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabaseClient;

  AuthNotifier(this._supabaseClient) : super(AuthState()) {
    debugPrint("AuthNotifier constructor called with client: $_supabaseClient");
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint("Initializing AuthNotifier");
    try {
      final session = _supabaseClient.auth.currentSession;
      debugPrint("Current session: $session");

      if (session != null) {
        debugPrint("User is authenticated, updating state");
        state = state.copyWith(
          isAuthenticated: true,
          user: _supabaseClient.auth.currentUser,
        );
        debugPrint(
            "State updated: isAuthenticated=${state.isAuthenticated}, user=${state.user}");
      } else {
        debugPrint("User is not authenticated");
      }

      // Listen for auth state changes
      debugPrint("Setting up auth state change listener");
      _supabaseClient.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        debugPrint("Auth state changed: $event");

        if (event == AuthChangeEvent.signedIn) {
          debugPrint("User signed in, updating state");
          state = state.copyWith(
            isAuthenticated: true,
            user: _supabaseClient.auth.currentUser,
          );
          debugPrint(
              "State updated after sign in: isAuthenticated=${state.isAuthenticated}, user=${state.user}");
        } else if (event == AuthChangeEvent.signedOut) {
          debugPrint("User signed out, updating state");
          state = state.copyWith(
            isAuthenticated: false,
            user: null,
          );
          debugPrint(
              "State updated after sign out: isAuthenticated=${state.isAuthenticated}");
        }
      });
      debugPrint("Auth state change listener set up");
    } catch (e) {
      debugPrint("Error initializing AuthNotifier: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.realsocial://login-callback',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (_) {
      return Future.error(_.message);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      // Note: Supabase might require email verification depending on your settings
    } on AuthException catch (_) {
      return Future.error(_.message);
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _supabaseClient.auth.signOut();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
