// Main dashboard page showing tracked URLs and their status.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService supabaseService = SupabaseService();

  final TextEditingController _urlController = TextEditingController();

  List<String> publicPages = [];
  List<String> userPages = [];

  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final user = supabase.auth.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });

    try {
      final publicUrls = await supabaseService.loadPublicPages();

      List<String> userUrls = [];
      if (user != null) {
        final rawUserUrls = await supabaseService.loadUserPages();
        userUrls = rawUserUrls.cast<String>();
      }

      setState(() {
        publicPages = publicUrls.cast<String>();
        userPages = userUrls;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addUserUrl(String url) async {
    if (url.trim().isEmpty) return;
    await supabaseService.addUserPage(url.trim());
    _urlController.clear();
    _loadPages();
  }

  Future<void> _deleteUserUrl(String url) async {
    await supabaseService.deleteUserPage(url);
    _loadPages();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isLoggedIn) ...[
            const Text(
              "Your tracked pages",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...userPages.map(
              (url) => ListTile(
                title: Text(url),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUserUrl(url),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Add new URL',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _addUserUrl,
            ),
            const Divider(height: 32),
          ],
          Text(
            isLoggedIn ? "Example projects" : "Preview (not logged in)",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...publicPages.map((url) => ListTile(title: Text(url))),
        ],
      ),
    );
  }
}
