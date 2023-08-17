import 'package:flutter/material.dart';

//Firebase_auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/services/social_signin.dart';
import 'package:ebook_application/screen/sign_in/sign_in_screen.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';
import 'package:ebook_application/screen/sign_in/components/header.dart';
import 'package:ebook_application/components/date_picker_field.dart';

class BodySignUp extends StatefulWidget {
  const BodySignUp({
    super.key,
  });

  @override
  State<BodySignUp> createState() => _BodySignUpState();
}

class _BodySignUpState extends State<BodySignUp> with InputValidatorMixin {
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool hasUserExist = false;
  bool isLoading = false;
  bool isEmail = true;
  DateTime? _birthday;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void getBirthday(DateTime birthday) {
    _birthday = birthday;
  }

  bool validate() {
    if (_formKey.currentState!.validate()) {
      if (_birthday == null) {
        showErrorMessage('Please enter your birthday!');
        return false;
      }
      return true;
    }

    return false;
  }

  Future<void> _signUp(
    String emailPhone,
    String password,
    String username,
    String fullname,
    DateTime birthday,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });
      //Create user
      if (isEmail) {
        await auth
            .createUserWithEmailAndPassword(
                email: emailPhone, password: password)
            .then(
          (UserCredential userCredential) async {
            final User? user = userCredential.user;
            if (user != null) {
              if (user.emailVerified == false) {
                await user.sendEmailVerification();
                showInfoMessage('An email confirm has sent to: ${user.email}');
              }

              await firestore.collection('accounts').doc(username).set({
                'creation_time': user.metadata.creationTime,
                'password': password,
              });

              await firestore.collection('users').doc(user.uid).set({
                'username': firestore.doc('accounts/$username'),
                'birthday': birthday,
                'email': user.email,
                'full_name': fullname,
              });
            }
          },
        );
      } else {
        final Map<String, dynamic> userMetaData = {
          'username': username,
          'full_name': fullname,
          'birthday': birthday,
        };
        await SocialSignIn().signInWithPhoneNumber(
          context: context,
          phoneNumber: _emailPhoneController.text,
          userMetaData: userMetaData,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        context.showErrorMessage('The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        context.showErrorMessage('The account already exists for that email.');
      } else if (error.code == 'invalid-email') {
        context.showErrorMessage('Email is invalid');
      } else if (error.code == 'operation-not-allowed') {
        context.showErrorMessage('Sign in with email is not enabled.');
      }
    } catch (e) {
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
                    flex: 1,
                    child: Header(
                      firstText: 'Let\'s sign you up',
                      secondText: 'Please sign up an account to use this app!',
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputField(
                            label: 'Username',
                            controller: _usernameController,
                            hintText: 'Enter your username',
                            validator: (username) {
                              if (username == null || username.isEmpty) {
                                return 'Username is required';
                              }

                              if (isUsernameValid(username)) {
                                if (hasUserExist) {
                                  return 'User has already existed';
                                }
                                return null;
                              }

                              return 'Enter a valid username';
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InputField(
                            label: 'Full name',
                            controller: _fullnameController,
                            hintText: 'Enter your full name',
                            validator: (fullname) {
                              if (fullname == null || fullname.isEmpty) {
                                return 'Full name is required';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InputField(
                            label: 'Email/ Phone number',
                            controller: _emailPhoneController,
                            hintText: 'Enter your email or phone number',
                            validator: (emailPhone) {
                              if (emailPhone == null || emailPhone.isEmpty) {
                                return 'Email or phone number is required';
                              }

                              if (isEmailValid(emailPhone)) return null;
                              if (isPhoneValid(emailPhone)) {
                                isEmail = false;
                                return null;
                              }

                              return 'Enter a valid email or phone number';
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            width: double.infinity,
                            height: 22,
                            child: Text(
                              'Birthday',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DatePickerField(getBirthday: getBirthday),
                          const SizedBox(
                            height: 20,
                          ),
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
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: getProportionateScreenHeight(45),
                            child: TextButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus!.unfocus();
                                try {
                                  if(_usernameController.text.isNotEmpty) {
                                    await firestore
                                        .collection('accounts')
                                        .doc(_usernameController.text)
                                        .get()
                                        .then((DocumentSnapshot docSnapshot) {
                                      if (docSnapshot.exists) {
                                        hasUserExist = true;
                                      }
                                    });
                                  }
                                } finally {
                                  if (validate()) {
                                    _signUp(
                                      _emailPhoneController.text,
                                      _passwordController.text,
                                      _usernameController.text,
                                      _fullnameController.text,
                                      _birthday!,
                                    );
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
    );
  }
}
