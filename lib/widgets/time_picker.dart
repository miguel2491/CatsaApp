import 'package:flutter/material.dart';

class TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const TimePickerTile({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = time != null ? time!.format(context) : '--:--';
    return ListTile(
      title: Text(label),
      subtitle: Text(timeStr),
      trailing: Icon(Icons.access_time),
      onTap: onTap,
    );
  }
}
