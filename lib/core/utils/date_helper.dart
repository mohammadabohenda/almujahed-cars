// ============================================================================
// ملف: date_helper.dart
// الوظيفة: دوال مساعدة لتنسيق التواريخ وحساب عدد أيام الإيجار تلقائيًا.
// ============================================================================

import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  static final DateFormat _displayFormat = DateFormat('yyyy/MM/dd', 'ar');
  static final DateFormat _fallbackFormat = DateFormat('yyyy/MM/dd');

  /// تنسيق التاريخ لعرضه في الواجهة (بأرقام لاتينية لضمان التوافق)
  static String format(DateTime date) {
    try {
      return _fallbackFormat.format(date);
    } catch (_) {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// حساب عدد الأيام بين تاريخ الاستلام وتاريخ التسليم
  /// الحد الأدنى هو يوم واحد حتى لو كان التاريخان في نفس اليوم.
  static int calculateDays(DateTime pickup, DateTime dropoff) {
    final difference = dropoff.difference(pickup).inDays;
    return difference <= 0 ? 1 : difference;
  }

  /// حساب العمر بالسنوات من تاريخ الميلاد (اختياري لعرض معلومة إضافية)
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
