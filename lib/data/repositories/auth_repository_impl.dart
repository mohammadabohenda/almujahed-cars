// ============================================================================
// ملف: auth_repository_impl.dart
// الوظيفة: التنفيذ الفعلي لـ IAuthRepository عبر Hive + تشفير كلمات المرور.
// ============================================================================

import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/utils/password_hasher.dart';
import 'package:almugahed_cars/data/datasources/auth_local_datasource.dart';
import 'package:almugahed_cars/data/models/user_model.dart';
import 'package:almugahed_cars/domain/entities/app_user.dart';
import 'package:almugahed_cars/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDataSource localDataSource;
  static const _uuid = Uuid();

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<AppUser?> login(String username, String password) async {
    final model = localDataSource.getByUsername(username);
    if (model == null) return null;
    if (!PasswordHasher.verify(password, model.passwordHash)) return null;
    return model.toEntity();
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    return localDataSource.getAll().map((m) => m.toEntity()).toList();
  }

  @override
  Future<bool> addUser(String username, String password, UserRole role) async {
    if (localDataSource.getByUsername(username) != null) {
      return false; // اسم المستخدم موجود مسبقًا
    }
    final model = UserModel(
      id: _uuid.v4(),
      username: username.trim(),
      passwordHash: PasswordHasher.hash(password),
      roleIndex: role.index,
      createdAt: DateTime.now(),
    );
    await localDataSource.save(model);
    return true;
  }

  @override
  Future<void> deleteUser(String id) => localDataSource.delete(id);
}
