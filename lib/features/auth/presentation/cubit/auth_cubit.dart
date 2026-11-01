import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart' as app_user;
import 'auth_state.dart' as auth_ui;

class AuthCubit extends Cubit<auth_ui.AuthState> {
  AuthCubit() : super(const auth_ui.AuthInitial()) {
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
        (change) {
          switch (change.event) {
            case AuthChangeEvent.passwordRecovery:
              emit(const auth_ui.AuthPasswordRecovery());
            case AuthChangeEvent.signedIn:
              final session = change.session;
              if (session != null) {
                emit(_authenticatedState(session.user));
              }
            case AuthChangeEvent.signedOut:
              emit(const auth_ui.AuthInitial());
            default:
              break;
          }
        },
      );
    } catch (_) {
      _authSubscription = null;
    }
  }

  static const String _rememberedLoginKey = 'remembered_login';
  static const String redirectUrl = 'mono-wallet://auth-callback';
  static SharedPreferences? _sharedPreferences;
  StreamSubscription<AuthState>? _authSubscription;

  auth_ui.AuthAuthenticated _authenticatedState(User user) {
    return auth_ui.AuthAuthenticated(
      app_user.User(
        id: user.id,
        name: user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            user.email?.split('@').first ??
            'User',
        email: user.email ?? 'user@example.com',
      ),
    );
  }

  static Future<void> initialize() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _prefs async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<void> checkAuthStatus() async {
    await initialize();
    Session? session;
    try {
      session = Supabase.instance.client.auth.currentSession;
    } catch (_) {
      emit(const auth_ui.AuthInitial());
      return;
    }
    final isLoggedIn = session != null;

    if (isLoggedIn) {
      final user = session.user;
      final prefs = await _prefs;
      await prefs.setBool(_rememberedLoginKey, true);
      emit(_authenticatedState(user));
      return;
    }

    final prefs = await _prefs;
    await prefs.setBool(_rememberedLoginKey, false);
    emit(const auth_ui.AuthInitial());
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const auth_ui.AuthLoading());

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Unable to sign in. Please try again.');
      }

      final prefs = await _prefs;
      await prefs.setBool(_rememberedLoginKey, true);

      emit(_authenticatedState(user));
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  Future<void> requestPasswordReset(String email) async {
    emit(const auth_ui.AuthLoading());

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectUrl,
      );
      emit(
        const auth_ui.AuthInfo(
          'Password reset instructions were sent to your email.',
        ),
      );
    } on AuthApiException catch (error) {
      emit(auth_ui.AuthFailure(error.message));
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  Future<void> updatePassword(String password) async {
    emit(const auth_ui.AuthLoading());

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      await checkAuthStatus();
    } on AuthApiException catch (error) {
      emit(auth_ui.AuthFailure(error.message));
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  Future<void> signInWithProvider(OAuthProvider provider) async {
    emit(const auth_ui.AuthLoading());

    try {
      final launched = await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: redirectUrl,
        scopes: provider == OAuthProvider.apple ? 'name email' : null,
      );
      if (!launched) {
        emit(const auth_ui.AuthFailure('Could not open the sign-in provider.'));
      }
    } on AuthApiException catch (error) {
      emit(auth_ui.AuthFailure(error.message));
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(const auth_ui.AuthLoading());

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Unable to create account. Please try again.');
      }

      if (response.session == null) {
        emit(
          const auth_ui.AuthFailure(
            'Account created. Please confirm your email before signing in.',
          ),
        );
        return;
      }

      emit(
        auth_ui.AuthAuthenticated(
          app_user.User(
            id: user.id,
            name: fullName.trim().isNotEmpty ? fullName.trim() : 'User',
            email: user.email ?? email.trim(),
          ),
        ),
      );
    } on AuthApiException catch (error) {
      final message = error.code == 'over_email_send_rate_limit'
          ? 'Too many verification emails were requested. Please wait and try again later.'
          : error.message;
      emit(auth_ui.AuthFailure(message));
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      final prefs = await _prefs;
      await prefs.setBool(_rememberedLoginKey, false);
      emit(const auth_ui.AuthInitial());
    } catch (error) {
      emit(auth_ui.AuthFailure(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}