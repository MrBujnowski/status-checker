// Defines MaterialApp, theme, and routing.

import 'package:flutter/material.dart';
import 'auth/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Checker',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}
