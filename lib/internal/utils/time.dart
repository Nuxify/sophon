import 'package:intl/intl.dart';
import 'package:sophon/internal/enums.dart';

String formatTimestamp(int unixSeconds, TimestampFormat format) {
  final DateTime timestamp =
      DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true)
          .toLocal();

  final DateTime now = DateTime.now();

  switch (format) {
    case TimestampFormat.timeAndDate:
      final String formatted =
          DateFormat('h:mma MMM d, y').format(timestamp); // 4:00PM Jan 24, 2025
      return formatted;

    case TimestampFormat.dateOnly:
      return DateFormat('MMM d, y').format(timestamp); // Jan 24, 2025

    case TimestampFormat.relative:
      final Duration diff = now.difference(timestamp);

      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('h:mma MMM d, y')
          .format(timestamp); // fallback with new format
  }
}

String timeBasedGreeting() {
  final int hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return 'Good Morning,\n';
  } else if (hour >= 12 && hour < 17) {
    return 'Good Afternoon,\n';
  } else {
    return 'Good Evening,\n';
  }
}
