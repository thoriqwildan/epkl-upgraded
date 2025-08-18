import 'package:epkl/data/services/api_service.dart';
import 'package:epkl/data/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(secureStorageProvider));
});
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SecureStorageService _storageService;

  AuthNotifier(this._apiService, this._storageService)
    : super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    final token = await _storageService.readToken();
    final nisn = await _storageService.readNisn();
    if (token == null || nisn == null) {
      state = const AuthState.initial();
      return;
    }

    try {
      state = const AuthState.loading();
      final profileResponse = await _apiService.getProfile(nisn: nisn);
      if (profileResponse.success) {
        state = AuthState.success(profileResponse.data);
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final loginResponse = await _apiService.login(email, password);
      if (loginResponse.success) {
        final token = loginResponse.data.token;
        final nisn = loginResponse.data.user.nisn;

        await _storageService.saveToken(token);
        await _storageService.saveNisn(nisn);

        state = AuthState.success(loginResponse.data.user);
      } else {
        state = AuthState.error(loginResponse.message);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteNisn();
    state = const AuthState.initial();
  }

  Future<bool> updateProfile({
    required String name,
    required int jurusanId,
    required int kelasId,
    required String phone,
  }) async {
    final currentState = state;

    // Gunakan maybeMap untuk menangani state 'success' secara aman
    return await currentState.maybeMap(
      // Jika state bukan 'success', lakukan 'orElse'
      orElse: () async => false,

      // Callback ini hanya akan berjalan jika state saat ini adalah 'success'
      success: (successState) async {
        try {
          final updatedUser = await _apiService.updateProfile(
            // Akses 'user' dan 'nisn' dari parameter 'successState'
            nisn: successState.user.nisn,
            name: name,
            jurusanId: jurusanId,
            kelasId: kelasId,
            phone: phone,
          );

          // Jika berhasil, perbarui state dengan data user yang baru
          state = AuthState.success(updatedUser);
          return true; // Kembalikan true untuk menandakan sukses
        } catch (e) {
          // Jika gagal, print error dan kembalikan false
          print('Update profile failed: $e');
          return false;
        }
      },
    );
  }
}
