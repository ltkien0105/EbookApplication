import 'package:flutter/material.dart';

import 'package:ebook_application/screen/sign_in/components/body_forget_password.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BodyForget(),
    );
  }
}
