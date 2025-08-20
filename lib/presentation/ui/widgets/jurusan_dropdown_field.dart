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
        value: selectedJurusanId,
        menuMaxHeight: 300.0,
        borderRadius: BorderRadius.circular(12),
        items: jurusanList.map((jurusan) {
          return DropdownMenuItem<int>(
            value: jurusan.id,
            child: Expanded(
              child: Text(jurusan.name, overflow: TextOverflow.ellipsis),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Jurusan',
          prefixIcon: Icon(Icons.school_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}
