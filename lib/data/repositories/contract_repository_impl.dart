// ============================================================================
// ملف: contract_repository_impl.dart
// الوظيفة: التنفيذ الفعلي لـ IContractRepository، يربط بين مصدر البيانات
// المحلي (Hive) وخدمة تخزين الصور، ويحوّل بين Model و Entity.
// ============================================================================

import 'dart:io';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/datasources/contract_local_datasource.dart';
import 'package:almugahed_cars/data/datasources/image_storage_service.dart';
import 'package:almugahed_cars/data/models/contract_model.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';
import 'package:almugahed_cars/domain/repositories/i_contract_repository.dart';

class ContractRepositoryImpl implements IContractRepository {
  final ContractLocalDataSource localDataSource;
  final ImageStorageService imageStorageService;

  ContractRepositoryImpl({
    required this.localDataSource,
    required this.imageStorageService,
  });

  @override
  Future<List<Contract>> getAllContracts() async {
    final models = localDataSource.getAll();
    // ترتيب الأحدث أولاً حسب تاريخ الإنشاء
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Contract?> getContractById(String id) async {
    return localDataSource.getById(id)?.toEntity();
  }

  @override
  Future<void> addContract(
    Contract contract, {
    File? identityImageFile,
    File? licenseImageFile,
  }) async {
    String? identityPath;
    String? licensePath;

    if (identityImageFile != null) {
      identityPath = await imageStorageService.saveImage(
        identityImageFile,
        AppConstants.identityImagesFolder,
      );
    }
    if (licenseImageFile != null) {
      licensePath = await imageStorageService.saveImage(
        licenseImageFile,
        AppConstants.licenseImagesFolder,
      );
    }

    final finalContract = contract.copyWith(
      identityImagePath: identityPath,
      licenseImagePath: licensePath,
    );

    await localDataSource.save(ContractModel.fromEntity(finalContract));
  }

  @override
  Future<void> updateContract(
    Contract contract, {
    File? newIdentityImageFile,
    File? newLicenseImageFile,
  }) async {
    String? identityPath = contract.identityImagePath;
    String? licensePath = contract.licenseImagePath;

    // في حال تم اختيار صورة جديدة، نحذف القديمة ونحفظ الجديدة
    if (newIdentityImageFile != null) {
      await imageStorageService.deleteImage(contract.identityImagePath);
      identityPath = await imageStorageService.saveImage(
        newIdentityImageFile,
        AppConstants.identityImagesFolder,
      );
    }
    if (newLicenseImageFile != null) {
      await imageStorageService.deleteImage(contract.licenseImagePath);
      licensePath = await imageStorageService.saveImage(
        newLicenseImageFile,
        AppConstants.licenseImagesFolder,
      );
    }

    final updated = contract.copyWith(
      identityImagePath: identityPath,
      licenseImagePath: licensePath,
      updatedAt: DateTime.now(),
    );

    await localDataSource.save(ContractModel.fromEntity(updated));
  }

  @override
  Future<void> deleteContract(String id) async {
    final model = localDataSource.getById(id);
    if (model != null) {
      await imageStorageService.deleteImage(model.identityImagePath);
      await imageStorageService.deleteImage(model.licenseImagePath);
      await localDataSource.delete(id);
    }
  }

  @override
  Future<List<Contract>> searchContracts(String query) async {
    final all = await getAllContracts();
    if (query.trim().isEmpty) return all;

    final lowerQuery = query.trim().toLowerCase();
    return all.where((c) {
      return c.fullName.toLowerCase().contains(lowerQuery) ||
          c.plateNumber.toLowerCase().contains(lowerQuery) ||
          c.phoneNumber.toLowerCase().contains(lowerQuery) ||
          c.nationalIdNumber.toLowerCase().contains(lowerQuery) ||
          c.carType.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
