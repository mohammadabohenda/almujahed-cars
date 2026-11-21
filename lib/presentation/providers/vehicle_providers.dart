// ============================================================================
// ملف: vehicle_providers.dart
// الوظيفة: ربط كل طبقات إدارة السيارات (Data/Domain) عبر Riverpod، وإدارة
// حالة قائمة السيارات (تحميل/نجاح/خطأ) وعمليات الإضافة والتعديل والحذف
// وإضافة سجلات الصيانة.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/datasources/vehicle_local_datasource.dart';
import 'package:almugahed_cars/data/repositories/vehicle_repository_impl.dart';
import 'package:almugahed_cars/domain/entities/maintenance_record.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';
import 'package:almugahed_cars/domain/repositories/i_vehicle_repository.dart';
import 'package:almugahed_cars/domain/usecases/vehicle_usecases.dart';

final vehicleLocalDataSourceProvider = Provider((ref) => VehicleLocalDataSource());

final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    localDataSource: ref.watch(vehicleLocalDataSourceProvider),
  );
});

final getAllVehiclesUseCaseProvider = Provider((ref) {
  return GetAllVehiclesUseCase(ref.watch(vehicleRepositoryProvider));
});
final getVehicleByIdUseCaseProvider = Provider((ref) {
  return GetVehicleByIdUseCase(ref.watch(vehicleRepositoryProvider));
});
final addVehicleUseCaseProvider = Provider((ref) {
  return AddVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});
final updateVehicleUseCaseProvider = Provider((ref) {
  return UpdateVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});
final deleteVehicleUseCaseProvider = Provider((ref) {
  return DeleteVehicleUseCase(ref.watch(vehicleRepositoryProvider));
});
final addMaintenanceRecordUseCaseProvider = Provider((ref) {
  return AddMaintenanceRecordUseCase(ref.watch(vehicleRepositoryProvider));
});

enum VehiclesStatus { initial, loading, loaded, error }

class VehiclesState {
  final VehiclesStatus status;
  final List<Vehicle> vehicles;
  final String? errorMessage;

  const VehiclesState({
    this.status = VehiclesStatus.initial,
    this.vehicles = const [],
    this.errorMessage,
  });

  VehiclesState copyWith({
    VehiclesStatus? status,
    List<Vehicle>? vehicles,
    String? errorMessage,
  }) {
    return VehiclesState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      errorMessage: errorMessage,
    );
  }
}

class VehiclesController extends StateNotifier<VehiclesState> {
  final GetAllVehiclesUseCase _getAll;
  final AddVehicleUseCase _add;
  final UpdateVehicleUseCase _update;
  final DeleteVehicleUseCase _delete;
  final AddMaintenanceRecordUseCase _addMaintenance;

  VehiclesController({
    required GetAllVehiclesUseCase getAll,
    required AddVehicleUseCase add,
    required UpdateVehicleUseCase update,
    required DeleteVehicleUseCase delete,
    required AddMaintenanceRecordUseCase addMaintenance,
  })  : _getAll = getAll,
        _add = add,
        _update = update,
        _delete = delete,
        _addMaintenance = addMaintenance,
        super(const VehiclesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: VehiclesStatus.loading);
    try {
      final vehicles = await _getAll();
      state = state.copyWith(status: VehiclesStatus.loaded, vehicles: vehicles);
    } catch (e) {
      state = state.copyWith(status: VehiclesStatus.error, errorMessage: '$e');
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      await _add(vehicle);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(status: VehiclesStatus.error, errorMessage: '$e');
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle vehicle) async {
    try {
      await _update(vehicle);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(status: VehiclesStatus.error, errorMessage: '$e');
      return false;
    }
  }

  /// تغيير حالة سيارة فقط (تُستخدم تلقائيًا عند إضافة/إغلاق عقد تأجير)
  Future<void> setVehicleStatus(String vehicleId, VehicleStatus status) async {
    Vehicle? vehicle;
    for (final v in state.vehicles) {
      if (v.id == vehicleId) {
        vehicle = v;
        break;
      }
    }
    if (vehicle == null) return;
    await _update(vehicle.copyWith(status: status));
    await load();
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      await _delete(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(status: VehiclesStatus.error, errorMessage: '$e');
      return false;
    }
  }

  Future<bool> addMaintenanceRecord(String vehicleId, MaintenanceRecord record) async {
    try {
      await _addMaintenance(vehicleId, record);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(status: VehiclesStatus.error, errorMessage: '$e');
      return false;
    }
  }
}

final vehiclesControllerProvider =
    StateNotifierProvider<VehiclesController, VehiclesState>((ref) {
  return VehiclesController(
    getAll: ref.watch(getAllVehiclesUseCaseProvider),
    add: ref.watch(addVehicleUseCaseProvider),
    update: ref.watch(updateVehicleUseCaseProvider),
    delete: ref.watch(deleteVehicleUseCaseProvider),
    addMaintenance: ref.watch(addMaintenanceRecordUseCaseProvider),
  );
});

final singleVehicleProvider = FutureProvider.family<Vehicle?, String>((ref, id) async {
  final useCase = ref.watch(getVehicleByIdUseCaseProvider);
  return useCase(id);
});
