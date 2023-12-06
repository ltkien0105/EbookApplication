import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/screen/home/home_page.dart';
import 'package:ebook_application/screen/sign_in/otp_screen.dart';

class SocialSignIn {
  GoogleSignInAccount? _gUser;

  GoogleSignInAccount? get gUser => _gUser;

  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    _gUser = googleUser;

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );

    try {
      await auth
          .signInWithCredential(credential)
          .then((UserCredential userCredential) {
        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'invalid-credential') {
        context.showErrorMessage(
          'Error occurred while accessing credentials. Try again.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorMessage(
        'Error occurred using Google Sign-In. Try again.',
      );
    }
  }

  Future<Map<String, String>?> getGoogleAccountToken() async {
    if (gUser != null) {
      final gAuth = await gUser!.authentication;
      return {
        'idToken': gAuth.idToken!,
        'accessToken': gAuth.accessToken!,
      };
    }

    return null;
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.accessToken == null) return;

    final OAuthCredential credential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    await auth
        .signInWithCredential(credential)
        .then((UserCredential userCredential) {
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      }
    });
  }

  Future<void> signInWithPhoneNumber({
    required BuildContext context,
    required String phoneNumber,
    Map<String, dynamic>? userMetaData,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: '+84${phoneNumber.substring(1)}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException error) {
        if (error.code == 'network-request-failed') {
          context.showErrorMessage(
            'Network error!',
          );
        }

        if (error.code == 'invalid-phone-number') {
          context.showErrorMessage('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
              userMetaData: userMetaData,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
