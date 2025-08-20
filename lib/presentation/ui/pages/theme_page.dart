// lib/presentation/ui/pages/theme_page.dart

import 'package:epkl/core/theme/app_theme.dart';
import 'package:epkl/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dapatkan tema yang sedang aktif
    final activeTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Tema')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        // Ambil jumlah tema dari list global kita
        itemCount: appThemes.length,
        itemBuilder: (context, index) {
          final theme = appThemes[index];
          final bool isSelected = theme.name == activeTheme.name;

          return Card(
            child: ListTile(
              title: Text(theme.name),
              onTap: () {
                // Panggil notifier untuk mengubah tema
                ref.read(themeNotifierProvider.notifier).setTheme(theme.name);
              },
              // Tampilkan ikon centang jika tema ini sedang aktif
              trailing: isSelected ? const Icon(Icons.check_circle) : null,
            ),
          );
        },
      ),
    );
  }
}
