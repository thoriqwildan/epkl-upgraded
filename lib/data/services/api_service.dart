import 'dart:io';

import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:epkl/data/models/attendance.dart';
import 'package:epkl/data/models/attendance_status.dart';
import 'package:epkl/data/models/info_detail.dart';
import 'package:epkl/data/models/info_list_response.dart';
import 'package:epkl/data/models/journal.dart';
import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/data/models/kelas.dart';
import 'package:epkl/data/models/register_request.dart';
import 'package:epkl/data/models/user_response.dart';
import 'package:intl/intl.dart';
import '../models/login_response.dart';
import 'secure_storage_service.dart';

class ApiService {
  final Dio _dio;

  ApiService(SecureStorageService storageService)
    // --- SOLUSI: TAMBAHKAN TIMEOUT ---
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://epkl.smk2-yk.sch.id/api',
          // Set timeout ke 15 detik (atau sesuai kebutuhan)
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Ini adalah HttpClient standar dari dart:io
        final client = HttpClient();
        // Karena kita pakai HTTP, callback sertifikat ini tidak akan dipanggil
        // tapi ini adalah praktik standar saat membuat HttpClient kustom.
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

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

  Future<User> register({required RegisterRequest request}) async {
    try {
      final response = await _dio.post(
        '/siswa/register',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Gagal melakukan registrasi.',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Terjadi kesalahan jaringan.';
      throw Exception(errorMessage);
    }
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

  Future<List<Jurusan>> getJurusanList() async {
    try {
      final response = await _dio.get('/jurusan');
      final List<dynamic> listData = response.data['data'];
      return listData.map((json) => Jurusan.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get jurusan list: ${e.message}');
    }
  }

  Future<List<Kelas>> getKelasList() async {
    try {
      final response = await _dio.get('/kelas');
      // Ambil list dari key 'data' dan ubah menjadi List<Kelas>
      final List<dynamic> listData = response.data['data'];
      return listData.map((json) => Kelas.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get kelas list: ${e.message}');
    }
  }

  Future<User> updateProfile({
    required String nisn,
    required String name,
    required int jurusanId,
    required int kelasId,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '/siswa/profile',
        data: {
          'nisn': nisn,
          'name': name,
          'm_jurusan_id': jurusanId.toString(),
          'm_kelas_id': kelasId.toString(),
          'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Gagal update profil: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<User> updateAvatar({
    required String nisn,
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'nisn': nisn,
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post('/siswa/profile/avatar', data: formData);

      if (response.data['success'] == true) {
        // Asumsi API avatar juga mengembalikan data user terbaru
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Gagal update avatar: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Error upload avatar: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  Future<List<Attendance>> getAttendanceList({
    required String nisn,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    try {
      // Format DateTime ke String 'yyyy-MM-dd'
      final formatter = DateFormat('yyyy-MM-dd');
      final response = await _dio.get(
        '/attendance/list',
        queryParameters: {
          'nisn': nisn,
          'date_start': formatter.format(dateStart),
          'date_end': formatter.format(dateEnd),
        },
      );
      print('Attendance response: ${response.data}');
      final List<dynamic> listData = response.data['data'];
      return listData.map((json) => Attendance.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get attendance list: ${e.message}');
    }
  }

  Future<List<Journal>> getJournalList({required String nisn}) async {
    try {
      final response = await _dio.get(
        '/journal',
        queryParameters: {'nisn': nisn},
      );
      final List<dynamic> listData = response.data['data'];
      return listData.map((json) => Journal.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get journal list: ${e.message}');
    }
  }

  Future<Journal> createJournal({
    required String nisn,
    required DateTime tanggal,
    required String kegiatan,
    required String target,
  }) async {
    try {
      // Format tanggal ke 'yyyy-MM-dd'
      final formattedDate = DateFormat('yyyy-MM-dd').format(tanggal);
      final response = await _dio.post(
        '/journal',
        data: {
          'nisn': nisn,
          'tanggal': formattedDate,
          'kegiatan': kegiatan,
          'target': target,
        },
      );

      if (response.data['success'] == true) {
        // Jika sukses, API mengembalikan data jurnal yang baru dibuat
        return Journal.fromJson(response.data['data']);
      } else {
        throw Exception('Gagal membuat jurnal: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<AttendanceStatus> getTodayAttendanceStatus({
    required String nisn,
  }) async {
    try {
      final response = await _dio.get(
        '/attendance',
        queryParameters: {'nisn': nisn},
      );
      return AttendanceStatus.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data['success'] == false) {
        return AttendanceStatus.fromJson(
          e.response?.data ?? {'success': false},
        );
      }
      throw Exception('Failed to get today\'s attendance status: ${e.message}');
    }
  }

  Future<Attendance> checkIn({
    required String nisn,
    required DateTime date,
    String? description,
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _dio.post(
        '/attendance/check-in',
        data: {'nisn': nisn, 'date': formattedDate, 'description': description},
      );

      if (response.data['success'] == true) {
        // API mengembalikan data absensi yang baru dibuat
        return Attendance.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Gagal melakukan check-in: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<Attendance> checkOut({
    required String nisn,
    required DateTime date,
    String? description,
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      // Asumsi methodnya POST, sesuaikan jika berbeda (misal: PUT atau PATCH)
      final response = await _dio.post(
        '/attendance/check-out',
        data: {'nisn': nisn, 'date': formattedDate, 'description': description},
      );

      if (response.data['success'] == true) {
        // API mengembalikan data absensi yang sudah ter-update
        return Attendance.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Gagal melakukan check-out: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<InfoListResponse> getInfoList({int limit = 5, int page = 1}) async {
    try {
      final response = await _dio.get(
        '/info',
        queryParameters: {'limit': limit, 'page': page},
      );
      return InfoListResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get info list: ${e.message}');
    }
  }

  // FUNGSI BARU UNTUK MENGAMBIL DETAIL INFO
  Future<InfoDetail> getInfoDetail({required int id}) async {
    try {
      final response = await _dio.get('/info', queryParameters: {'id': id});
      return InfoDetail.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to get info detail: ${e.message}');
    }
  }
}
