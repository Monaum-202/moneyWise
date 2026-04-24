import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat.yMd().format(date);
  }
}
