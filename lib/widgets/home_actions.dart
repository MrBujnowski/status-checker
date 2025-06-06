import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/discord_service.dart';

class HomeActions extends StatelessWidget {
  final bool isLoggedIn;
  final Future<void> Function(String url, String? urlName) onAddUrl;
  final Future<void> Function({String? discordWebhookUrl, bool? isAdmin}) onUpdateUserSettings;
  final Future<String?> Function() onLoadDiscordWebhookUrl;

  const HomeActions({
    super.key,
    required this.isLoggedIn,
    required this.onAddUrl,
    required this.onUpdateUserSettings,
    required this.onLoadDiscordWebhookUrl,
  });

  // ======= ADD PAGE DIALOG =======
  void _showAddPageDialog(BuildContext context) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withOpacity(0.28),
            width: 2.0,
          ),
        ),
        elevation: 14,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 6),
        title: Text(
          'Add Page',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(left: 28, right: 28, bottom: 8, top: 2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "Add a page for monitoring.",
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Page Name (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Page URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFbe1931),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (urlController.text.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      await onAddUrl(
                        urlController.text.trim(),
                        nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Page added.')),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======= DISCORD WEBHOOK DIALOG + VERIFICATION =======
  void _showDiscordWebhookDialog(BuildContext context) async {
    final String currentWebhook =
        (await onLoadDiscordWebhookUrl()) ?? "";
    final webhookController = TextEditingController(text: currentWebhook);
    final discordService = DiscordService();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withOpacity(0.28),
            width: 2.0,
          ),
        ),
        elevation: 14,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 6),
        title: Text(
          'Discord Webhook URL',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.only(left: 28, right: 28, bottom: 8, top: 2),
        content: TextField(
          controller: webhookController,
          decoration: InputDecoration(
            labelText: 'Webhook URL',
            hintText: 'Enter your Discord webhook URL',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
          keyboardType: TextInputType.url,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 18),
              if (currentWebhook.isNotEmpty) ...[
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await onUpdateUserSettings(discordWebhookUrl: null);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Webhook deleted')),
                        );
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 18),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5865F2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final url = webhookController.text.trim();
                    Navigator.of(dialogContext).pop();
                    if (url.isNotEmpty && url != currentWebhook) {
                      final sent = await discordService.sendVerificationCode(url);
                      if (!sent) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send verification code')),
                          );
                        }
                        return;
                      }

                      final codeController = TextEditingController();
                      final verified = await showDialog<bool>(
                        context: context,
                        builder: (verifyContext) => AlertDialog(
                          title: const Text('Enter Verification Code'),
                          content: TextField(
                            controller: codeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Code'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(verifyContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (discordService.verifyCode(codeController.text.trim())) {
                                  Navigator.of(verifyContext).pop(true);
                                } else {
                                  ScaffoldMessenger.of(verifyContext).showSnackBar(
                                    const SnackBar(content: Text('Invalid code')),
                                  );
                                }
                              },
                              child: const Text('Verify'),
                            ),
                          ],
                        ),
                      );

                      if (verified == true) {
                        await onUpdateUserSettings(discordWebhookUrl: url);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Webhook saved')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Verify & Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Narrativva Status",
              style: GoogleFonts.epilogue(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 12),
            // OnlineDot sem!
          ],
        ),
        const SizedBox(height: 14),
        Text(
          "Live status and uptime monitoring for all Narrativva apps and websites.",
          style: GoogleFonts.inter(
            fontSize: 17,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.56),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        if (isLoggedIn) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Page'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFbe1931),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddPageDialog(context),
              ),
              const SizedBox(width: 18),
              FilledButton.icon(
                icon: const FaIcon(FontAwesomeIcons.discord, color: Colors.white, size: 20),
                label: const Text('Set Discord'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5865F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showDiscordWebhookDialog(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
