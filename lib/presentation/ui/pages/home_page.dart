// lib/presentation/ui/pages/home_page.dart

import 'package:epkl/data/services/location_service.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/attendance_status_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/providers/setting_provider.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOffSite = false;
  bool _isSubmitting = false;
  double? _currentDistance;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    if (_isOffSite && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // --- PERBAIKAN UTAMA ADA DI SINI ---
      final user = ref
          .read(authNotifierProvider)
          .maybeWhen(success: (userData) => userData, orElse: () => null);
      if (user == null) {
        throw Exception('Gagal mendapatkan data user. Silakan coba lagi.');
      }
      // ------------------------------------

      final isLocationCheckEnabled = ref.read(settingsNotifierProvider);

      if (isLocationCheckEnabled && !_isOffSite) {
        final pklLat = double.tryParse(user.lat ?? '0.0');
        final pklLng = double.tryParse(user.longitude ?? '0.0');

        if (pklLat == null || pklLng == null) {
          throw Exception('Lokasi PKL tidak valid di profil Anda.');
        }

        final locationService = LocationService();
        final currentPosition = await locationService.getCurrentPosition();
        final distance = locationService.calculateDistanceInMeters(
          currentPosition.latitude,
          currentPosition.longitude,
          pklLat,
          pklLng,
        );

        // Update jarak di UI secara real-time sebelum check-in
        if (mounted) setState(() => _currentDistance = distance);

        if (distance > 100) {
          throw Exception(
            'Anda berada di luar jangkauan (${distance.toStringAsFixed(0)}m).',
          );
        }
      }

      await ref
          .read(attendanceStatusProvider.notifier)
          .checkIn(
            description: _isOffSite ? _descriptionController.text : null,
          );

      if (mounted) showAppSnackBar(context, message: 'Berhasil Check In!');
    } catch (e) {
      if (mounted)
        showAppSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleCheckOut() async {
    // TODO: Implementasi logika Check Out
    print("LOGIC CHECK OUT DI SINI");
    showAppSnackBar(
      context,
      message: 'Fitur Check Out belum diimplementasikan',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(attendanceStatusProvider);
    final authState = ref.watch(authNotifierProvider);

    // Tentukan apakah tombol harus dinonaktifkan
    bool isButtonDisabled =
        _isSubmitting ||
        (_currentDistance != null && _currentDistance! > 100 && !_isOffSite);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Gunakan pola yang aman juga di sini
          authState.maybeWhen(
            success: (user) => 'Hai, ${user.name.split(' ').first}',
            orElse: () => 'Dashboard Absensi',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(attendanceStatusProvider.notifier).fetchStatus(),
        child: Center(
          child: statusState.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Gagal memuat status: $err'),
            data: (status) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- UI UTAMA BERDASARKAN STATUS ---
                      if (!status.hasCheckedIn) ...[
                        ElevatedButton(
                          onPressed: isButtonDisabled ? null : _handleCheckIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Check In Sekarang',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text(
                            'Saya tidak berada di lokasi (Izin)',
                          ),
                          value: _isOffSite,
                          onChanged: (value) =>
                              setState(() => _isOffSite = value),
                        ),
                        if (_isOffSite) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Alasan / Deskripsi Kegiatan',
                              border: OutlineInputBorder(),
                              hintText:
                                  'Contoh: Sedang WFH karena ada acara keluarga',
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (_isOffSite &&
                                  (value == null || value.isEmpty)) {
                                return 'Alasan tidak boleh kosong jika tidak di lokasi';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (!_isOffSite && _currentDistance != null)
                          Text(
                            'Jarak Anda dari lokasi: ${_currentDistance!.toStringAsFixed(0)} meter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _currentDistance! > 100
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                      ] else if (status.hasCheckedIn &&
                          !status.hasCheckedOut) ...[
                        const Text('Anda sudah check in pada pukul:'),
                        Text(
                          status.attendanceData!.checkInTime,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleCheckOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Check Out Sekarang',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Absensi hari ini telah selesai.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Check In: ${status.attendanceData!.checkInTime}'),
                        Text(
                          'Check Out: ${status.attendanceData!.checkOutTime}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
