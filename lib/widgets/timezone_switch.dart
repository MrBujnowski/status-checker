import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class TimezoneSwitchWidget extends StatefulWidget {
  final String selectedTimezone;
  final void Function(String timezone) onChanged;

  const TimezoneSwitchWidget({
    super.key,
    required this.selectedTimezone,
    required this.onChanged,
  });

  @override
  State<TimezoneSwitchWidget> createState() => _TimezoneSwitchWidgetState();
}

class _TimezoneSwitchWidgetState extends State<TimezoneSwitchWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _pragueTime(DateTime utc) {
    int year = utc.year;
    DateTime lastSunday(int month) {
      var date = DateTime.utc(year, month + 1, 1).subtract(const Duration(days: 1));
      while (date.weekday != DateTime.sunday) {
        date = date.subtract(const Duration(days: 1));
      }
      return date;
    }

    final start = DateTime.utc(year, 3, lastSunday(3).day, 1); // DST start 01:00 UTC
    final end = DateTime.utc(year, 10, lastSunday(10).day, 1); // DST end 01:00 UTC
    final isDst = utc.isAfter(start) && utc.isBefore(end);
    final offset = isDst ? 2 : 1;
    return utc.add(Duration(hours: offset));
  }

  String _formattedTime() {
    DateTime utc = DateTime.now().toUtc();
    DateTime displayTime =
        widget.selectedTimezone == 'UTC' ? utc : _pragueTime(utc);
    return DateFormat('HH:mm').format(displayTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.44),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 8),
          Text(
            _formattedTime(),
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 14),
          SegmentedButton<String>(
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 9)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              textStyle: WidgetStateProperty.all(
                GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            segments: const [
              ButtonSegment(
                value: 'Europe/Prague',
                label: SizedBox(
                  width: 52, // zajistí, že "Prague" zůstane na jednom řádku
                  child: Text(
                    'Prague',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ButtonSegment(
                value: 'UTC',
                label: SizedBox(
                  width: 40,
                  child: Text(
                    'UTC',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            selected: {widget.selectedTimezone},
            onSelectionChanged: (values) => widget.onChanged(values.first),
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}
