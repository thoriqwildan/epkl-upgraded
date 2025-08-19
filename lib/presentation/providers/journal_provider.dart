import 'package:epkl/data/models/journal.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier untuk mengelola state daftar jurnal
class JournalNotifier extends StateNotifier<AsyncValue<List<Journal>>> {
  final Ref _ref;

  JournalNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Langsung panggil fetchJournal saat notifier pertama kali dibuat
    fetchJournal();
  }

  Future<void> fetchJournal() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final authState = _ref.read(authNotifierProvider);
      final apiService = _ref.read(apiServiceProvider);

      final nisn = authState.maybeWhen(
        success: (user) => user.nisn,
        orElse: () => null,
      );

      if (nisn == null) {
        throw Exception("User not logged in");
      }

      final journalList = await apiService.getJournalList(nisn: nisn);
      state = AsyncValue.data(journalList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createJournal({
    required String kegiatan,
    required String target,
    required DateTime tanggal,
  }) async {
    try {
      final authState = _ref.read(authNotifierProvider);
      final apiService = _ref.read(apiServiceProvider);

      final nisn = authState.maybeWhen(
        success: (user) => user.nisn,
        orElse: () => null,
      );
      if (nisn == null) throw Exception("User not logged in");

      await apiService.createJournal(
        nisn: nisn,
        tanggal: tanggal, // Gunakan tanggal hari ini
        kegiatan: kegiatan,
        target: target,
      );

      await fetchJournal();
      return true; // Kembalikan true jika sukses
    } catch (e) {
      print('Gagal membuat jurnal: $e');
      return false; // Kembalikan false jika gagal
    }
  }
}

// Provider untuk JournalNotifier
final journalNotifierProvider =
    StateNotifierProvider.autoDispose<
      JournalNotifier,
      AsyncValue<List<Journal>>
    >((ref) {
      return JournalNotifier(ref);
    });
