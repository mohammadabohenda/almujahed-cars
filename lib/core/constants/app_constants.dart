// ============================================================================
// ملف: app_constants.dart
// الوظيفة: تجميع كل النصوص والثوابت الثابتة المستخدمة في التطبيق في مكان واحد
// لتسهيل الصيانة والتعديل مستقبلاً (مثل تغيير اسم الشركة أو نصوص الواجهة).
// ============================================================================

class AppConstants {
  AppConstants._();

  static const String appName = 'ALMUGAHED CARS';
  static const String appNameArabic = 'شركة المجاهد لتأجير السيارات';
  static const String logoPath = 'assets/logo/logo.png';

  // أسماء صناديق Hive
  static const String contractsBoxName = 'contracts_box';
  static const String vehiclesBoxName = 'vehicles_box';
  static const String usersBoxName = 'users_box';
  static const String settingsBoxName = 'settings_box';

  // مجلد تخزين الصور داخل مساحة التطبيق
  static const String identityImagesFolder = 'identity_images';
  static const String licenseImagesFolder = 'license_images';
  static const String signaturesFolder = 'signatures';
  static const String exportsFolder = 'exports';

  // مفاتيح صندوق الإعدادات
  static const String themeModeKey = 'theme_mode'; // true = داكن, false = فاتح
  static const String sessionUsernameKey = 'session_username'; // آخر مستخدم مسجّل دخوله

  // بيانات المدير الافتراضي عند أول تشغيل للتطبيق
  static const String defaultAdminUsername = 'admin';
  static const String defaultAdminPassword = 'admin123';

  // الإشعارات المحلية
  static const String notificationChannelId = 'return_reminders';
  static const String notificationChannelName = 'تذكير مواعيد التسليم';
  static const int returnReminderHour = 9; // الساعة 9 صباحًا يوم قبل التسليم
}

/// أنواع التأجير المتاحة
enum RentalType { withoutDriver, withDriver }

extension RentalTypeLabel on RentalType {
  String get label {
    switch (this) {
      case RentalType.withoutDriver:
        return 'بدون سائق';
      case RentalType.withDriver:
        return 'مع سائق';
    }
  }
}

/// حالة السيارة داخل الأسطول
enum VehicleStatus { available, rented, maintenance }

extension VehicleStatusLabel on VehicleStatus {
  String get label {
    switch (this) {
      case VehicleStatus.available:
        return 'متاحة';
      case VehicleStatus.rented:
        return 'مؤجرة';
      case VehicleStatus.maintenance:
        return 'بالصيانة';
    }
  }
}

/// صلاحية المستخدم داخل التطبيق
enum UserRole { admin, employee }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.employee:
        return 'موظف';
    }
  }
}
