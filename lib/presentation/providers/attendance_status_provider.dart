// lib/presentation/providers/attendance_status_provider.dart

import 'package:epkl/data/models/attendance_status.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceStatusNotifier
    extends StateNotifier<AsyncValue<AttendanceStatus>> {
  final Ref _ref;

  AttendanceStatusNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    state = const AsyncValue.loading();
    try {
      final authState = _ref.read(authNotifierProvider);
      final apiService = _ref.read(apiServiceProvider);

      final nisn = authState.maybeWhen(
        success: (user) => user.nisn,
        orElse: () => null,
      );

      if (nisn == null) {
        if (mounted) {
          state = AsyncValue.data(
            AttendanceStatus(hasCheckedIn: false, hasCheckedOut: false),
          );
        }
        return;
      }

      final status = await apiService.getTodayAttendanceStatus(nisn: nisn);
      if (mounted) {
        state = AsyncValue.data(status);
      }
    } catch (e, st) {
      print('ERROR in fetchStatus: $e');
      print('STACK TRACE: $st');
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> checkIn({String? description}) async {
    final authState = _ref.read(authNotifierProvider);
    final apiService = _ref.read(apiServiceProvider);

    final nisn = authState.maybeWhen(
      success: (user) => user.nisn,
      orElse: () => null,
    );
    if (nisn == null) throw Exception("User not found");

    await apiService.checkIn(
      nisn: nisn,
      date: DateTime.now(),
      description: description,
    );

    await fetchStatus();
  }

  Future<void> checkOut({String? description}) async {
    final authState = _ref.read(authNotifierProvider);
    final apiService = _ref.read(apiServiceProvider);

    final nisn = authState.maybeWhen(
      success: (user) => user.nisn,
      orElse: () => null,
    );
    if (nisn == null) throw Exception("User not found");

    await apiService.checkOut(
      nisn: nisn,
      date: DateTime.now(),
      description: description,
    );

    // Setelah berhasil, panggil ulang fetchStatus untuk update UI
    await fetchStatus();
  }
}

final attendanceStatusProvider =
    StateNotifierProvider<
      AttendanceStatusNotifier,
      AsyncValue<AttendanceStatus>
    >((ref) {
      return AttendanceStatusNotifier(ref);
    });
