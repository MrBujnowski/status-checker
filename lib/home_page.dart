// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/url_entry.dart';
import 'models/user_settings.dart';
import 'services/supabase_service.dart';
import 'widgets/home_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService supabaseService = SupabaseService();

  List<UrlEntry> publicPages = [];
  List<UrlEntry> userPages = [];
  UserSettings? currentUserSettings;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final user = supabase.auth.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });

    try {
      final publicEntries = await supabaseService.loadPublicPages();

      List<UrlEntry> userEntries = [];
      UserSettings? settings;
      if (user != null) {
        userEntries = await supabaseService.loadUserPages();
        settings = await supabaseService.loadUserSettings();
      }

      setState(() {
        publicPages = publicEntries;
        userPages = userEntries;
        currentUserSettings = settings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addUserUrl(String url, String? urlName) async {
    if (url.trim().isEmpty) return;
    // Corrected call: only pass url and urlName (named parameter)
    await supabaseService.addUserPage(url.trim(), urlName: urlName?.trim());
    await _loadAllData();
  }

  Future<void> _deleteUserUrl(String pageId) async {
    await supabaseService.deleteUserPage(pageId);
    await _loadAllData();
  }

  // New method to handle editing a URL
  Future<void> _editUserUrl(String pageId, String newUrl, String? newUrlName) async {
    if (newUrl.trim().isEmpty) return;
    await supabaseService.updateUserPage(pageId, newUrl.trim(), newUrlName: newUrlName?.trim());
    await _loadAllData();
  }

  Future<void> _updateUserSettings({String? discordWebhookUrl, bool? isAdmin}) async {
    await supabaseService.upsertUserSettings(
      discordWebhookUrl: discordWebhookUrl,
      isAdmin: isAdmin,
    );
    await _loadAllData();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Checker'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _signOut,
            ),
        ],
      ),
      body: HomeContent(
        isLoggedIn: isLoggedIn,
        publicPages: publicPages,
        userPages: userPages,
        onAddUrl: _addUserUrl,
        onDeleteUrl: _deleteUserUrl,
        onEditUrl: _editUserUrl, // Pass the new edit function
        currentUserSettings: currentUserSettings,
        onUpdateUserSettings: _updateUserSettings,
      ),
    );
  }
}
