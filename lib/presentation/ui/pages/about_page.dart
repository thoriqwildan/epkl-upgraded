import 'dart:async';

import 'package:epkl/presentation/ui/pages/secret_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _tapCount = 0;
  Timer? _tapTimer;
  String _appVersion = 'Memuat ...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleLogoTap,
            child: Image.asset(
              // Gunakan Image.asset untuk logo dari assets
              'assets/images/smk2-logo.png', // Pastikan path ini benar
              width: 120, // Ukuran bisa disesuaikan
              height: 120,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aplikasi EPKL',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Clipboard.setData(ClipboardData(text: _appVersion));
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
              // Gunakan state _appVersion yang sudah dinamis
              child: Text(
                'Versi $_appVersion',
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
            Share.share(
              'Coba aplikasi E-PKL SMKN 2 Yogyakarta! https://api.github.com/repos/thoriqwildan/epkl-upgraded/releases/latest',
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.contact_support_outlined),
          title: const Text('Hubungi Dukungan'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'wildanthoriq14@gmail.com',
              query:
                  'subject=Dukungan Aplikasi EPKL v$_appVersion', // Subjek email
            );
            launchUrl(emailLaunchUri);
          },
        ),
      ],
    );
  }

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
            applicationVersion: _appVersion,
            applicationIcon: Image.asset(
              'assets/images/smk2-logo.png',
              width: 48,
            ),
          ),
        ),
      ],
    );
  }

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
