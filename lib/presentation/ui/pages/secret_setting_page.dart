import 'package:epkl/presentation/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretSettingsPage extends ConsumerWidget {
  const SecretSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sekarang state-nya adalah objek AppSettings
    final appSettings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Rahasia')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SwitchListTile(
            title: const Text('Nonaktifkan Pengecekan Lokasi GPS'),
            subtitle: const Text(
              'Memungkinkan check-in & check-out dari mana saja.',
            ),
            value: appSettings.isLocationCheckDisabled,
            onChanged: (bool newValue) {
              notifier.setLocationCheckEnabled(newValue);
            },
          ),
          const Divider(),
          // --- SWITCH BARU UNTUK MANIPULASI TANGGAL ---
          SwitchListTile(
            title: const Text('Aktifkan Manipulasi Tanggal Jurnal'),
            subtitle: const Text(
              'Menampilkan pilihan tanggal di halaman tambah jurnal.',
            ),
            value: appSettings.isDateManipulationEnabled,
            onChanged: (bool newValue) {
              notifier.setDateManipulationEnabled(newValue);
            },
          ),
        ],
      ),
    );
  }
}
