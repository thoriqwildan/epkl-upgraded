// lib/presentation/ui/pages/info_detail_page.dart
import 'package:epkl/presentation/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InfoDetailPage extends ConsumerWidget {
  final int infoId;
  const InfoDetailPage({super.key, required this.infoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton provider detail info dengan ID yang dikirim
    final infoDetailState = ref.watch(infoDetailProvider(infoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Informasi')),
      body: infoDetailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (info) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.image != null)
                Image.network(
                  "http://epkl.smk2-yk.sch.id${info.image}",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 100),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dipublikasikan pada ${DateFormat('d MMMM yyyy', 'id_ID').format(info.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Divider(height: 32),
                    Text(
                      info.info,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
