import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/url_entry.dart';
import 'models/user_settings.dart';
import 'services/supabase_service.dart';
import 'services/discord_service.dart';
import 'login_page.dart';
import 'widgets/home_content.dart';
import 'widgets/timezone_switch.dart';

class HomePage extends StatefulWidget {
  final void Function() onToggleTheme;
  final ThemeMode themeMode;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseService supabaseService = SupabaseService();
  final DiscordService discordService = DiscordService();

  List<UrlEntry> publicPages = [];
  List<UrlEntry> userPages = [];
  UserSettings? currentUserSettings;
  bool isLoading = true;
  bool isLoggedIn = false;
  String timezone = 'Europe/Prague';

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

  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
  }

  Future<void> _addUserUrl(String url, String? urlName) async {
    String finalUrl = url.trim();

    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    if (!isValidUrl(finalUrl)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The entered URL is not valid.')),
        );
      }
      return;
    }

    final exists = userPages.any((entry) => entry.url == finalUrl);
    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This page has already been added.')),
        );
      }
      return;
    }

    await supabaseService.addUserPage(finalUrl, urlName: urlName?.trim());
    await _loadAllData();
    await _logToDiscord("**Page added:** ${urlName ?? finalUrl}");
  }

  Future<void> _deleteUserUrl(String pageId) async {
    final deleted = userPages.firstWhere(
      (p) => p.id == pageId,
      orElse: () => UrlEntry(
        id: '',
        url: '',
        isPublic: false,
        createdAt: DateTime.now(),
      ),
    );
    await supabaseService.deleteUserPage(pageId);
    await _loadAllData();
    await _logToDiscord("**Page deleted:** ${deleted.urlName ?? deleted.url}");
  }

  Future<void> _editUserUrl(String pageId, String newUrl, String? newUrlName) async {
    await supabaseService.updateUserPage(pageId, newUrl.trim(), newUrlName: newUrlName?.trim());
    await _loadAllData();
    await _logToDiscord("**Page updated:** ${newUrlName ?? newUrl}");
  }

  Future<void> _updateUserSettings({String? discordWebhookUrl, bool? isAdmin}) async {
    await supabaseService.upsertUserSettings(
      discordWebhookUrl: discordWebhookUrl,
      isAdmin: isAdmin,
    );
    await _loadAllData();
  }

  Future<String?> _loadDiscordWebhookUrl() async {
    final settings = await supabaseService.loadUserSettings();
    return settings?.discordWebhookUrl;
  }

  Future<void> _logToDiscord(String message) async {
    final webhook = currentUserSettings?.discordWebhookUrl;
    if (webhook != null && webhook.trim().isNotEmpty) {
      try {
        await discordService.sendSimpleMessage(webhook, message);
      } catch (e) {
        print('Failed to send message to Discord: $e');
      }
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            onToggleTheme: widget.onToggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // === ŽÁDNÝ APPBAR, jen horní řádek jako na loginu ===
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Row(
              children: [
                const Spacer(),
                TimezoneSwitchWidget(
                  selectedTimezone: timezone,
                  onChanged: (tz) => setState(() => timezone = tz),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    size: 25,
                  ),
                  onPressed: widget.onToggleTheme,
                  tooltip: 'Switch light/dark theme',
                ),
                if (isLoggedIn)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: _signOut,
                  ),
              ],
            ),
          ),
        ),
      ),
      body: HomeContent(
        isLoggedIn: isLoggedIn,
        publicPages: publicPages,
        userPages: userPages,
        onAddUrl: _addUserUrl,
        onDeleteUrl: _deleteUserUrl,
        onEditUrl: _editUserUrl,
        currentUserSettings: currentUserSettings,
        onUpdateUserSettings: _updateUserSettings,
        onLoadDiscordWebhookUrl: _loadDiscordWebhookUrl,
        timezone: timezone,
      ),
    );
  }
}
