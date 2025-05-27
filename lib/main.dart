// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using values from environment variables passed via --dart-define
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Handling magic link callback
  try {
    await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
  } catch (_) {
    // Ignore AuthException if token is absent
  }

  runApp(const MyApp());
}
