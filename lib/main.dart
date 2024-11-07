import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Pages/SplashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
// Import the DefaultFirebaseOptions class
import 'firebase_options.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "Backend/.env"); // Load the .env file
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 // await dotenv.load(fileName: "Backend/.env"); // Load the .env file
  runApp(MyApp());
}

Future<String> _getIpAddress() async {
  final info = NetworkInfo();
  String? wifiIPv4;

  if (await Permission.locationWhenInUse.request().isGranted) {
    try {
      wifiIPv4 = await info.getWifiIP();
    } catch (e) {
      wifiIPv4 = 'Failed to get IP';
    }
  } else {
    wifiIPv4 = 'Permission denied';
  }

  return wifiIPv4 ?? 'Unknown IP';
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
      home: SplashScreen(),
    );
  }
}
