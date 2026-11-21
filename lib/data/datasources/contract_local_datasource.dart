// ============================================================================
// ملف: contract_local_datasource.dart
// الوظيفة: طبقة الوصول المباشر لقاعدة بيانات Hive (CRUD خام على ContractModel)
// لا تحتوي على أي منطق عمل، فقط عمليات تخزين/استرجاع/حذف.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/models/contract_model.dart';

class ContractLocalDataSource {
  Box<ContractModel> get _box =>
      Hive.box<ContractModel>(AppConstants.contractsBoxName);

  List<ContractModel> getAll() {
    return _box.values.toList();
  }

  ContractModel? getById(String id) {
    return _box.get(id);
  }

  Future<void> save(ContractModel model) async {
    await _box.put(model.id, model);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
