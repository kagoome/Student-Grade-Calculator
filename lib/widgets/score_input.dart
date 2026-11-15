import 'package:flutter/material.dart';

/// Input nilai tunggal (widget lama, tidak dipakai di layar saat ini).
/// Gaya mengikuti tema aplikasi sehingga aman untuk mode terang/gelap.
class ScoreInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const ScoreInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: '/ 100',
      ),
    );
  }
}
