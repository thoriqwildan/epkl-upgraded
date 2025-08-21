import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerFormField extends StatelessWidget {
  const ShimmerFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Gunakan widget Shimmer sebagai pembungkus
      child: Shimmer.fromColors(
        // Tentukan warna dasar dan warna kilau
        baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        highlightColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.2),
        child: Container(
          height: 60, // Sesuaikan tinggi agar sama dengan TextFormField
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
