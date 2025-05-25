// Login page allowing users to sign in via magic link (email)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> _signInWithMagicLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      await supabase.auth.signInWithOtp(email: email);
      setState(() {
        message = 'Check your email for the login link.';
      });
    } catch (e) {
      setState(() {
        message = 'Login failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in via Magic Link',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _signInWithMagicLink,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send magic link'),
            ),
            const SizedBox(height: 16),
            if (message != null) Text(message!),
          ],
        ),
      ),
    );
  }
}
