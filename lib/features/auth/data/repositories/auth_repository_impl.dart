import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Try legacy endpoint first (matches desktop login.js exactly - sends JSON.stringify body)
    try {
      final response = await _apiClient.post(
        ApiConstants.authenticate,
        data: jsonEncode({'username': username, 'userpassword': password}),
      );

      final raw = response.data;
      if (raw is String && raw.isNotEmpty) {
        return _parseAuthResponse(raw);
      }
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      if (raw is List) {
        if (raw.isNotEmpty && raw.first is Map) {
          return Map<String, dynamic>.from(raw.first);
        }
      }
      return {'Token': raw?.toString() ?? ''};
    } catch (e) {
      // Try the newer endpoint
      try {
        final response = await _apiClient.post(
          '/api/Authenticate',
          data: {'UserName': username, 'UserPassword': password},
          contentType: 'application/json',
        );
        final raw = response.data;
        if (raw is String && raw.isNotEmpty) {
          return _parseAuthResponse(raw);
        }
        if (raw is Map) {
          return Map<String, dynamic>.from(raw);
        }
        return {'Token': raw?.toString() ?? ''};
      } catch (_) {
        rethrow;
      }
    }
  }

  Map<String, dynamic> _parseAuthResponse(String raw) {
    try {
      final parsed = Map<String, dynamic>.from(_simpleJsonDecode(raw));
      if (parsed.containsKey('Token') ||
          parsed.containsKey('UserName') ||
          parsed.containsKey('Roles') ||
          parsed.containsKey('AccessLevel')) {
        return parsed;
      }
    } catch (_) {}

    final jwtRegex = RegExp(r'^eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+$');
    if (jwtRegex.hasMatch(raw.trim())) {
      return {'Token': raw.trim()};
    }

    return {'Token': raw};
  }

  dynamic _simpleJsonDecode(String s) {
    var trimmed = s.trim();
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      trimmed = trimmed.substring(1, trimmed.length - 1);
    }
    try {
      return jsonDecode(trimmed);
    } catch (_) {}
    return trimmed;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    return {};
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(apiClientProvider));
});
