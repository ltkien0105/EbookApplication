import 'package:flutter/material.dart';

class InputFieldProfile extends StatelessWidget {
  const InputFieldProfile({
    super.key,
    required this.title,
    required this.content,
    this.controller,
    this.enabled = true,
  });

  final String title;
  final String content;
  final TextEditingController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.start,
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: content,
          enabled: enabled,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}