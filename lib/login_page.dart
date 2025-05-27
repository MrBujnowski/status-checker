// lib/login_page.dart
import 'package:flutter/material.dart';

import 'auth/magic_link_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final MagicLinkService magicLinkService = MagicLinkService();

  bool isLoading = false;
  String? message;

  Future<void> _sendLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    // Explicitly declare the type to help the compiler
    final String? error = await magicLinkService.sendMagicLink(email);
    setState(() {
      if (error == null) {
        message = 'Zkontroluj email a klikni na odkaz pro přihlášení.';
      } else {
        message = error;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Přihlášení')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Přihlášení přes Magic Link',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _sendLink,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Odeslat odkaz'),
            ),
            const SizedBox(height: 16),
            if (message != null) Text(message!),
          ],
        ),
      ),
    );
  }
}