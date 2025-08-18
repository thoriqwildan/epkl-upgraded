// lib/utils/snackbar_helper.dart

import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  // Hapus SnackBar yang mungkin sedang tampil
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Tampilkan SnackBar baru
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating, // Agar terlihat lebih modern
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
