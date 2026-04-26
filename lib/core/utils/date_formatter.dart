import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }
}
