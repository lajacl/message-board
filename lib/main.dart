import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:message_board/auth.dart';
import 'package:message_board/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Chatboards - Message Boards';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
