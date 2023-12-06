import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/services/social_signin.dart';
import 'package:ebook_application/components/date_picker_field.dart';
import 'package:ebook_application/screen/sign_in/sign_in_screen.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';
import 'package:ebook_application/screen/sign_in/components/header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.isEmail,
  });

  final bool isEmail;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with InputValidatorMixin {
  final _fullNameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool hasUserExist = false;
  bool isLoading = false;
  DateTime? _dateOfBirth;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void getDateOfBirth(DateTime dateOfBirth) {
    _dateOfBirth = dateOfBirth;
  }

  bool validate() {
    if (_formKey.currentState!.validate()) {
      if (_dateOfBirth == null) {
        showErrorMessage('Please enter your date of birth!');
        return false;
      }
      return true;
    }

    return false;
  }

  Future<void> _signUp(
    String emailPhone,
    String? password,
    String fullName,
    DateTime dateOfBirth,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      //Create user
      if (widget.isEmail) {
        await auth
            .createUserWithEmailAndPassword(
          email: emailPhone,
          password: password!,
        )
            .then(
          (UserCredential userCredential) async {
            final User? user = userCredential.user;
            if (user != null) {
              if (user.emailVerified == false) {
                await user.sendEmailVerification();

                showInfoMessage('An email confirm has sent to: ${user.email}');
                user.updateDisplayName(fullName);
                firestore.doc('users/${user.uid}').set({
                  'dateOfBirth': dateOfBirth,
                });
              }
            }
          },
        );
      } else {
        final Map<String, dynamic> userMetaData = {
          'full_name': fullName,
          'dateOfBirth': dateOfBirth,
        };
        await SocialSignIn().signInWithPhoneNumber(
          context: context,
          phoneNumber: _emailPhoneController.text,
          userMetaData: userMetaData,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        if (!mounted) return;
        context.showErrorMessage('The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        if (!mounted) return;
        context.showErrorMessage('The account already exists for that email.');
      } else if (error.code == 'invalid-email') {
        if (!mounted) return;
        context.showErrorMessage('Email is invalid');
      } else if (error.code == 'operation-not-allowed') {
        if (!mounted) return;
        context.showErrorMessage('Sign in with email is not enabled.');
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorMessage(e as String);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> showDirectToSignInDialog() {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Congratulations, sign up successfully!'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Back to sign in'),
          )
        ],
      ),
    );
  }

  void showErrorMessage(String message) => context.showErrorMessage(message);

  void showInfoMessage(String message) => context.showInfoMessage(message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Header(
                        firstText: 'Let\'s sign you up',
                        secondText:
                            'Please sign up an account to use this app!',
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputField(
                              label: 'Full name',
                              controller: _fullNameController,
                              hintText: 'Enter your full name',
                              validator: (fullName) {
                                if (fullName == null || fullName.isEmpty) {
                                  return 'Full name is required';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InputField(
                              label: widget.isEmail ? 'Email' : 'Phone number',
                              controller: _emailPhoneController,
                              hintText: widget.isEmail
                                  ? 'Enter your email'
                                  : 'Enter your phone number',
                              validator: (emailPhone) {
                                if (emailPhone == null || emailPhone.isEmpty) {
                                  return widget.isEmail
                                      ? 'Email is required'
                                      : 'Phone number is required';
                                }

                                if (widget.isEmail) {
                                  if (!isEmailValid(emailPhone)) {
                                    return 'Enter a valid email';
                                  }
                                } else {
                                  if (!isPhoneValid(emailPhone)) {
                                    return 'Enter a valid phone number';
                                  }
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 22,
                              child: Text(
                                'Date of birth',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DatePickerField(getDateOfBirth: getDateOfBirth),
                            const SizedBox(
                              height: 20,
                            ),
                            if (widget.isEmail)
                              InputField(
                                label: 'Password',
                                controller: _passwordController,
                                hintText: 'Enter your password',
                                isPassword: true,
                                validator: (password) {
                                  if (password == null || password.isEmpty) {
                                    return 'Password is required';
                                  }

                                  if (isPasswordValid(password)) return null;

                                  return 'Enter a valid password';
                                },
                              ),
                            if (widget.isEmail)
                              const SizedBox(
                                height: 20,
                              ),
                            if (widget.isEmail)
                              InputField(
                                label: 'Confirm password',
                                controller: _confirmPasswordController,
                                hintText: 'Enter confirm password',
                                isPassword: true,
                                validator: (confirmPassword) {
                                  if (confirmPassword == null ||
                                      confirmPassword.isEmpty) {
                                    return 'Confirm password is required';
                                  } else if (confirmPassword !=
                                      _passwordController.text) {
                                    return 'Confirm password is not match';
                                  }

                                  return null;
                                },
                              ),
                            const SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: getProportionateScreenHeight(45),
                              child: TextButton(
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  if (validate()) {
                                    _signUp(
                                      _emailPhoneController.text,
                                      widget.isEmail
                                          ? _passwordController.text
                                          : null,
                                      _fullNameController.text,
                                      _dateOfBirth!,
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                    Color.fromARGB(255, 51, 75, 235),
                                  ),
                                  foregroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white),
                                  shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.white,
                                          color: Colors.yellow,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
