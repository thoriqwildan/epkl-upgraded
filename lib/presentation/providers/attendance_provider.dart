// lib/presentation/providers/attendance_provider.dart

import 'package:epkl/data/models/attendance.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Definisikan state untuk filter tanggal
class DateFilter {
  final DateTime start;
  final DateTime end;
  DateFilter({required this.start, required this.end});
}

// 2. Buat Notifier
class AttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final Ref _ref;

  AttendanceNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Listener ini tetap berguna untuk mereset state jika user logout.
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () {
          state = const AsyncValue.data([]);
        },
      );
    });

    // --- AWAL DARI SOLUSI ---
    // Langsung periksa state otentikasi saat ini, jangan hanya menunggu perubahan.
    final currentAuthState = _ref.read(authNotifierProvider);
    currentAuthState.maybeWhen(
      success: (user) {
        // Jika user sudah login, langsung panggil fetch data dengan filter default.
        print(
          'Auth state is already success, fetching initial attendance list...',
        );
        final now = DateTime.now();
        fetchAttendance(
          DateFilter(start: DateTime(now.year, now.month, 1), end: now),
        );
      },
      orElse: () {
        // Jika karena suatu alasan user tidak login, set state ke data kosong.
        state = const AsyncValue.data([]);
      },
    );
    // --- AKHIR DARI SOLUSI ---
  }

  Future<void> fetchAttendance(DateFilter filter) async {
    state = const AsyncValue.loading();
    try {
      final authState = _ref.read(authNotifierProvider);
      final apiService = _ref.read(apiServiceProvider);

      print('Fetching attendance from ${filter.start} to ${filter.end}');

      // Ambil NISN dari auth state
      final nisn = authState.maybeWhen(
        success: (user) => user.nisn,
        orElse: () => null,
      );

      if (nisn == null) {
        throw Exception("User not logged in");
      }

      final attendanceList = await apiService.getAttendanceList(
        nisn: nisn,
        dateStart: filter.start,
        dateEnd: filter.end,
      );

      final reversedList = attendanceList.reversed.toList();
      state = AsyncValue.data(reversedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 3. Buat Provider
final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<List<Attendance>>>((
      ref,
    ) {
      return AttendanceNotifier(ref);
    });
