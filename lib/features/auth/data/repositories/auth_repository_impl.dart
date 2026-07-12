import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      return Right(User.fromJson(response.data['user']));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return Right(User.fromJson(response.data['user']));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/v1/user/profile');
      return Right(User.fromJson(response.data['user']));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _apiClient.post('/api/v1/auth/forgot-password', data: {'email': email});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
