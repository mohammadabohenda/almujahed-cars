// ============================================================================
// ملف: i_auth_repository.dart
// الوظيفة: عقد (Interface) لعمليات تسجيل الدخول وإدارة حسابات المستخدمين.
// ============================================================================

import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/domain/entities/app_user.dart';

abstract class IAuthRepository {
  /// يحاول تسجيل الدخول، ويرجع المستخدم عند النجاح أو null عند فشل التحقق.
  Future<AppUser?> login(String username, String password);

  Future<List<AppUser>> getAllUsers();

  Future<bool> addUser(String username, String password, UserRole role);

  Future<void> deleteUser(String id);
}
