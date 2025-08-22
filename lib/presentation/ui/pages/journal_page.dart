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

      // --- PERUBAHAN 1: Bungkus Body dengan RefreshIndicator ---
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
        onRefresh: () =>
            ref.read(journalNotifierProvider.notifier).fetchJournal(),
        child: journalState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Gagal memuat data: $err'),
            ),
          ),
          data: (journals) {
            // --- PERUBAHAN 2: Buat state "kosong" agar bisa di-scroll ---
            if (journals.isEmpty) {
              // Bungkus dengan ListView agar tetap bisa ditarik untuk refresh
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: const Center(
                        child: Text('Belum ada entri jurnal.'),
                      ),
                    ),
                  );
                },
              );
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
      ),

      // Tombol Tambah Jurnal (tidak ada perubahan)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            // Menggunakan MaterialPageRoute agar transisi mengikuti tema global
            MaterialPageRoute(builder: (context) => const AddJournalPage()),
          );
        },
        tooltip: 'Tambah Jurnal',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget JournalCard (tidak ada perubahan)
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 20),
            Text(
              journal.kegiatan,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
