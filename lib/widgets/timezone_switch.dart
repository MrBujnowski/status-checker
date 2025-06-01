import 'package:flutter/material.dart';

class TimezoneSwitchWidget extends StatelessWidget {
  final String selectedTimezone;
  final void Function(String timezone) onChanged;

  const TimezoneSwitchWidget({
    super.key,
    required this.selectedTimezone,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 18),
        const SizedBox(width: 4),
        ToggleButtons(
          isSelected: [
            selectedTimezone == 'Europe/Prague',
            selectedTimezone == 'UTC',
          ],
          onPressed: (idx) {
            if (idx == 0) onChanged('Europe/Prague');
            if (idx == 1) onChanged('UTC');
          },
          borderRadius: BorderRadius.circular(6),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Prague', style: TextStyle(fontSize: 13)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('UTC', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}
