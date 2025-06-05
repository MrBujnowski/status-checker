import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/auth_gate.dart';

class StatusCheckerApp extends StatefulWidget {
  const StatusCheckerApp({super.key});

  @override
  State<StatusCheckerApp> createState() => _StatusCheckerAppState();
}

class _StatusCheckerAppState extends State<StatusCheckerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  // Přepínání světlo/tma
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Globální ThemeData - moderní FlexColorScheme + Google Fonts
    return MaterialApp(
      title: 'Status Checker',
      debugShowCheckedModeBanner: false,
      // Moderní světlý theme (Material 3, krásné barvy, radiusy, fonty)
      theme: FlexThemeData.light(
        scheme: FlexScheme.hippieBlue, // Změň klidně na Aqua, Sakura apod.
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          cardRadius: 20,
          elevatedButtonRadius: 16,
          inputDecoratorRadius: 12,
          defaultRadius: 16,
          blendOnLevel: 12,
        ),
      ).copyWith(
        textTheme: GoogleFonts.interTextTheme(),
        primaryTextTheme: GoogleFonts.epilogueTextTheme(),
      ),
      // Moderní tmavý theme (stejná schéma)
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.hippieBlue,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        subThemesData: const FlexSubThemesData(
          cardRadius: 20,
          elevatedButtonRadius: 16,
          inputDecoratorRadius: 12,
          defaultRadius: 16,
          blendOnLevel: 24,
        ),
      ).copyWith(
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        primaryTextTheme: GoogleFonts.epilogueTextTheme(ThemeData.dark().textTheme),
      ),
      // Výchozí mód (podle systému)
      themeMode: _themeMode,
      // Home je AuthGate, dál předáváš theme přepínač a mode
      home: AuthGate(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
