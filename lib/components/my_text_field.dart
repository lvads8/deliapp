import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool hideInput;
  final String? errorText;

  const MyTextField({
    Key? key,
    required this.label,
    this.controller,
    this.onChanged,
    this.hideInput = false,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autocorrect: false,
      obscureText: hideInput,
      onChanged: onChanged,
      enabled: onChanged != null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        label: Text(label),
        errorText: errorText,
      ),
    );
  }
}
