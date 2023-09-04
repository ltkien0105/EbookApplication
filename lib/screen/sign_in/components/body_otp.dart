import 'package:ebook_application/components/loading_overplay.dart';
import 'package:ebook_application/screen/home/home_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

import 'package:ebook_application/constants.dart';

class BodyOtp extends StatefulWidget {
  const BodyOtp({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.userMetaData,
  });

  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final Map<String, dynamic>? userMetaData;

  @override
  State<BodyOtp> createState() => _BodyOtpState();
}

class _BodyOtpState extends State<BodyOtp> {
  bool _isLoading = false;
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  String code = "";

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 234, 239, 244),
        borderRadius: BorderRadius.circular(19),
      ),
    );

    return SafeArea(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 32,
                ),
                const Text(
                  'Phone Verification',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Pinput(
                    controller: pinController,
                    focusNode: focusNode,
                    androidSmsAutofillMethod:
                        AndroidSmsAutofillMethod.smsUserConsentApi,
                    defaultPinTheme: defaultPinTheme,
                    length: 6,
                    onCompleted: (smsCode) async {
                      code = smsCode;
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: widget.verificationId,
                        smsCode: code,
                      );

                      try {
                        setState(() {
                          _isLoading = true;
                        });
                        await auth
                            .signInWithCredential(credential)
                            .then((UserCredential userCredential) async {
                          if (userCredential.user != null) {
                            final user = userCredential.user;
                            final userMetaData = widget.userMetaData;
                            if (userMetaData != null) {
                              await firestore
                                  .collection('accounts')
                                  .doc(userMetaData['username'])
                                  .set({
                                'creation_time': user!.metadata.creationTime,
                                'password': null,
                              });

                              await firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .set({
                                'username': firestore.doc(
                                    'accounts/${userMetaData['username']}'),
                                'birthday': userMetaData['birthday'],
                                'email': null,
                                'phone_number': user.phoneNumber,
                                'full_name': userMetaData['full_name'],
                              });
                            }
                            navigateToHomePage();
                          }
                        });
                      } on FirebaseAuthException catch (error) {
                        if (error.code == 'invalid-verification-code') {
                          context.showErrorMessage(
                              'Verification code is incorrect');
                        }
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t receive OTP?'),
                    TextButton(
                      onPressed: () async {
                        await auth.verifyPhoneNumber(
                          phoneNumber: '+84${widget.phoneNumber.substring(1)}',
                          verificationCompleted:
                              (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (
                            String verificationId,
                            int? resendToken,
                          ) async {
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: code,
                            );
                            await auth.signInWithCredential(credential);
                          },
                          forceResendingToken: widget.resendToken,
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      },
                      child: const Text('Resend'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading) const LoadingOverplay()
        ],
      ),
    );
  }
}
