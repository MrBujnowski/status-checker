import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/url_entry.dart';
import '../models/page_status.dart';
import '../services/supabase_service.dart';

class PageStatusRowWidget extends StatelessWidget {
  final UrlEntry page;
  final String timezone;
  final SupabaseService supabaseService = SupabaseService();

  PageStatusRowWidget({super.key, required this.page, required this.timezone});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        supabaseService.loadPageDailyStatuses(page.id, timezone: timezone),
        supabaseService.loadPageLatestStatus(page.id, timezone: timezone),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Text('Chyba při načítání statusů.');
        }

        final List<PageStatus> statuses = snapshot.data![0] as List<PageStatus>;
        final PageStatus? latestStatus = snapshot.data![1] as PageStatus?;

        Map<String, String> statusByDay = {
          for (var s in statuses) s.day: s.status,
        };

        final now = DateTime.now();
        List<String> prevDays = List.generate(29, (i) {
          final d = now.subtract(Duration(days: 29 - i));
          return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        });
        final today = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        // Seznam dvojic: (status, day)
        final ovals = [
          ...prevDays.map((day) => (statusByDay[day] ?? 'grey', day)),
          (latestStatus?.status ?? 'grey', today),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              page.urlName?.isNotEmpty == true ? page.urlName! : page.url,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              page.url,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final tuple in ovals)
                  _StatusOval(status: tuple.$1, day: tuple.$2),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusOval extends StatelessWidget {
  final String status;
  final String day;
  const _StatusOval({required this.status, required this.day});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'green':
        color = Colors.green;
        break;
      case 'red':
        color = Colors.red;
        break;
      case 'orange':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey.shade400;
    }

    // Převod YYYY-MM-DD na pěkný formát
    String formattedDate;
    try {
      final date = DateTime.parse(day);
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      formattedDate = day;
    }

    // Text statusu pro tooltip
    String statusText;
    switch (status) {
      case 'green':
        statusText = "No incidents";
        break;
      case 'red':
        statusText = "Major issues";
        break;
      case 'orange':
        statusText = "Some issues";
        break;
      default:
        statusText = "No data";
    }

    return Tooltip(
      message: "$formattedDate\n$statusText",
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      textStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.all(10),
      preferBelow: false,
      child: Container(
        width: 14,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}