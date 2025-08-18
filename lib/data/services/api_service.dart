// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:epkl/data/models/user_response.dart';
import '../models/login_response.dart';
import 'secure_storage_service.dart';

class ApiService {
  final Dio _dio;

  ApiService(SecureStorageService storageService)
    : _dio = Dio(BaseOptions(baseUrl: 'http://epkl.smk2-yk.sch.id/api')) {
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('Request Headers: ${options.headers}');
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await storageService.deleteToken();
          }
          return handler.next(e);
        },
      ),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login/siswa',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to login: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  Future<ProfileResponse> getProfile({required String nisn}) async {
    try {
      final response = await _dio.get(
        '/siswa/profile',
        queryParameters: {'nisn': nisn},
      );
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to get profile: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}
