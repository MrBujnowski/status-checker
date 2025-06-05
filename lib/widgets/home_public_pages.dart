import 'package:flutter/material.dart';
import '../models/url_entry.dart';
import 'page_status_row.dart';

class HomePublicPages extends StatelessWidget {
  final List<UrlEntry> publicPages;
  final String timezone;

  const HomePublicPages({
    super.key,
    required this.publicPages,
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: publicPages
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: PageStatusRowWidget(
                  page: entry,
                  timezone: timezone,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
