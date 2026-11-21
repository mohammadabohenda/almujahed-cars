// ============================================================================
// ملف: maintenance_record_model.dart  (Data Layer)
// الوظيفة: تمثيل سجل الصيانة كما يُخزَّن داخل Hive (كعنصر ضمن قائمة في
// VehicleModel)، مع TypeAdapter يدوي. لا يرث HiveObject لأنه لا يُخزَّن
// مباشرة في Box بل كعنصر متداخل داخل قائمة maintenanceRecords.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/domain/entities/maintenance_record.dart';

class MaintenanceRecordModel {
  String id;
  DateTime date;
  String description;
  double cost;

  MaintenanceRecordModel({
    required this.id,
    required this.date,
    required this.description,
    required this.cost,
  });

  factory MaintenanceRecordModel.fromEntity(MaintenanceRecord entity) {
    return MaintenanceRecordModel(
      id: entity.id,
      date: entity.date,
      description: entity.description,
      cost: entity.cost,
    );
  }

  MaintenanceRecord toEntity() {
    return MaintenanceRecord(id: id, date: date, description: description, cost: cost);
  }
}

/// typeId = 2 (فريد داخل المشروع بالكامل)
class MaintenanceRecordModelAdapter extends TypeAdapter<MaintenanceRecordModel> {
  @override
  final int typeId = 2;

  @override
  MaintenanceRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceRecordModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      description: fields[2] as String,
      cost: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.cost);
  }
}
