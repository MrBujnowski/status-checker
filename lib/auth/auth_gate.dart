import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home_page.dart';
import '../login_page.dart';

class AuthGate extends StatefulWidget {
  final void Function() onToggleTheme;
  final ThemeMode themeMode;

  const AuthGate({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleInitialSession();
  }

  Future<void> _handleInitialSession() async {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
    } catch (e) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return HomePage(
        onToggleTheme: widget.onToggleTheme,
        themeMode: widget.themeMode,
      );
    } else {
      return LoginPage(
        onToggleTheme: widget.onToggleTheme,
        themeMode: widget.themeMode,
      );
    }
  }
}
