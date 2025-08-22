import 'dart:async';

import 'package:epkl/presentation/ui/pages/secret_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SecretSettingsPage()),
      );
    } else {
      _tapTimer = Timer(const Duration(seconds: 2), () {
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          _buildInteractionSection(context),
          const Divider(height: 1),
          _buildLegalSection(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const String appVersion = '1.0.0'; // Sebaiknya ambil dari package_info_plus

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        children: [
          // Logo dengan gestur tap rahasia
          GestureDetector(
            onTap: _handleLogoTap,
            child: Image(
              image: AssetImage('assets/images/smk2-logo.png'),
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aplikasi EPKL',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Versi aplikasi yang bisa di-tap untuk menyalin
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: appVersion));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Versi aplikasi disalin ke clipboard.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                'Versi $appVersion',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk bagian Interaksi Pengguna
  Widget _buildInteractionSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Bagikan Aplikasi'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Implementasi fungsi share.
            // Anda bisa menggunakan package 'share_plus'.
          },
        ),
        ListTile(
          leading: const Icon(Icons.contact_support_outlined),
          title: const Text('Hubungi Dukungan'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Implementasi buka email client (mailto).
            // Anda bisa menggunakan package 'url_launcher'.
          },
        ),
      ],
    );
  }

  // Widget untuk bagian Legal
  Widget _buildLegalSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Kebijakan Privasi'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Buka URL Kebijakan Privasi Anda.
          },
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Syarat & Ketentuan'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Buka URL Syarat & Ketentuan Anda.
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Lisensi Open Source'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Aplikasi EPKL',
            applicationVersion: '1.0.0',
            applicationIcon:
                const FlutterLogo(), // atau Image.asset('path/logo.png')
          ),
        ),
      ],
    );
  }

  // Widget untuk bagian Footer
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            'Dibuat dan dikembangkan oleh:',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Thoriq Wildan Abdurrosyid',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Thoriq Wildan Abdurrosyid.\nAll Rights Reserved.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
