import 'dart:async';

import 'package:epkl/presentation/ui/pages/secret_setting_page.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _tapCount = 0;
  Timer? _tapTimer;

  void _handleLogoTap() {
    _tapCount++;
    _tapTimer?.cancel();

    if (_tapCount == 3) {
      _tapCount = 0;
      print("Membuka halaman rahasia");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SecretSettingsPage()),
      );
    } else {
      _tapTimer = Timer(const Duration(seconds: 1), () {
        _tapCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleLogoTap,
                child: const FlutterLogo(size: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aplikasi EPKL',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Dibuat dan dikembangkan oleh:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thoriq Wildan Abdurrosyid', // Ganti dengan nama Anda
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
