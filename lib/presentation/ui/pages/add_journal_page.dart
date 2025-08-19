// lib/presentation/ui/pages/add_journal_page.dart

import 'package:epkl/presentation/providers/journal_provider.dart';
import 'package:epkl/presentation/providers/setting_provider.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddJournalPage extends ConsumerStatefulWidget {
  const AddJournalPage({super.key});

  @override
  ConsumerState<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends ConsumerState<AddJournalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kegiatanController;
  late final TextEditingController _targetController;
  bool _isSaving = false;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _kegiatanController = TextEditingController();
    _targetController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate:
          DateTime.now(), // Batasi agar tidak bisa memilih tanggal di masa depan
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveJournal() async {
    // 1. Validasi semua input di form
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // 2. Panggil method createJournal dari Notifier
      final success = await ref
          .read(journalNotifierProvider.notifier)
          .createJournal(
            kegiatan: _kegiatanController.text,
            target: _targetController.text,
            tanggal: _selectedDate,
          );

      setState(() => _isSaving = false);

      // 3. Berikan feedback ke pengguna dan kembali ke halaman sebelumnya
      if (mounted && success) {
        showAppSnackBar(context, message: 'Jurnal berhasil disimpan!');
        Navigator.of(context).pop(); // Kembali ke JournalListPage
      } else if (mounted) {
        showAppSnackBar(
          context,
          message: 'Gagal menyimpan jurnal',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDateManipulationEnabled = ref
        .watch(settingsNotifierProvider)
        .isDateManipulationEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Jurnal Harian')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (isDateManipulationEnabled) ...[
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal Jurnal'),
                subtitle: Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  ).format(_selectedDate),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _kegiatanController,
              decoration: const InputDecoration(
                labelText: 'Kegiatan Hari Ini',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8, // Field yang lebih besar untuk kegiatan
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kegiatan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Tercapai',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Target tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveJournal, // Disable saat saving
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Jurnal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
