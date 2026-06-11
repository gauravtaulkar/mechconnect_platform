import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // dropdown value — USER or MECHANIC
  String selectedRole = 'USER';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> register() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole,
      );

      if (result.containsKey('token')) {
        ApiService.setToken(result['token']);

        // go to home screen after register
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => errorMessage = result['error'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      setState(() => isLoading = false);