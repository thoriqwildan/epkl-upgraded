import 'package:epkl/data/models/journal.dart';
import 'package:epkl/presentation/providers/journal_provider.dart';
import 'package:epkl/presentation/ui/pages/add_journal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class JournalListPage extends ConsumerWidget {
  const JournalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Harian')),
      body: journalState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gagal memuat data: $err'),
          ),
        ),
        data: (journals) {
          if (journals.isEmpty) {
            return const Center(child: Text('Belum ada entri jurnal.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final journal = journals[index];
              return JournalCard(journal: journal);
            },
          );
        },
      ),
      // Tombol Tambah Jurnal
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJournalPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Jurnal',
      ),
    );
  }
}

// Widget untuk menampilkan satu item jurnal agar lebih rapi
class JournalCard extends StatelessWidget {
  final Journal journal;
  const JournalCard({super.key, required this.journal});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(DateTime.parse(journal.tanggal)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(height: 20),
            Text(
              journal.kegiatan,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 4, // Batasi teks kegiatan agar tidak terlalu panjang
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
