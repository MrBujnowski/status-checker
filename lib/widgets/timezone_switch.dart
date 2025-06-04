import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../ui_constants.dart';

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
    return Row(
      children: [
        const Icon(Icons.access_time, size: 18),
        const SizedBox(width: kPaddingSmall),
        Text(_formattedTime(), style: const TextStyle(fontSize: 13)),
        const SizedBox(width: kPaddingSmall),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Europe/Prague', label: Text('Prague')),
            ButtonSegment(value: 'UTC', label: Text('UTC')),
          ],
          selected: {widget.selectedTimezone},
          onSelectionChanged: (values) {
            if (values.isNotEmpty) widget.onChanged(values.first);
          },
        ),
      ],
    );
  }
}
