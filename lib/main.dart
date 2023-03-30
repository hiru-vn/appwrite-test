import 'package:appwrite/appwrite.dart';
import 'package:chat_app/services/functions/auth_functions.dart';
import 'package:chat_app/services/functions/firebase_functions.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/login.dart';
import '/pages/home.dart';

Client client = Client();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  client
      .setEndpoint('http://192.168.1.14/v1') // Your Appwrite Endpoint
      .setProject('64216df64488b8f2d367') // Your project ID
      .setSelfSigned();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<AuthServices>(create: (_) => AuthServices()),
          Provider<DatabaseService>(create: (_) => DatabaseService()),
        ],
        child: const LoginForm(),
      ),
    );
  }
}
