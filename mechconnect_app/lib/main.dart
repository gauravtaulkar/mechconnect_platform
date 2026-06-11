import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            'MechConnect',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}