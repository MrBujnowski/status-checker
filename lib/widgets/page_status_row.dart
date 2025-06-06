import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          return const Text('Error loading statuses.');
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

        final ovals = [
          ...prevDays.map((day) => (statusByDay[day] ?? 'grey', day)),
          (latestStatus?.status ?? 'grey', today),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 22), // větší mezery mezi bloky
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                page.urlName?.isNotEmpty == true ? page.urlName! : page.url,
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                page.url,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  final ovalWidth = isNarrow ? 4.0 : 15.0;
                  final ovalHeight = isNarrow ? 20.0 : 28.0;

                  Widget row = SizedBox(
                    height: ovalHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        for (final tuple in ovals)
                          _StatusOval(
                            status: tuple.$1,
                            day: tuple.$2,
                            width: ovalWidth,
                            height: ovalHeight,
                          ),
                      ],
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        row,
                        const SizedBox(height: 4),
                        Text(
                          'Last 30 days',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    );
                  }

                  return row;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusOval extends StatefulWidget {
  final String status;
  final String day;
  final double width;
  final double height;
  const _StatusOval({
    required this.status,
    required this.day,
    this.width = 15,
    this.height = 28,
  });

  @override
  State<_StatusOval> createState() => _StatusOvalState();
}

class _StatusOvalState extends State<_StatusOval> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (widget.status) {
      case 'green':
        color = const Color(0xFF34D399); // emerald green
        break;
      case 'red':
        color = const Color(0xFFEF4444); // modern red
        break;
      case 'orange':
        color = const Color(0xFFF59E42); // modern orange
        break;
      default:
        color = Colors.grey.shade400;
    }

    String formattedDate;
    try {
      final date = DateTime.parse(widget.day);
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      formattedDate = widget.day;
    }

    String statusText;
    switch (widget.status) {
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: "$formattedDate\n$statusText",
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.94),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: false,
        waitDuration: Duration.zero, // tooltip hned
        child: Transform.translate(
          offset: _hovered ? const Offset(0, -2) : Offset.zero, // animace nahoru
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 1.3),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.36),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
