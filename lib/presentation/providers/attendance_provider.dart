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

  AttendanceNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> fetchAttendance(DateFilter filter) async {
    state = const AsyncValue.loading();
    try {
      final authState = _ref.read(authNotifierProvider);
      final apiService = _ref.read(apiServiceProvider);

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
      state = AsyncValue.data(attendanceList);
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
