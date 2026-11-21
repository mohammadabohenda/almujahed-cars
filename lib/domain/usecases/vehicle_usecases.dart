// ============================================================================
// ملف: vehicle_usecases.dart
// الوظيفة: حالات الاستخدام الخاصة بإدارة أسطول السيارات.
// ============================================================================

import 'package:almugahed_cars/domain/entities/maintenance_record.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';
import 'package:almugahed_cars/domain/repositories/i_vehicle_repository.dart';

class GetAllVehiclesUseCase {
  final IVehicleRepository repository;
  GetAllVehiclesUseCase(this.repository);
  Future<List<Vehicle>> call() => repository.getAllVehicles();
}

class GetVehicleByIdUseCase {
  final IVehicleRepository repository;
  GetVehicleByIdUseCase(this.repository);
  Future<Vehicle?> call(String id) => repository.getVehicleById(id);
}

class AddVehicleUseCase {
  final IVehicleRepository repository;
  AddVehicleUseCase(this.repository);
  Future<void> call(Vehicle vehicle) => repository.addVehicle(vehicle);
}

class UpdateVehicleUseCase {
  final IVehicleRepository repository;
  UpdateVehicleUseCase(this.repository);
  Future<void> call(Vehicle vehicle) => repository.updateVehicle(vehicle);
}

class DeleteVehicleUseCase {
  final IVehicleRepository repository;
  DeleteVehicleUseCase(this.repository);
  Future<void> call(String id) => repository.deleteVehicle(id);
}

class AddMaintenanceRecordUseCase {
  final IVehicleRepository repository;
  AddMaintenanceRecordUseCase(this.repository);
  Future<void> call(String vehicleId, MaintenanceRecord record) =>
      repository.addMaintenanceRecord(vehicleId, record);
}
