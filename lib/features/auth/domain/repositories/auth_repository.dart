abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> getCurrentUser();
}
