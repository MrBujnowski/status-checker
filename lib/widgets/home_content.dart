import 'package:flutter/material.dart';
import '../models/url_entry.dart';
import '../models/user_settings.dart';
import '../services/discord_service.dart';

class HomeContent extends StatefulWidget {
  final bool isLoggedIn;
  final List<UrlEntry> publicPages;
  final List<UrlEntry> userPages;
  final Future<void> Function(String url, String? urlName) onAddUrl;
  final Future<void> Function(String pageId) onDeleteUrl;
  final Future<void> Function(String pageId, String newUrl, String? newUrlName) onEditUrl;
  final UserSettings? currentUserSettings;
  final Future<void> Function({String? discordWebhookUrl, bool? isAdmin}) onUpdateUserSettings;

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
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _urlNameController = TextEditingController();
  final TextEditingController _webhookController = TextEditingController();

  final DiscordService _discordService = DiscordService();
  String? _pendingWebhookUrl;

  @override
  void initState() {
    super.initState();
    if (widget.currentUserSettings != null && widget.currentUserSettings!.discordWebhookUrl != null) {
      _webhookController.text = widget.currentUserSettings!.discordWebhookUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlNameController.dispose();
    _webhookController.dispose();
    super.dispose();
  }

  void _submitUrl() {
    final url = _urlController.text.trim();
    final urlName = _urlNameController.text.trim();
    if (url.isNotEmpty) {
      widget.onAddUrl(url, urlName.isEmpty ? null : urlName);
      _urlController.clear();
      _urlNameController.clear();
    }
  }

  Future<void> _startDiscordWebhookVerification() async {
    final webhookUrl = _webhookController.text.trim();
    if (webhookUrl.isEmpty) return;

    final ok = await _discordService.sendVerificationCode(webhookUrl);
    if (ok) {
      _pendingWebhookUrl = webhookUrl;
      _showVerificationDialog();
    } else {
      _showError('Sending code to Discord failed! Check the webhook URL.');
    }
  }

  void _showVerificationDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Verify your Discord webhook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We sent a 4-digit code to your Discord webhook.\nCopy it from Discord and enter it:'),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(labelText: 'Verification code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Verify'),
            onPressed: () async {
              if (_discordService.verifyCode(codeController.text.trim())) {
                Navigator.of(context).pop();
                await widget.onUpdateUserSettings(discordWebhookUrl: _pendingWebhookUrl);
                _showInfo('Webhook verified and saved!');
              } else {
                _showError('Invalid code. Try again.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _showEditDialog(UrlEntry entry) async {
    final TextEditingController editUrlController = TextEditingController(text: entry.url);
    final TextEditingController editUrlNameController = TextEditingController(text: entry.urlName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit URL'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: editUrlNameController,
                  decoration: const InputDecoration(labelText: 'Page Name (Optional)'),
                ),
                TextField(
                  controller: editUrlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                widget.onEditUrl(
                  entry.id,
                  editUrlController.text.trim(),
                  editUrlNameController.text.trim().isEmpty ? null : editUrlNameController.text.trim(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.isLoggedIn) ...[
          const Text(
            "Your tracked pages",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.userPages.isEmpty)
            const Text('No pages tracked yet. Add one below!'),
          ...widget.userPages.map(
            (entry) => ListTile(
              title: Text(entry.urlName ?? entry.url),
              subtitle: entry.urlName != null ? Text(entry.url) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(entry),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.onDeleteUrl(entry.id),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlNameController,
            decoration: const InputDecoration(
              labelText: 'Page Name (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL to track',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitUrl(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitUrl,
            child: const Text('Add URL'),
          ),
          const Divider(height: 32),

          const Text(
            "Discord Webhook Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _webhookController,
            decoration: const InputDecoration(
              labelText: 'Discord Webhook URL',
              hintText: 'Enter URL for notifications',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _startDiscordWebhookVerification,
            child: const Text('Verify & Save Webhook'),
          ),
          const Divider(height: 32),
        ],

        Text(
          widget.isLoggedIn ? "Example projects" : "Preview (not logged in)",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.publicPages.map((entry) => ListTile(
          title: Text(entry.urlName ?? entry.url),
          subtitle: entry.urlName != null ? Text(entry.url) : null,
        )),
      ],
    );
  }
}
