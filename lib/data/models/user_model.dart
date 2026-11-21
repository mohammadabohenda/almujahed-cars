// ============================================================================
// ملف: user_model.dart  (Data Layer)
// الوظيفة: تمثيل المستخدم كما يُخزَّن في Hive، مع TypeAdapter يدوي.
// كلمة المرور تُخزَّن دائمًا كـ Hash (SHA-256) وليست نصًا صريحًا.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/domain/entities/app_user.dart';

class UserModel extends HiveObject {
  String id;
  String username;
  String passwordHash;
  int roleIndex;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.roleIndex,
    required this.createdAt,
  });

  factory UserModel.fromEntity(AppUser entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      passwordHash: entity.passwordHash,
      roleIndex: entity.role.index,
      createdAt: entity.createdAt,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      username: username,
      passwordHash: passwordHash,
      role: UserRole.values[roleIndex],
      createdAt: createdAt,
    );
  }
}

/// typeId = 3 (فريد داخل المشروع بالكامل)
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 3;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      passwordHash: fields[2] as String,
      roleIndex: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.passwordHash)
      ..writeByte(3)
      ..write(obj.roleIndex)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
