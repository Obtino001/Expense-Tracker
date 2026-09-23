import 'package:intl/intl.dart';

class Formatters {
  Formatters._();
  static String currencyCode = 'USD';
  static String get currencySymbol => switch (currencyCode) {
    'EUR' => '€', 'GBP' => '£', 'PKR' => 'Rs ', 'INR' => '₹', 'JPY' => '¥',
    'CAD' => 'CA\$', 'AUD' => 'A\$', _ => '\$',
  };
  static String currency(num value) => NumberFormat.currency(locale: 'en_US', symbol: currencySymbol, decimalDigits: currencyCode == 'JPY' ? 0 : 2).format(value);
  static String compactCurrency(num value) => NumberFormat.compactCurrency(locale: 'en_US', symbol: currencySymbol, decimalDigits: 1).format(value);
  static String date(DateTime d) => DateFormat('MMM d, yyyy').format(d);
  static String dayMonth(DateTime d) => DateFormat('d MMM').format(d);
  static String time(DateTime d) => DateFormat('h:mm a').format(d);
  static String weekday(DateTime d) => DateFormat('EEEE').format(d);
  static String percent(double value, {int digits = 0}) => '${(value * 100).toStringAsFixed(digits)}%';
  static String relativeDay(DateTime d) {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    return dayMonth(d);
  }
}
