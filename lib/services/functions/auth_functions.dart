import 'package:appwrite/appwrite.dart';
import 'package:chat_app/auth/login.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/services/functions/firebase_functions.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Account account = Account(client);

class AuthServices extends ChangeNotifier {
  void signupUser(
      String email, String password, String name, BuildContext context) async {
    try {
      String id = const Uuid().v4();
      await account.create(
          userId: id, email: email, password: password, name: name);
      DatabaseService(uid: id).savingUserData(name, email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Sign up is success',
        ),
      ));
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  void signinUser(String email, String password, BuildContext context) async {
    try {
      await account.createEmailSession(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  void signoutUser(BuildContext context) async {
    try {
      await account.deleteSessions();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginForm()),
      );
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }
}
