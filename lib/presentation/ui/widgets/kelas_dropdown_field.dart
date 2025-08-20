import 'package:epkl/data/models/kelas.dart';
import 'package:epkl/presentation/ui/widgets/profile_text_field.dart';
import 'package:flutter/material.dart';

class KelasDropdownField extends StatelessWidget {
  final bool isEditing;
  final List<Kelas> kelasList;
  final int? selectedJurusanId;
  final int? selectedKelasId;
  final ValueChanged<int?> onChanged;
  final String initialValueText;

  const KelasDropdownField({
    super.key,
    required this.isEditing,
    required this.kelasList,
    required this.selectedJurusanId,
    required this.selectedKelasId,
    required this.onChanged,
    required this.initialValueText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return ProfileTextField(
        controller: TextEditingController(text: initialValueText),
        label: 'Kelas',
        icon: Icons.class_outlined,
        isEditing: false,
      );
    }

    final filteredKelasList = kelasList
        .where((kelas) => kelas.mJurusanId == selectedJurusanId)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: selectedKelasId,
        menuMaxHeight: 300.0,
        borderRadius: BorderRadius.circular(12),
        items: filteredKelasList.map((kelas) {
          return DropdownMenuItem<int>(
            value: kelas.id,
            child: Expanded(
              child: Text(kelas.name, overflow: TextOverflow.ellipsis),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: 'Kelas',
          prefixIcon: const Icon(Icons.class_outlined),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          hintText: selectedJurusanId == null
              ? 'Pilih Jurusan terlebih dahulu'
              : 'Pilih Kelas',
        ),
      ),
    );
  }
}
