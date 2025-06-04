import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/auth_gate.dart';
import 'theme_notifier.dart';
import 'ui_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Status Checker',
      themeMode: themeNotifier.mode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme:
            GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.light).textTheme),
        colorScheme: const ColorScheme.light().copyWith(background: Colors.white),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme:
            GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        colorScheme: const ColorScheme.dark().copyWith(background: Colors.black),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
