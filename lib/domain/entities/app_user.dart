// ============================================================================
// ملف: app_user.dart  (Domain Entity)
// الوظيفة: يمثل مستخدم النظام (مدير أو موظف) المستخدَم لتسجيل الدخول محليًا.
// ============================================================================

import 'package:almugahed_cars/core/constants/app_constants.dart';

class AppUser {
  final String id;
  final String username;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });
}
