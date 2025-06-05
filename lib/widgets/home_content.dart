import 'package:flutter/material.dart';
import '../models/url_entry.dart';
import '../models/user_settings.dart';
import 'home_actions.dart';
import 'home_user_pages.dart';
import 'home_public_pages.dart';

class HomeContent extends StatefulWidget {
  final bool isLoggedIn;
  final List<UrlEntry> publicPages;
  final List<UrlEntry> userPages;
  final Future<void> Function(String url, String? urlName) onAddUrl;
  final Future<void> Function(String pageId) onDeleteUrl;
  final Future<void> Function(String pageId, String newUrl, String? newUrlName) onEditUrl;
  final UserSettings? currentUserSettings;
  final Future<void> Function({String? discordWebhookUrl, bool? isAdmin}) onUpdateUserSettings;
  final Future<String?> Function() onLoadDiscordWebhookUrl;
  final String timezone;

  const HomeContent({
    super.key,
    required this.isLoggedIn,
    required this.publicPages,
    required this.userPages,
    required this.onAddUrl,
    required this.onDeleteUrl,
    required this.onEditUrl,
    this.currentUserSettings,
    required this.onUpdateUserSettings,
    required this.onLoadDiscordWebhookUrl,
    required this.timezone,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.symmetric(
              vertical: constraints.maxWidth < 650 ? 36 : 70,
              horizontal: 0,
            ),
            children: [
              Center(
                child: Column(
                  children: [
                    HomeActions(
                      isLoggedIn: widget.isLoggedIn,
                      onAddUrl: widget.onAddUrl,
                      onLoadDiscordWebhookUrl: widget.onLoadDiscordWebhookUrl,
                      onUpdateUserSettings: widget.onUpdateUserSettings,
                    ),
                    if (widget.isLoggedIn)
                      HomeUserPages(
                        userPages: widget.userPages,
                        onEditUrl: widget.onEditUrl,
                        onDeleteUrl: widget.onDeleteUrl,
                        timezone: widget.timezone,
                      ),
                  ],
                ),
              ),
              Center(
                child: HomePublicPages(
                  publicPages: widget.publicPages,
                  timezone: widget.timezone,
                ),
              ),
              const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }
}
