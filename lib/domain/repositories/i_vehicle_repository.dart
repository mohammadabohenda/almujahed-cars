// ============================================================================
// ملف: i_vehicle_repository.dart
// الوظيفة: عقد (Interface) للتعامل مع بيانات السيارات ضمن الأسطول.
// ============================================================================

import 'package:almugahed_cars/domain/entities/maintenance_record.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';

abstract class IVehicleRepository {
  Future<List<Vehicle>> getAllVehicles();
  Future<Vehicle?> getVehicleById(String id);
  Future<void> addVehicle(Vehicle vehicle);
  Future<void> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
  Future<void> addMaintenanceRecord(String vehicleId, MaintenanceRecord record);
}
