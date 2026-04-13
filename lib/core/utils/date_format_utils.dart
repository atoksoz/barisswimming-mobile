import 'package:intl/intl.dart';

class DateFormatUtils {
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateOnly = DateFormat('dd/MM/yyyy');

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      return _dateTime.format(DateTime.parse(dateTimeString));
    } catch (_) {
      return dateTimeString;
    }
  }

  static String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      return _dateOnly.format(DateTime.parse(dateTimeString));
    } catch (_) {
      return dateTimeString;
    }
  }

  /// d.m.Y (saat yok; gün/ay baştaki sıfırsız), yerel saat dilimi.
  static String formatDateDayMonthYearDots(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final d = DateTime.parse(dateTimeString).toLocal();
      return '${d.day}.${d.month}.${d.year}';
    } catch (_) {
      return dateTimeString;
    }
  }
}
