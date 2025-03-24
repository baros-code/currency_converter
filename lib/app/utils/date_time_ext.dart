import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String formatDefault() {
    return DateFormat('dd-MM-yyyy').format(this);
  }

  String formatByYearMonthDay() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}
