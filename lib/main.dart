import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Ak Firebase ešte nie je nakonfigurovaný, aplikácia môže zlyhať pri volaní Firebase služieb.
  }

  runApp(const NestoryApp());
}

class NestoryApp extends StatelessWidget {
  const NestoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
