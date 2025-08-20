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

// Tambahkan 'TickerProviderStateMixin' untuk bisa menjalankan animasi
class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // State untuk UI lokal
  bool _isOffSite = false;
  bool _isSubmitting = false;
  double? _currentDistance;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variabel baru untuk controller animasi
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi controller animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Animasi akan berulang (maju-mundur)

    // Definisikan animasi (memperbesar dan memperkecil antara 100% dan 105%)
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _descriptionController.dispose();
    _animationController.dispose(); // Jangan lupa dispose controller animasi
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(attendanceStatusProvider.notifier).fetchStatus();
    }
  }

  // Logika untuk check-in dan check-out (tidak ada perubahan dari versi sebelumnya)
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

      final appSettings = ref.read(settingsNotifierProvider);

      if (!appSettings.isLocationCheckDisabled && !_isOffSite) {
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
      if (mounted) {
        showAppSnackBar(context, message: e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(attendanceStatusProvider);
    // final authState = ref.watch(authNotifierProvider);
    bool isButtonDisabled =
        _isSubmitting ||
        (_currentDistance != null && _currentDistance! > 100 && !_isOffSite);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const FlutterLogo(),
            const SizedBox(width: 12),
            const Text('E-PKL Remastered'),
          ],
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
                  minHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TOMBOL MELINGKAR DENGAN ANIMASI
                      ScaleTransition(
                        scale: _animation,
                        child: _buildMainAttendanceButton(
                          status,
                          isButtonDisabled,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Tampilkan switch & deskripsi jika absensi belum selesai
                      if (!status.hasCheckedIn ||
                          (status.hasCheckedIn && !status.hasCheckedOut))
                        _buildOffSiteSwitchAndDescription(),
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

  // Widget helper untuk membangun tombol utama
  Widget _buildMainAttendanceButton(dynamic status, bool isDisabled) {
    Widget buttonContent;
    VoidCallback? onPressed;
    Color buttonColor = Theme.of(context).primaryColor;

    if (!status.hasCheckedIn) {
      buttonContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 48),
          SizedBox(height: 8),
          Text(
            'CHECK IN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
      onPressed = isDisabled
          ? null
          : () => _handleAttendanceAction(isCheckingIn: true);
    } else if (status.hasCheckedIn && !status.hasCheckedOut) {
      buttonColor = Colors.redAccent;
      buttonContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sudah Check In:'),
          Text(
            status.attendanceData!.checkInTime,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(
            color: Colors.white54,
            height: 24,
            indent: 30,
            endIndent: 30,
          ),
          const Text(
            'CHECK OUT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
      onPressed = isDisabled
          ? null
          : () => _handleAttendanceAction(isCheckingIn: false);
    } else {
      _animationController.stop();
      buttonColor = Colors.green;
      buttonContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.white),
          SizedBox(height: 8),
          Text(
            'SELESAI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
      onPressed = null;
    }

    return SizedBox(
      width: 220,
      height: 220,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : buttonContent,
      ),
    );
  }

  // Widget helper untuk switch dan deskripsi (tidak berubah)
  Widget _buildOffSiteSwitchAndDescription() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Saya tidak berada di lokasi (Izin)'),
          value: _isOffSite,
          onChanged: (value) => setState(() {
            _isOffSite = value;
            _currentDistance = null;
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
