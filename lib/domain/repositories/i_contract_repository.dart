// ============================================================================
// ملف: i_contract_repository.dart
// الوظيفة: عقد (Interface) يحدد العمليات المتاحة على العقود، دون معرفة كيفية
// تنفيذها فعليًا. هذا يسمح باستبدال آلية التخزين (Hive) مستقبلاً دون التأثير
// على باقي طبقات التطبيق (Domain / Presentation).
// ============================================================================

import 'dart:io';
import 'package:almugahed_cars/domain/entities/contract.dart';

abstract class IContractRepository {
  Future<List<Contract>> getAllContracts();

  Future<Contract?> getContractById(String id);

  /// إضافة عقد جديد، مع نسخ الصور (إن وجدت) إلى التخزين الدائم.
  Future<void> addContract(
    Contract contract, {
    File? identityImageFile,
    File? licenseImageFile,
  });

  /// تعديل عقد موجود، مع إمكانية استبدال الصور.
  Future<void> updateContract(
    Contract contract, {
    File? newIdentityImageFile,
    File? newLicenseImageFile,
  });

  /// حذف عقد وحذف صوره المرتبطة من التخزين.
  Future<void> deleteContract(String id);

  /// بحث عن العقود (بالاسم / رقم اللوحة / رقم الهاتف / رقم الهوية)
  Future<List<Contract>> searchContracts(String query);
}
