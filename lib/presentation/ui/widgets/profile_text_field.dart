import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isEditing;
  final bool isEnabledInEditMode;
  final TextInputType keyboardType;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isEditing,
    this.isEnabledInEditMode = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: isEditing && isEnabledInEditMode,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: !isEditing || !isEnabledInEditMode,
          fillColor: Theme.of(context).disabledColor.withOpacity(0.1),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Theme.of(context).disabledColor),
          ),
        ),
      ),
    );
  }
}
