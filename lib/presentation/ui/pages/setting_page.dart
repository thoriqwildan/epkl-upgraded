import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/ui/pages/about_page.dart'; // Akan kita buat
import 'package:epkl/presentation/ui/pages/login_page.dart';
import 'package:epkl/presentation/ui/pages/theme_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  // Ubah menjadi ConsumerWidget
  const SettingsPage({super.key});

  // Fungsi untuk menampilkan dialog konfirmasi
  Future<void> _showLogoutConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(false); // Tutup dialog, kembalikan false
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // Tutup dialog, kembalikan true
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // Jika user menekan "Logout" (dialog mengembalikan true)
    if (confirmLogout == true) {
      // Panggil fungsi logout dari notifier
      await ref.read(authNotifierProvider.notifier).logout();
      // Navigasi ke halaman login dan hapus semua halaman sebelumnya
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Pilih Tema'),
            subtitle: const Text('Ubah tampilan warna aplikasi.'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Informasi pengembang aplikasi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Panggil fungsi untuk menampilkan dialog
              _showLogoutConfirmationDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }
}
