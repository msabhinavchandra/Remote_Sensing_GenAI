import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Pages/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RemSenseAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF121C38)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
