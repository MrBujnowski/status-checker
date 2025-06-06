import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.inter(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => _openUrl('https://github.com/Narrativva-Labs/status-checker'),
              icon: const Icon(Icons.star_border, size: 18),
              label: Text('Star us on GitHub', style: textStyle),
            ),
            TextButton(
              onPressed: () => _openUrl('https://labs.narrativva.com'),
              child: Text('Built by Narrativva Labs', style: textStyle),
            ),
            TextButton(
              onPressed: () => _openUrl('https://narrativva.com'),
              child: Text('\u00a9 2025 Narrativva', style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}
