// lib/data/services/update_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  final Dio _dio = Dio();

  // --- GANTI DENGAN USERNAME DAN NAMA REPO GITHUB ANDA ---
  final String _githubOwner = "thoriqwildan";
  final String _githubRepo = "epkl-upgraded";
  // ----------------------------------------------------

  Future<void> checkForUpdate(BuildContext context) async {
    // 1. Dapatkan versi aplikasi yang sedang berjalan
    final currentVersionStr = (await PackageInfo.fromPlatform()).version;
    final currentVersion = Version.parse(currentVersionStr);
    print('Current App Version: $currentVersion');

    try {
      // 2. Ambil data rilis terbaru dari GitHub API
      final response = await _dio.get(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );

      if (response.statusCode == 200 && response.data != null) {
        // Ambil nama tag (misal: "v1.0.1") dan hapus "v"
        final latestVersionStr = (response.data['tag_name'] as String)
            .replaceAll('v', '');
        final latestVersion = Version.parse(latestVersionStr);
        final releaseNotes = response.data['body'] as String;
        final releaseUrl = response.data['html_url'] as String;

        print('Latest GitHub Version: $latestVersion');

        // 3. Bandingkan versi
        if (latestVersion > currentVersion) {
          // Jika ada versi baru, tampilkan dialog
          _showUpdateDialog(
            context,
            latestVersion.toString(),
            releaseNotes,
            releaseUrl,
          );
        }
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String newVersion,
    String releaseNotes,
    String url,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Tersedia: v$newVersion'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Versi baru dari aplikasi tersedia. Perbarui sekarang?',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Catatan Rilis:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  releaseNotes.isEmpty
                      ? 'Tidak ada catatan rilis.'
                      : releaseNotes,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Nanti Saja'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Update Sekarang'),
              onPressed: () {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
