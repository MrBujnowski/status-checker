import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/url_entry.dart';
import '../models/user_settings.dart';
import '../services/discord_service.dart';
import 'page_status_row.dart';

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
  final DiscordService _discordService = DiscordService();
  String? _pendingWebhookUrl;

  void _showAddPageDialog() {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Page'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Page Name (optional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Page URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                widget.onAddUrl(
                  urlController.text.trim(),
                  nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                );
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDiscordWebhookDialog() async {
    String? currentWebhook = await widget.onLoadDiscordWebhookUrl();
    if (!mounted) return;
    currentWebhook ??= "";
    final webhookController = TextEditingController(text: currentWebhook);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discord Webhook URL'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: webhookController,
            decoration: const InputDecoration(
              labelText: 'Webhook URL',
              hintText: 'Enter your Discord webhook URL',
            ),
            keyboardType: TextInputType.url,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('Verify & Save'),
            onPressed: () async {
              final url = webhookController.text.trim();
              if (url.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter the webhook URL')),
                );
                return;
              }
              if (url == currentWebhook && url.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Webhook is already saved and verified.')),
                  );
                });
                return;
              }
              Navigator.of(dialogContext).pop();
              final ok = await _discordService.sendVerificationCode(url);
              if (!mounted) return;
              if (ok) {
                _pendingWebhookUrl = url;
                _showVerificationDialog();
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to send verification code. Please check the URL.')),
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify your Discord webhook'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We sent a 4-digit code to your Discord webhook. Copy it from Discord and enter it here:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'Verification code'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('Verify & Save'),
            onPressed: () async {
              if (_discordService.verifyCode(codeController.text.trim())) {
                Navigator.of(dialogContext).pop();
                await widget.onUpdateUserSettings(discordWebhookUrl: _pendingWebhookUrl);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Webhook verified and saved!')),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid code. Please try again.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(String pageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete page?"),
        content: const SizedBox(
          width: 420,
          child: Text("Are you sure you want to delete this page? All logs and records for this page will also be deleted."),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      widget.onDeleteUrl(pageId);
    }
  }

  Future<void> _showEditDialog(UrlEntry entry) async {
    final TextEditingController editUrlController = TextEditingController(text: entry.url);
    final TextEditingController editUrlNameController = TextEditingController(text: entry.urlName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit page'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: editUrlNameController,
                    decoration: const InputDecoration(labelText: 'Page Name (optional)'),
                  ),
                  TextField(
                    controller: editUrlController,
                    decoration: const InputDecoration(labelText: 'Page URL'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
                Navigator.of(dialogContext).pop();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Page',
                onPressed: _showAddPageDialog,
              ),
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.discord,
                  color: Color(0xFF5865F2),
                  size: 24,
                ),
                tooltip: widget.currentUserSettings?.discordWebhookUrl != null
                    ? 'Edit Discord webhook'
                    : 'Set Discord webhook',
                onPressed: _showDiscordWebhookDialog,
              ),
            ],
          ),
          const Text(
            "My Pages",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.userPages.isEmpty)
            const Text('You have not added any pages yet.'),
          ...widget.userPages.map(
            (entry) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: PageStatusRowWidget(page: entry, timezone: widget.timezone),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(entry),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmDialog(entry.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 32),
        ],

        // PUBLIC PAGES BELOW
        const Text(
          "Public pages / Example projects",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.publicPages.map(
          (entry) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: PageStatusRowWidget(page: entry, timezone: widget.timezone),
            ),
          ),
        ),
      ],
    );
  }
}
