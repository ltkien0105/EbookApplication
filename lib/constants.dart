import 'package:ebook_application/models/message.dart';
import 'package:flutter/material.dart';

//Cloud firestore
import 'package:cloud_firestore/cloud_firestore.dart';

//Firebase_auth
import 'package:firebase_auth/firebase_auth.dart';

//Firebase_auth
import 'package:firebase_storage/firebase_storage.dart';

//[auth] Firebase
FirebaseAuth auth = FirebaseAuth.instance;

//[cloud_firestore] Firebase
FirebaseFirestore firestore = FirebaseFirestore.instance;

//[cloud_storage] Firebase
FirebaseStorage storage = FirebaseStorage.instance;

//Google API key
String androidApiKey = 'AIzaSyCjG2bvfNfXnyQgK8Q88HR8w2bnekD0f_E';
String iosApiKey = 'AIzaSyCK7sunNqV6dUfswngY1ALs5IaxbEawNAY';

//OpenAI API key
String openAiAPIKey = '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';

//Message History
final List<Message> messageHistory = [];

//Custom snackbar
extension ShowSnackbar on BuildContext {
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showInfoMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
