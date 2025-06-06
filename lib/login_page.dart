import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/magic_link_service.dart';
import 'services/supabase_service.dart';
import 'models/url_entry.dart';
import 'widgets/timezone_switch.dart';
import 'widgets/page_status_row.dart';
import 'widgets/online_dot.dart';

class LoginPage extends StatefulWidget {
  final void Function() onToggleTheme;
  final ThemeMode themeMode;
  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

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

  Future<void> _sendLink(StateSetter dialogSetState) async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    dialogSetState(() {
      isLoading = true;
      message = null;
    });

    final String? error = await magicLinkService.sendMagicLink(email);
    dialogSetState(() {
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
    builder: (context) => StatefulBuilder(
      builder: (context, dialogSetState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Colors.white.withOpacity(0.28),
              width: 2.0,
            ),
          ),
          elevation: 14,
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            'Login / Registration',
            style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w600, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your email. You don't need to register – just enter your email, we'll send you a login link.",
                  style:
                      GoogleFonts.inter(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mail_outline),
                    label: Text(
                      'Send magic link',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed:
                        isLoading ? null : () => _sendLink(dialogSetState),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.epilogue(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    style: GoogleFonts.inter(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pouze nahoře
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showLoginButton = constraints.maxWidth > 450;
                return Row(
                  children: [
                    const Spacer(),
                    TimezoneSwitchWidget(
                      selectedTimezone: timezone,
                      onChanged: (tz) => setState(() => timezone = tz),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        widget.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        size: 25,
                      ),
                      onPressed: widget.onToggleTheme,
                      tooltip: 'Switch light/dark theme',
                    ),
                    if (showLoginButton)
                      IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: _showLoginDialog,
                        tooltip: 'Login',
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // Scrollbar bude normálně vpravo, protože ListView scrolluje celé body
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Narrativva Status',
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.w800,
                            fontSize: 38,
                            letterSpacing: -1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 12),
                        const OnlineDot(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Live status and uptime monitoring for all Narrativva apps and websites.',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
              // --- public stránky ---
              FutureBuilder<List<UrlEntry>>(
                future: supabaseService.loadPublicPages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text(
                          'No public pages available.',
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final publicPages = snapshot.data!;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: publicPages
                            .map((page) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                                  child: PageStatusRowWidget(
                                    page: page,
                                    timezone: timezone,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}
