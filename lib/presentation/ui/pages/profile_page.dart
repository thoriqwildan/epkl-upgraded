// lib/presentation/ui/pages/profile_page.dart

import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          // Pindahkan tombol logout ke sini
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              // Arahkan kembali ke halaman login setelah logout
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(child: Text('Gagal memuat data: $message')),
        // Hanya tampilkan UI jika state adalah success
        success: (user) {
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user.avatar == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              // Tampilkan data yang relevan untuk di-update
              ProfileInfoTile(
                icon: Icons.badge_outlined,
                label: 'NISN',
                value: user.nisn,
              ),
              ProfileInfoTile(
                icon: Icons.school_outlined,
                label: 'Jurusan',
                value: user.jurusan?.name ?? '-',
              ),
              ProfileInfoTile(
                icon: Icons.class_outlined,
                label: 'Kelas',
                value: user.kelas?.name ?? '-',
              ),
              ProfileInfoTile(
                icon: Icons.phone_outlined,
                label: 'Nomor HP',
                value: user.phone ?? 'Belum ditambahkan',
              ),
              const Divider(),
            ],
          );
        },
        // Untuk state initial, tampilkan loading agar checkAuth berjalan
        initial: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// Widget bantuan agar kode lebih rapi
class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
