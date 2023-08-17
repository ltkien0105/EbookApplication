import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/screen/sign_in/sign_in_screen.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';

class BodyForget extends StatefulWidget {
  const BodyForget({super.key});

  @override
  State<BodyForget> createState() => _BodyForgetState();
}

class _BodyForgetState extends State<BodyForget> with InputValidatorMixin {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isButtonEnable = false;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      setState(() {
        _isValid = true;
      });
      if (_emailController.text.isNotEmpty) {
        setState(() {
          _isButtonEnable = true;
        });
      } else {
        setState(() {
          _isButtonEnable = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool validate() {
    if (isEmailValid(_emailController.text)) {
      setState(() {
        _isValid = true;
      });
      return true;
    } else {
      setState(() {
        _isValid = false;
      });
      return false;
    }
  }

  void showInfoMessage() {
    context.showInfoMessage(
        'A password reset email has been sent to: ${_emailController.text}');
  }

  Future<void> resetPassword() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        await auth.sendPasswordResetEmail(email: _emailController.text);
        showInfoMessage();
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {
          context.showErrorMessage('Email has not used yet');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 32,
            ),
            const Text(
              'Reset password',
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  label: const Text('Email'),
                  errorText: _isValid ? null : 'Email is invalid'),
            ),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: _isButtonEnable ? resetPassword : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 51, 75, 235),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.yellow,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text('Reset password'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Remembered your password?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
