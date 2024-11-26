import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
// Import the DefaultFirebaseOptions class
import 'firebase_options.dart';

import '../Pages/MyHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "Backend/.env"); // Load existing .env

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Retrieve the IP address and set it in dotenv
  // Set IP address to dotenv environment variable

  runApp(MyApp()); // Pass IP directly to MyApp if needed
}

//Backend\.env
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
      home: const MyHomePage(title: 'Login Page'),
    );
  }
}
