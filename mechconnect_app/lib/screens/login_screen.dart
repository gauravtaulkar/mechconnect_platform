import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController connects a text field to our code
  // when user types in the field, controller captures it
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false; // shows spinner when request is in progress
  String errorMessage = ''; // shows error if login fails

  Future<void> login() async {
    setState(() {
      isLoading = true;  // show spinner
      errorMessage = '';
    });

    try {
      // call our ApiService login method
      final result = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result.containsKey('token')) {
        // save token for future requests
        ApiService.setToken(result['token']);

        // navigate to home screen, remove login from stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => errorMessage = result['error'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      setState(() => isLoading = false); // hide spinner
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // app title
            const Text(
              'MechConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Login to continue'),
            const SizedBox(height: 32),

            // email field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // password field
            TextField(
              controller: passwordController,
              obscureText: true, // hides password characters
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // error message — only shows if errorMessage is not empty
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            // login button — shows spinner while loading
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // link to register screen
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}