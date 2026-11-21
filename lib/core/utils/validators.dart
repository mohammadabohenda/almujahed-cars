// ============================================================================
// ملف: validators.dart
// الوظيفة: مجموعة دوال للتحقق من صحة بيانات النموذج (Form Validation)
// تُستخدم داخل كل TextFormField عبر الخاصية validator.
// ============================================================================

class Validators {
  Validators._();

  /// حقل نصي عام إلزامي
  static String? required(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// التحقق من رقم الهاتف (أرقام فقط، بين 7 و15 رقمًا)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(cleaned)) {
      return 'رقم هاتف غير صحيح';
    }
    return null;
  }

  /// التحقق من رقم عام (بطاقة شخصية / جواز سفر / رخصة قيادة / لوحة السيارة)
  static String? generalId(String? value, {String fieldName = 'الرقم'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    if (value.trim().length < 2) {
      return '$fieldName غير صحيح';
    }
    return null;
  }

  /// التحقق من قيمة رقمية (مثل السلفة أو عدد الأيام)
  static String? numeric(String? value, {bool allowEmpty = false, String fieldName = 'القيمة'}) {
    if (value == null || value.trim().isEmpty) {
      return allowEmpty ? null : '$fieldName مطلوبة';
    }
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName يجب أن تكون رقمًا';
    }
    return null;
  }

  /// التحقق من أن عدد الأيام أكبر من صفر
  static String? positiveInt(String? value, {String fieldName = 'القيمة'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوبة';
    }
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) {
      return '$fieldName يجب أن تكون رقمًا صحيحًا أكبر من صفر';
    }
    return null;
  }
}
