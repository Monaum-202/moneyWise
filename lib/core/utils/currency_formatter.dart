import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String getSymbol(String code) {
    switch (code) {
      case 'BDT': return '৳';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'INR': return '₹';
      default: return code;
    }
  }

  static String format(double amount, {String? code, bool showSymbol = true}) {
    final formatter = NumberFormat.decimalPattern();
    final formatted = formatter.format(amount);
    
    if (!showSymbol) return formatted;
    
    final symbol = code != null ? getSymbol(code) : '';
    return '$symbol$formatted';
  }
}
