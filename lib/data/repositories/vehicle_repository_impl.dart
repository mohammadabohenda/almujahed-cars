// ============================================================================
// ملف: vehicle_repository_impl.dart
// الوظيفة: التنفيذ الفعلي لـ IVehicleRepository عبر Hive.
// ============================================================================

import 'package:almugahed_cars/data/datasources/vehicle_local_datasource.dart';
import 'package:almugahed_cars/data/models/maintenance_record_model.dart';
import 'package:almugahed_cars/data/models/vehicle_model.dart';
import 'package:almugahed_cars/domain/entities/maintenance_record.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';
import 'package:almugahed_cars/domain/repositories/i_vehicle_repository.dart';

class VehicleRepositoryImpl implements IVehicleRepository {
  final VehicleLocalDataSource localDataSource;
  VehicleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    final models = localDataSource.getAll();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    return localDataSource.getById(id)?.toEntity();
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    await localDataSource.save(VehicleModel.fromEntity(vehicle));
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    await localDataSource.save(
      VehicleModel.fromEntity(vehicle.copyWith(updatedAt: DateTime.now())),
    );
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<void> addMaintenanceRecord(String vehicleId, MaintenanceRecord record) async {
    final model = localDataSource.getById(vehicleId);
    if (model == null) return;
    final updatedRecords = List<MaintenanceRecordModel>.from(model.maintenanceRecords)
      ..add(MaintenanceRecordModel.fromEntity(record));
    model.maintenanceRecords = updatedRecords;
    model.updatedAt = DateTime.now();
    await localDataSource.save(model);
  }
}
