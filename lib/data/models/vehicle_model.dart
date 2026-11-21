// ============================================================================
// ملف: vehicle_model.dart  (Data Layer)
// الوظيفة: تمثيل السيارة كما تُخزَّن فعليًا في Hive، مع TypeAdapter يدوي.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/models/maintenance_record_model.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';

class VehicleModel extends HiveObject {
  String id;
  String carType;
  String plateNumber;
  String color;
  int statusIndex;
  DateTime? lastInsuranceDate;
  DateTime? lastLicenseDate;
  List<MaintenanceRecordModel> maintenanceRecords;
  DateTime createdAt;
  DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.carType,
    required this.plateNumber,
    required this.color,
    required this.statusIndex,
    required this.maintenanceRecords,
    required this.createdAt,
    required this.updatedAt,
    this.lastInsuranceDate,
    this.lastLicenseDate,
  });

  factory VehicleModel.fromEntity(Vehicle entity) {
    return VehicleModel(
      id: entity.id,
      carType: entity.carType,
      plateNumber: entity.plateNumber,
      color: entity.color,
      statusIndex: entity.status.index,
      lastInsuranceDate: entity.lastInsuranceDate,
      lastLicenseDate: entity.lastLicenseDate,
      maintenanceRecords:
          entity.maintenanceRecords.map((m) => MaintenanceRecordModel.fromEntity(m)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      carType: carType,
      plateNumber: plateNumber,
      color: color,
      status: VehicleStatus.values[statusIndex],
      lastInsuranceDate: lastInsuranceDate,
      lastLicenseDate: lastLicenseDate,
      maintenanceRecords: maintenanceRecords.map((m) => m.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// typeId = 1 (فريد داخل المشروع بالكامل)
class VehicleModelAdapter extends TypeAdapter<VehicleModel> {
  @override
  final int typeId = 1;

  @override
  VehicleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleModel(
      id: fields[0] as String,
      carType: fields[1] as String,
      plateNumber: fields[2] as String,
      color: fields[3] as String,
      statusIndex: fields[4] as int,
      lastInsuranceDate: fields[5] as DateTime?,
      lastLicenseDate: fields[6] as DateTime?,
      maintenanceRecords: (fields[7] as List).cast<MaintenanceRecordModel>(),
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.carType)
      ..writeByte(2)
      ..write(obj.plateNumber)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.statusIndex)
      ..writeByte(5)
      ..write(obj.lastInsuranceDate)
      ..writeByte(6)
      ..write(obj.lastLicenseDate)
      ..writeByte(7)
      ..write(obj.maintenanceRecords)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}
