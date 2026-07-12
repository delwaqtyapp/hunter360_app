import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? token;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.token,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? error, String? token, bool clearError = false}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authJson = prefs.getString('AuthRepsonseSuccess');
      if (authJson != null && authJson.isNotEmpty) {
        final data = jsonDecode(authJson);
        final token = data['Token'] ?? '';
        if (token.isNotEmpty) {
          final user = User(
            id: data['UserName'] ?? '',
            name: data['UserName'] ?? '',
            email: data['UserName'] ?? '',
            role: (data['Roles'] as List<dynamic>?)?.first?.toString() ?? 'viewer',
            accessLevel: data['AccessLevel'] ?? 0,
            autoLogoutMinutes: data['AutoLogOutMin'] ?? 0,
          );
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            token: token,
          );
          return;
        }
      }
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final authData = await _repository.login(username, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('AuthRepsonseSuccess', jsonEncode(authData));

      final user = User(
        id: authData['UserName'] ?? username,
        name: authData['UserName'] ?? username,
        email: authData['UserName'] ?? username,
        role: (authData['Roles'] as List<dynamic>?)?.first?.toString() ?? 'operator',
        accessLevel: authData['AccessLevel'] ?? 0,
        autoLogoutMinutes: authData['AutoLogOutMin'] ?? 0,
        token: authData['Token'] ?? '',
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: authData['Token'] ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('AuthRepsonseSuccess');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
