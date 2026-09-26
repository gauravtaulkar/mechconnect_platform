import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MechConnectApp());
}

class MechConnectApp extends StatelessWidget {
  const MechConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // FIX: used to jump straight to LoginScreen every launch. Now we check
      // for a persisted session first (see splash_screen.dart) and route
      // straight to the right home screen for that user's role.
      home: const SplashScreen(),
    );
  }
}
