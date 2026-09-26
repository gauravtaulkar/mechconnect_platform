import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'mechanic_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedRole = 'USER';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields');
      return;
    }
    // FIX: original form had no way to catch a typo'd password — you'd only
    // find out at your next login attempt. Added a confirm-password check.
    if (passwordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final session = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        selectedRole,
      );
      if (!mounted) return;
      final destination = session.isMechanic
          ? const MechanicDashboardScreen()
          : const HomeScreen();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => destination));
    } on ApiException catch (e) {
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
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                  labelText: 'Role', border: OutlineInputBorder()),
              items: ['USER', 'MECHANIC']
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            if (selectedRole == 'MECHANIC') ...[
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "As a mechanic you'll set up your shop details right after registering.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Register',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
