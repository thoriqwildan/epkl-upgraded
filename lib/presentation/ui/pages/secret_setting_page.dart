import 'package:epkl/presentation/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecretSettingsPage extends ConsumerWidget {
  const SecretSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton state dari settingsNotifierProvider
    final isLocationCheckEnabled = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Rahasia')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Aktifkan Pengecekan Lokasi GPS'),
            subtitle: Text('Jika nonaktif, Anda bisa check-in dari mana saja.'),
            value: isLocationCheckEnabled,
            onChanged: (bool newValue) {
              // Panggil method di notifier untuk mengubah dan menyimpan setting
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setLocationCheckEnabled(newValue);
            },
          ),
        ],
      ),
    );
  }
}
