import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.initialValue,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 22,
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelStyle: const TextStyle(
              color: Colors.black,
            ),
            filled: true,
            hintText: hintText,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
          ),
          cursorColor: Colors.black,
        ),
      ],
    );
  }
}
