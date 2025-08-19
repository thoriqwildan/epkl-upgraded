// lib/presentation/ui/pages/login_page.dart

import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/ui/pages/main_page.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller dan form key tidak perlu diubah
    final _emailController = TextEditingController(
      text: "wildanthoriq14@gmail.com",
    );
    final _passwordController = TextEditingController(text: "Wildan14#");
    final _formKey = GlobalKey<FormState>();

    // Bagian ref.listen ini sudah benar, tidak perlu diubah
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (user) {
          // Panggil helper kita
          showAppSnackBar(context, message: 'Selamat datang, ${user.name}!');

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false, // Hapus semua halaman sebelumnya
          );
        },
        error: (message) {
          // Panggil helper kita dengan flag error
          showAppSnackBar(context, message: message, isError: true);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login Siswa')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authNotifierProvider);
                  return authState.maybeWhen(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    orElse: () => ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ref
                              .read(authNotifierProvider.notifier)
                              .login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('LOGIN'),
                    ),
                  );
                },
              ),
              // ==========================================================
            ],
          ),
        ),
      ),
    );
  }
}
