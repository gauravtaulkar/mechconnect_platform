import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'mechanic_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Enter your email and password');
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final session = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!mounted) return;
      // FIX: previously every login went to the same customer HomeScreen
      // regardless of role. A MECHANIC account now lands on its own
      // dashboard (view/manage bookings, edit shop) instead.
      final destination = session.isMechanic
          ? const MechanicDashboardScreen()
          : const HomeScreen();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => destination));
    } on ApiException catch (e) {
      // FIX: this now shows the backend's real reason (e.g. "Invalid email
      // or password") instead of a generic Internal Server Error / blank
      // message, now that the backend has a proper exception handler.
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage =
          'Could not reach the server. Check your connection and the '
          'address in lib/config/app_config.dart.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('MechConnect',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 8),
            const Text('Login to continue'),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              onSubmitted: (_) => login(),
              decoration: const InputDecoration(
                  labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Login',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
