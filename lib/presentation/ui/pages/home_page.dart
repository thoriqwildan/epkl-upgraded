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

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  bool _isOffSite = false;
  bool _isSubmitting = false;
  double? _currentDistance;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(attendanceStatusProvider.notifier).fetchStatus();
    }
  }

  // LOGIKA DISATUKAN MENJADI SATU FUNGSI
  Future<void> _handleAttendanceAction({required bool isCheckingIn}) async {
    if (_isOffSite && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref
          .read(authNotifierProvider)
          .maybeWhen(success: (data) => data, orElse: () => null);
      if (user == null) throw Exception('Gagal mendapatkan data user.');

      final isLocationCheckEnabled = ref.read(settingsNotifierProvider);

      if (isLocationCheckEnabled && !_isOffSite) {
        final pklLat = double.tryParse(user.lat ?? '0.0')!;
        final pklLng = double.tryParse(user.longitude ?? '0.0')!;

        final locationService = LocationService();
        final currentPosition = await locationService.getCurrentPosition();
        final distance = locationService.calculateDistanceInMeters(
          currentPosition.latitude,
          currentPosition.longitude,
          pklLat,
          pklLng,
        );
        if (mounted) setState(() => _currentDistance = distance);

        if (distance > 100) {
          throw Exception(
            'Anda berada di luar jangkauan (${distance.toStringAsFixed(0)}m).',
          );
        }
      }

      final notifier = ref.read(attendanceStatusProvider.notifier);
      final description = _isOffSite ? _descriptionController.text : null;
      String successMessage;

      if (isCheckingIn) {
        await notifier.checkIn(description: description);
        successMessage = 'Berhasil Check In!';
      } else {
        await notifier.checkOut(description: description);
        successMessage = 'Berhasil Check Out!';
      }

      if (mounted) showAppSnackBar(context, message: successMessage);
    } catch (e) {
      if (mounted)
        showAppSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(attendanceStatusProvider);
    final authState = ref.watch(authNotifierProvider);
    bool isButtonDisabled =
        _isSubmitting ||
        (_currentDistance != null && _currentDistance! > 100 && !_isOffSite);

    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                      if (!status.hasCheckedIn) ...[
                        ElevatedButton(
                          onPressed: isButtonDisabled
                              ? null
                              : () =>
                                    _handleAttendanceAction(isCheckingIn: true),
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
                        _buildOffSiteSwitchAndDescription(),
                      ] else if (status.hasCheckedIn &&
                          !status.hasCheckedOut) ...[
                        const Text(
                          'Anda sudah check in pada pukul:',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          status.attendanceData!.checkInTime,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isButtonDisabled
                              ? null
                              : () => _handleAttendanceAction(
                                  isCheckingIn: false,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
                        const SizedBox(height: 24),
                        _buildOffSiteSwitchAndDescription(),
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

  Widget _buildOffSiteSwitchAndDescription() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Saya tidak berada di lokasi (Izin)'),
          value: _isOffSite,
          onChanged: (value) => setState(() {
            _isOffSite = value;
            _currentDistance = null; // Reset info jarak saat switch diubah
          }),
        ),
        if (_isOffSite) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Alasan / Deskripsi Kegiatan',
              border: OutlineInputBorder(),
              hintText: 'Contoh: Sedang WFH karena ada acara keluarga',
            ),
            maxLines: 3,
            validator: (value) {
              if (_isOffSite && (value == null || value.isEmpty)) {
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
              color: _currentDistance! > 100 ? Colors.red : Colors.green,
            ),
          ),
      ],
    );
  }
}
