// ============================================================================
// ملف: auth_providers.dart
// الوظيفة: ربط طبقة المصادقة مع Riverpod، وإدارة حالة "المستخدم الحالي"
// (Session) وحفظها في صندوق الإعدادات بحيث لا يحتاج المستخدم لتسجيل الدخول
// من جديد في كل مرة يفتح فيها التطبيق، إلا بعد تسجيل الخروج صراحةً.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/datasources/auth_local_datasource.dart';
import 'package:almugahed_cars/data/repositories/auth_repository_impl.dart';
import 'package:almugahed_cars/domain/entities/app_user.dart';
import 'package:almugahed_cars/domain/repositories/i_auth_repository.dart';

final authLocalDataSourceProvider = Provider((ref) => AuthLocalDataSource());

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

Box get _settingsBox => Hive.box(AppConstants.settingsBoxName);

class AuthController extends StateNotifier<AppUser?> {
  final IAuthRepository _repository;
  final AuthLocalDataSource _localDataSource;

  AuthController(this._repository, this._localDataSource) : super(null) {
    _restoreSession();
  }

  /// عند فتح التطبيق: لو كان هناك اسم مستخدم محفوظ من جلسة سابقة، نعيد تحميله
  /// تلقائيًا دون الحاجة لإعادة إدخال كلمة المرور.
  void _restoreSession() {
    final savedUsername = _settingsBox.get(AppConstants.sessionUsernameKey) as String?;
    if (savedUsername != null) {
      final model = _localDataSource.getByUsername(savedUsername);
      if (model != null) {
        state = model.toEntity();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    final user = await _repository.login(username, password);
    if (user != null) {
      state = user;
      await _settingsBox.put(AppConstants.sessionUsernameKey, user.username);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    state = null;
    await _settingsBox.delete(AppConstants.sessionUsernameKey);
  }

  bool get isManager => state?.role == UserRole.admin;
}

final authControllerProvider = StateNotifierProvider<AuthController, AppUser?>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

/// كل المستخدمين المسجّلين (تُستخدم في شاشة الإعدادات لإدارة الموظفين)
final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getAllUsers();
});
