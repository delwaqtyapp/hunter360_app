import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/errors/exceptions.dart';

final dioProvider = Provider<Dio>((ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final dio = Dio(BaseOptions(
    baseUrl: serverUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json, text/plain, */*',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authTokenProvider);
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      // Don't force Content-Type - let each request set it
      handler.next(options);
    },
    onResponse: (response, handler) {
      handler.next(response);
    },
    onError: (error, handler) {
      handler.next(error);
    },
  ));

  return dio;
});

final authTokenProvider = StateProvider<String>((ref) => '');
final serverUrlProvider = StateProvider<String>((ref) => AppConstants.defaultServerUrl);

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, String? contentType}) async {
    try {
      final options = contentType != null
          ? Options(contentType: contentType)
          : null;
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out: ${e.message}');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final body = e.response?.data;
        String msg = 'Server error ($statusCode)';
        if (body != null) {
          if (body is String) {
            msg = body;
          } else if (body is Map) {
            msg = body['message']?.toString() ?? body['error']?.toString() ?? msg;
          }
        }
        return ServerException(message: msg, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ServerException(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'Cannot connect to server. Check server URL and VPN connection.');
      default:
        return NetworkException(message: 'Network error: ${e.message}');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});
