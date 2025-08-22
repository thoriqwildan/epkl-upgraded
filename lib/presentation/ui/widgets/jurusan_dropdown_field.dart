import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/presentation/ui/widgets/profile_text_field.dart';
import 'package:flutter/material.dart';

class JurusanDropdownField extends StatelessWidget {
  final bool isEditing;
  final List<Jurusan> jurusanList;
  final int? selectedJurusanId;
  final ValueChanged<int?> onChanged;
  final String initialValueText;

  const JurusanDropdownField({
    super.key,
    required this.isEditing,
    required this.jurusanList,
    required this.selectedJurusanId,
    required this.onChanged,
    required this.initialValueText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return ProfileTextField(
        controller: TextEditingController(text: initialValueText),
        label: 'Jurusan',
        icon: Icons.school_outlined,
        isEditing: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        // --- PERBAIKAN #1: Menggunakan 'value' untuk state yang lebih robust ---
        // 'value' akan selalu merefleksikan state terbaru dari parent widget,
        // tidak seperti 'initialValue' yang hanya diatur sekali.
        value: selectedJurusanId,
        menuMaxHeight: 300.0,
        borderRadius: BorderRadius.circular(12),
        items: jurusanList.map((jurusan) {
          return DropdownMenuItem<int>(
            value: jurusan.id,
            // --- PERBAIKAN #2 (UTAMA): Menghapus widget 'Expanded' ---
            // 'Expanded' tidak boleh digunakan di sini dan merupakan penyebab
            // bug tampilan di perangkat yang berbeda.
            child: Text(jurusan.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: 'Jurusan',
          prefixIcon: Icon(
            Icons.school_outlined,
            color: Theme.of(context).primaryColor,
          ),
          // Properti 'filled' dan 'fillColor' di sini tidak terlalu efektif
          // karena field ini hanya muncul saat isEditing = true.
          // Jadi bisa dihapus jika mau.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
