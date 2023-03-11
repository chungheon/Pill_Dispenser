import 'package:intl/intl.dart';

class DateTimeHelper {
  static const List<String> days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];
  static final DateTime MONDAY_REFERENCE = DateTime(2022, 1, 31);

  static String formatDateTimeStr(DateTime date, {bool showDay = false}) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    if (showDay) {
      int dayIndex = MONDAY_REFERENCE.difference(date).inDays % 7;
      formattedDate += ' (${days[dayIndex]})';
    }
    return formattedDate;
  }
}
