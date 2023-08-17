import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/screen/home/home_page.dart';
import 'package:ebook_application/components/social_card.dart';
import 'package:ebook_application/services/social_signin.dart';
import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/screen/sign_in/sign_up_screen.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';
import 'package:ebook_application/screen/sign_in/components/header.dart';
import 'package:ebook_application/screen/sign_in/forget_password_screen.dart';

class BodySignIn extends StatefulWidget {
  const BodySignIn({super.key});

  @override
  State<BodySignIn> createState() => _BodySignInState();
}

class _BodySignInState extends State<BodySignIn> with InputValidatorMixin {
  bool _isLoading = false;
  bool _isEmail = true;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool validate() {
    if (_formKey.currentState!.validate()) {
      return true;
    }

    return false;
  }

  Future<void> _signInWithEmailAndPassword(
      String email, String password) async {
    if (validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then(
          (UserCredential userCredential) {
            if (userCredential.user != null) {
              if (userCredential.user!.emailVerified) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              } else {
                context.showErrorMessage(
                  'Please verify email before signing in!',
                );
              }
            }
          },
        );
      } on FirebaseAuthException catch (error) {
        if (mounted) {
          if (error.code == 'user-not-found') {
            context.showErrorMessage(
              'User is not be found!',
            );
          }
          if (error.code == 'wrong-password') {
            context.showErrorMessage(
              'Password is incorrect!',
            );
          }
        }
      } catch (error) {
        context.showErrorMessage(error as String);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Header(
                      firstText: 'Let\'s sign you in',
                      secondText: 'Welcome back!',
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isEmail)
                            InputField(
                              label: 'Phone number',
                              controller: _phoneController,
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.phone,
                              validator: (phoneNumber) {
                                if (phoneNumber == null ||
                                    phoneNumber.isEmpty) {
                                  return 'Phone number is required';
                                }

                                if (isPhoneValid(phoneNumber)) return null;

                                return 'Enter a valid phone number';
                              },
                            ),
                          if (_isEmail)
                            InputField(
                              label: 'Email',
                              controller: _emailController,
                              hintText: 'Enter your email',
                              validator: (emailPhone) {
                                if (emailPhone == null || emailPhone.isEmpty) {
                                  return 'Email is required';
                                }

                                if (isEmailValid(emailPhone)) return null;

                                return 'Enter a valid email';
                              },
                            ),
                          if (_isEmail)
                            const SizedBox(
                              height: 20,
                            ),
                          if (_isEmail)
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
                          if (_isEmail)
                            Row(
                              children: [
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: getProportionateScreenHeight(45),
                            child: TextButton(
                              onPressed: () async {
                                if (_isEmail) {
                                  _signInWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                                } else {
                                  if (validate()) {
                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      await SocialSignIn()
                                          .signInWithPhoneNumber(
                                        context: context,
                                        phoneNumber: _phoneController.text,
                                      );
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: const MaterialStatePropertyAll(
                                  Color.fromARGB(255, 51, 75, 235),
                                ),
                                foregroundColor: const MaterialStatePropertyAll(
                                    Colors.white),
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              child: _isLoading == true
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
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                          const Spacer(),
                          const Text('or continue with'),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SocialCard(
                                image: 'assets/icons/google.svg',
                                onTap: () {
                                  SocialSignIn().signInWithGoogle(context);
                                },
                              ),
                              SocialCard(
                                image: 'assets/icons/facebook.svg',
                                onTap: () {
                                  SocialSignIn().signInWithFacebook(context);
                                },
                              ),
                              _isEmail
                                  ? SocialCard(
                                      image: 'assets/icons/phone.svg',
                                      onTap: () {
                                        setState(() {
                                          _isEmail = false;
                                        });
                                      },
                                    )
                                  : SocialCard(
                                      image: 'assets/icons/email.svg',
                                      onTap: () {
                                        setState(() {
                                          _isEmail = true;
                                        });
                                      },
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text('Register now'),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
