import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'mechanic_dashboard_screen.dart';

// NEW: didn't exist before. Restores a persisted session (if any) and sends
// the user straight to the right screen for their role, instead of always
// starting at the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final session = await ApiService.restoreSession();
    if (!mounted) return;

    Widget destination;
    if (session == null) {
      destination = const LoginScreen();
    } else if (session.isMechanic) {
      destination = const MechanicDashboardScreen();
    } else {
      destination = const HomeScreen();
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.orange)),
    );
  }
}
