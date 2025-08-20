// lib/presentation/ui/widgets/info_card.dart
import 'package:epkl/data/models/info_summary.dart';
import 'package:epkl/presentation/ui/pages/info_detail_page.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final InfoSummary info;
  const InfoCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN UTAMA: Ganti Card dengan ListTile di dalam Card ---
    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Beri jarak bawah antar item
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Gunakan gambar sebagai leading jika ada, jika tidak gunakan ikon
        leading: info.image != null
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  "http://epkl.smk2-yk.sch.id${info.image}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
              )
            : const Icon(Icons.info_outline, size: 40),
        title: Text(info.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoDetailPage(infoId: info.id),
            ),
          );
        },
      ),
    );
  }
}
