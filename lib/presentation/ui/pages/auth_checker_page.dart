// lib/presentation/ui/pages/auth_checker_page.dart

import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/ui/pages/login_page.dart';
import 'package:epkl/presentation/ui/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthCheckerPage extends ConsumerStatefulWidget {
  const AuthCheckerPage({super.key});

  @override
  ConsumerState<AuthCheckerPage> createState() => _AuthCheckerPageState();
}

class _AuthCheckerPageState extends ConsumerState<AuthCheckerPage> {
  @override
  void initState() {
    super.initState();
    // Panggil setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dengarkan state otentikasi
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      // Jika berhasil (sudah login), arahkan ke HomePage
      success: (_) => const MainPage(),
      // Jika initial atau error (belum login), arahkan ke LoginPage
      initial: () => const LoginPage(),
      error: (_) => const LoginPage(),
      // Saat memeriksa token, tampilkan layar loading
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
