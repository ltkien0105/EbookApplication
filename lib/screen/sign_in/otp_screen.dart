import 'package:ebook_application/screen/sign_in/components/body_otp.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({
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
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: BodyOtp(
        phoneNumber: phoneNumber,
        verificationId: verificationId,
        resendToken: resendToken,
      ),
    );
  }
}
