import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('hh:mm a').format(date);
  }

  static String formatRelative(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(date);
  }
}
