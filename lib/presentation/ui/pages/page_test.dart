import 'package:flutter/material.dart';

class TransparencyTestPage extends StatelessWidget {
  const TransparencyTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // GANTI DENGAN PATH ASET ANDA YANG SEBENARNYA
    const String yourImagePath = 'assets/images/smk2-logo.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Transparansi Gambar'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background pola papan catur
          _buildCheckerboard(context),

          // Gambar Anda di tengah
          Center(
            child: Image(image: const AssetImage(yourImagePath), width: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckerboard(BuildContext context) {
    // ... (kode helper _buildCheckerboard sama seperti jawaban sebelumnya)
    return Positioned.fill(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 20,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 20;
          int col = index % 20;
          bool isDark = (row + col) % 2 == 0;
          return Container(color: isDark ? Colors.grey[400] : Colors.grey[200]);
        },
      ),
    );
  }
}
