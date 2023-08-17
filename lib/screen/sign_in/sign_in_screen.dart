import 'package:flutter/material.dart';

import 'package:ebook_application/screen/sign_in/components/body_sign_in.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BodySignIn(),
    );
  }
}
