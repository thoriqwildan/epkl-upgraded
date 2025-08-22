// lib/presentation/ui/pages/home_page.dart

// ignore_for_file: deprecated_member_use

import 'package:epkl/data/services/location_service.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/attendance_status_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/providers/info_provider.dart';
import 'package:epkl/presentation/providers/setting_provider.dart';
import 'package:epkl/presentation/ui/widgets/info_card.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isOffSite = false;
  bool _isSubmitting = false;
  double? _currentDistance;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCheckingDistance = false;
  bool isButtonDisabled = false;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isOffSite) {
        _updateDistance();
      }
    });
  }

  Future<void> _updateDistance() async {
    setState(() {
      _isCheckingDistance = true;
      _currentDistance = null;
    });

    try {
      final user = ref
          .read(authNotifierProvider)
          .maybeWhen(success: (data) => data, orElse: () => null);
      if (user == null) throw Exception('Gagal mendapatkan data user.');

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

      if (mounted) {
        setState(() {
          _currentDistance = distance;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, message: e.toString(), isError: true);
        setState(() {
          _currentDistance = double.infinity;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingDistance = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(attendanceStatusProvider.notifier).fetchStatus();
    }
  }

  Future<void> refreshAttendance() async {
    ref.read(attendanceStatusProvider.notifier).fetchStatus();
    _updateDistance();
  }

  Future<void> _handleAttendanceAction({required bool isCheckingIn}) async {
    if (_isOffSite && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isGpsCheckDisabledBySecretSetting = ref
          .read(settingsNotifierProvider)
          .isLocationCheckDisabled;

      if (!isGpsCheckDisabledBySecretSetting && !_isOffSite) {
        if (_currentDistance == null) {
          throw Exception(
            'Sedang mengambil data lokasi, silakan coba sesaat lagi.',
          );
        }
        if (_currentDistance! > 100) {
          throw Exception(
            'Anda berada di luar jangkauan (${_currentDistance!.toStringAsFixed(0)}m).',
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

      setState(() {
        _isOffSite = false;
        _descriptionController.clear();
        _currentDistance = null;
      });
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
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: authState.when(
          success: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(),
          error: (e) => const Text('E-PKL'),
          initial: () => const Text('E-PKL'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshAttendance(),
        child: statusState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Gagal memuat status: $err')),
          data: (status) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAttendanceCard(context, status, authState),
                    const SizedBox(height: 24),

                    _buildInfoSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    dynamic status,
    AuthState authState,
  ) {
    bool isButtonDisabled =
        _isSubmitting ||
        _isCheckingDistance ||
        (_currentDistance != null && _currentDistance! > 100 && !_isOffSite);

    final appSettings = ref.watch(settingsNotifierProvider);
    if (appSettings.isLocationCheckDisabled) {
      isButtonDisabled = _isSubmitting;
    }

    String subtitleText;
    if (appSettings.isLocationCheckDisabled) {
      subtitleText = 'Pengecekan lokasi dinonaktifkan';
    } else if (_isCheckingDistance) {
      subtitleText = 'Mengecek jarak...';
    } else if (_currentDistance != null) {
      subtitleText =
          '${_currentDistance!.toStringAsFixed(0)} meter dari lokasi';
    } else if (_isOffSite) {
      subtitleText = 'Mode izin aktif';
    } else {
      subtitleText = '...';
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            authState.when(
              success: (user) => ListTile(
                leading: Icon(
                  appSettings.isLocationCheckDisabled
                      ? Icons.location_off_outlined
                      : Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Status Lokasi'),
                subtitle: Text(
                  subtitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              loading: () => const ListTile(title: Text("Memuat lokasi ...")),
              error: (_) => const ListTile(title: Text("Gagal memuat lokasi")),
              initial: () => const SizedBox(),
            ),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: isButtonDisabled
                  ? const AlwaysStoppedAnimation(1)
                  : _animation,
              child: _buildMainAttendanceButton(status, isButtonDisabled),
            ),
            const SizedBox(height: 24),
            if (!status.hasCheckedIn ||
                (status.hasCheckedIn && !status.hasCheckedOut))
              _buildOffSiteSwitchAndDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAttendanceButton(dynamic status, bool isDisabled) {
    Widget buttonContent;
    VoidCallback? onPressed;
    Color buttonColor;
    final theme = Theme.of(context);

    if (!status.hasCheckedIn) {
      buttonColor = theme.colorScheme.primary;
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
      buttonColor = theme.colorScheme.error;
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
      buttonColor = Colors.green.shade600;
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
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(color: theme.colorScheme.onPrimary)
            : buttonContent,
      ),
    );
  }

  Widget _buildOffSiteSwitchAndDescription() {
    return Column(
      children: [
        _buildAttendanceModeToggle(),
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
      ],
    );
  }

  Widget _buildAttendanceModeToggle() {
    final theme = Theme.of(context);

    final isGpsCheckDisabledBySecretSetting = ref
        .watch(settingsNotifierProvider)
        .isLocationCheckDisabled;
    if (isGpsCheckDisabledBySecretSetting) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ToggleButtons(
        isSelected: [_isOffSite == false, _isOffSite == true],
        onPressed: (int index) {
          final bool isNowOffSite = index == 1;
          setState(() {
            _isOffSite = isNowOffSite;
          });

          if (!isNowOffSite) {
            _updateDistance();
          } else {
            setState(() {
              _currentDistance = null;
            });
          }
        },
        // Styling
        borderRadius: BorderRadius.circular(10.0),
        selectedColor: theme.colorScheme.onPrimary,
        color: theme.colorScheme.onSurfaceVariant,
        fillColor: theme.colorScheme.primary,
        renderBorder: false,
        constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth: (MediaQuery.of(context).size.width - 100) / 2,
        ),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 24),
                SizedBox(width: 8),
                Text('Di Lokasi'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, size: 24),
                SizedBox(width: 8),
                Text('Izin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final infoListState = ref.watch(infoListProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Terbaru',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            infoListState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text('Gagal memuat info')),
              data: (infoList) {
                if (infoList.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada informasi saat ini.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: infoList.length,
                  itemBuilder: (context, index) {
                    final info = infoList[index];
                    return InfoCard(info: info);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
