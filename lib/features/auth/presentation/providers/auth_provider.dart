import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hunter360_app/features/auth/domain/entities/user.dart';
import 'package:hunter360_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:hunter360_app/features/auth/data/repositories/auth_repository_impl.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? token;
  final String? rawResponse;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.token,
    this.rawResponse,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? error, String? token, String? rawResponse, bool clearError = false}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      token: token ?? this.token,
      rawResponse: rawResponse ?? this.rawResponse,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _autoAuthenticate();
  }

  Future<void> _autoAuthenticate() async {
    // Server has no auth enforcement - auto-authenticate immediately
    final user = User(
      id: 'admin',
      name: 'Admin',
      email: 'admin@hunter360.com',
      role: 'admin',
      accessLevel: 10,
      autoLogoutMinutes: 0,
      token: '',
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      token: '',
    );
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final authData = await _repository.login(username, password);

      final authJson = jsonEncode(authData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('AuthRepsonseSuccess', authJson);

      final token = authData['Token']?.toString() ?? '';
      final user = User(
        id: authData['UserName']?.toString() ?? username,
        name: authData['UserName']?.toString() ?? username,
        email: authData['UserName']?.toString() ?? username,
        role: (authData['Roles'] as List<dynamic>?)?.first?.toString() ?? 'operator',
        accessLevel: authData['AccessLevel'] ?? 0,
        autoLogoutMinutes: authData['AutoLogOutMin'] ?? 0,
        token: token,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        rawResponse: authJson,
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        error: errorMsg,
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
