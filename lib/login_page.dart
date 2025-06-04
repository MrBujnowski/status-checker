import 'package:flutter/material.dart';
import 'auth/magic_link_service.dart';
import 'services/supabase_service.dart';
import 'models/url_entry.dart';
import 'widgets/timezone_switch.dart';
import 'widgets/page_status_row.dart';
import 'widgets/theme_switch.dart';
import 'ui_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseService supabaseService = SupabaseService();
  final TextEditingController emailController = TextEditingController();
  final MagicLinkService magicLinkService = MagicLinkService();

  String timezone = 'Europe/Prague';
  bool isLoading = false;
  String? message;

  Future<void> _sendLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    final String? error = await magicLinkService.sendMagicLink(email);
    setState(() {
      if (error == null) {
        message = 'Check your email and click the link to log in.';
      } else {
        message = error;
      }
      isLoading = false;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login / Registration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email. You don\'t need to register – just enter your email, we\'ll send you a login link.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _sendLink,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send magic link'),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: const TextStyle(color: Colors.green, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(),
        actions: [
          const ThemeSwitchWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingSmall),
            child: TimezoneSwitchWidget(
              selectedTimezone: timezone,
              onChanged: (tz) => setState(() => timezone = tz),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _showLoginDialog,
            tooltip: 'Login',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: kPaddingXLarge),
                FutureBuilder<List<UrlEntry>>(
                  future: supabaseService.loadPublicPages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: kPaddingXLarge),
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: kPaddingXLarge),
                        child: Text('No public pages', textAlign: TextAlign.center),
                      );
                    }
                    final publicPages = snapshot.data!;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: publicPages
                          .map((page) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: kPaddingXXLarge),
                                child: PageStatusRowWidget(page: page, timezone: timezone),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
