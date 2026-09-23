import 'package:intl/intl.dart';

/// Static formatters for currency, dates, and percentages.
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 1,
  );

  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _fullDate = DateFormat('MMM d, yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _weekday = DateFormat('EEEE');

  static String currency(num value) => _currency.format(value);
  static String compactCurrency(num value) => _compactCurrency.format(value);

  static String date(DateTime d) => _fullDate.format(d);
  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String time(DateTime d) => _time.format(d);
  static String weekday(DateTime d) => _weekday.format(d);

  static String percent(double value, {int digits = 0}) {
    return '${(value * 100).toStringAsFixed(digits)}%';
  }

  /// "today", "yesterday", "5 days ago"…
  static String relativeDay(DateTime d) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(d.year, d.month, d.day);
    final int diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return dayMonth(d);
  }
}
