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
    // Try the legacy endpoint first (matches desktop login.js exactly)
    try {
      final response = await _apiClient.post(
        ApiConstants.authenticate,
        data: {'username': username, 'userpassword': password},
        contentType: 'application/x-www-form-urlencoded',
      );

      final raw = response.data;
      if (raw is String && raw.isNotEmpty) {
        // Response is a plain text string (JWT or JSON string)
        return _parseAuthResponse(raw);
      }
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      if (raw is List) {
        // Some servers return the auth data as a list with one element
        if (raw.isNotEmpty && raw.first is Map) {
          return Map<String, dynamic>.from(raw.first);
        }
      }
      return {'Token': raw?.toString() ?? ''};
    } catch (e) {
      // Try the new endpoint
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
    // Try parsing as JSON
    try {
      final parsed = Map<String, dynamic>.from(
        Map<String, dynamic>.from(_simpleJsonDecode(raw)),
      );
      // Check if it has the expected auth fields
      if (parsed.containsKey('Token') ||
          parsed.containsKey('UserName') ||
          parsed.containsKey('Roles') ||
          parsed.containsKey('AccessLevel')) {
        return parsed;
      }
    } catch (_) {}

    // Check if it's a bare JWT token
    final jwtRegex = RegExp(r'^eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+$');
    if (jwtRegex.hasMatch(raw.trim())) {
      return {'Token': raw.trim()};
    }

    // Return as-is
    return {'Token': raw};
  }

  dynamic _simpleJsonDecode(String s) {
    var trimmed = s.trim();
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      trimmed = trimmed.substring(1, trimmed.length - 1);
    }
    try {
      final decoded = jsonDecode(trimmed);
      return decoded;
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
