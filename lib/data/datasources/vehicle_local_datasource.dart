// ============================================================================
// ملف: vehicle_local_datasource.dart
// الوظيفة: عمليات CRUD خام على صندوق السيارات في Hive.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/models/vehicle_model.dart';

class VehicleLocalDataSource {
  Box<VehicleModel> get _box => Hive.box<VehicleModel>(AppConstants.vehiclesBoxName);

  List<VehicleModel> getAll() => _box.values.toList();

  VehicleModel? getById(String id) => _box.get(id);

  Future<void> save(VehicleModel model) => _box.put(model.id, model);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clearAll() => _box.clear();
}
