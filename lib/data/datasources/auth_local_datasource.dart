// ============================================================================
// ملف: auth_local_datasource.dart
// الوظيفة: عمليات CRUD خام على صندوق المستخدمين في Hive، بالإضافة إلى زرع
// حساب "مدير" افتراضي تلقائيًا عند أول تشغيل للتطبيق إن لم يوجد أي مستخدم.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/utils/password_hasher.dart';
import 'package:almugahed_cars/data/models/user_model.dart';

class AuthLocalDataSource {
  static const _uuid = Uuid();

  Box<UserModel> get _box => Hive.box<UserModel>(AppConstants.usersBoxName);

  List<UserModel> getAll() => _box.values.toList();

  UserModel? getByUsername(String username) {
    try {
      return _box.values.firstWhere(
        (u) => u.username.toLowerCase() == username.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserModel model) => _box.put(model.id, model);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clearAll() => _box.clear();

  /// يُستدعى مرة واحدة عند بدء التطبيق: لو الصندوق فارغ (أول تشغيل) يُنشئ
  /// حساب مدير افتراضي بمستخدم/كلمة مرور محددة في AppConstants.
  Future<void> seedDefaultAdminIfNeeded() async {
    if (_box.isEmpty) {
      final admin = UserModel(
        id: _uuid.v4(),
        username: AppConstants.defaultAdminUsername,
        passwordHash: PasswordHasher.hash(AppConstants.defaultAdminPassword),
        roleIndex: UserRole.admin.index,
        createdAt: DateTime.now(),
      );
      await _box.put(admin.id, admin);
    }
  }
}
