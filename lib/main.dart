// Entry point of the Status Checker app.
// Launches the application using runApp.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final Stream<AuthState> _authStream;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    // Determine initial state
    _isLoggedIn = supabase.auth.currentUser != null;

    // Listen for auth state changes
    _authStream = supabase.auth.onAuthStateChange;
    _authStream.listen((data) {
      final user = data.session?.user;
      setState(() {
        _isLoggedIn = user != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Checker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
