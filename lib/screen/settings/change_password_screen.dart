import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/components/input_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formChangePassKey = GlobalKey<FormState>();

  late TextEditingController curPassController;
  late TextEditingController newPassController;
  late TextEditingController confirmPassController;
  final user = auth.currentUser!;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    curPassController = TextEditingController();
    newPassController = TextEditingController();
    confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    curPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Change password'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formChangePassKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputField(
                      label: 'Current password',
                      isPassword: true,
                      controller: curPassController,
                      validator: (curPass) {
                        if (curPass == null || curPass.isEmpty) {
                          return 'This field is required';
                        }

                        if (curPass.length < 8) {
                          return 'This field must be at least 8 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'New password',
                      isPassword: true,
                      controller: newPassController,
                      validator: (newPass) {
                        if (newPass == null || newPass.isEmpty) {
                          return 'This field is required';
                        }

                        if (newPass.length < 8) {
                          return 'This field must be at least 8 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Confirm password',
                      controller: confirmPassController,
                      isPassword: true,
                      validator: (confirmPass) {
                        if (confirmPass == null || confirmPass.isEmpty) {
                          return 'This field is required';
                        }

                        if (confirmPass != newPassController.text) {
                          return 'This field must match new password';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: SizeConfig.screenWidth! * 0.6,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formChangePassKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: curPassController.text,
                            );

                            try {
                              await user
                                  .reauthenticateWithCredential(credential);

                              await user.updatePassword(newPassController.text);

                              setState(() {
                                isLoading = false;
                              });

                              if (!mounted) return;
                              context.showInfoMessage(
                                  'Change password successfully');

                              curPassController.clear();
                              newPassController.clear();
                              confirmPassController.clear();
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'wrong-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('The password is invalid'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: SizedBox(
                          width: SizeConfig.screenWidth! * .4,
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                                : const Text('Change password'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
