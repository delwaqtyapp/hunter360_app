import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:hunter360_app/core/constants/api_constants.dart';
import 'package:hunter360_app/core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiClient.post(
      ApiConstants.authenticate,
      data: {'username': username, 'userpassword': password},
    );
    if (response.data is String) {
      try {
        return Map<String, dynamic>.from(
          Map<String, dynamic>.from(response.data as Map),
        );
      } catch (_) {
        return {'Token': response.data};
      }
    }
    return Map<String, dynamic>.from(response.data);
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
