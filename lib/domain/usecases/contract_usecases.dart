// ============================================================================
// ملف: contract_usecases.dart
// الوظيفة: طبقة Use Cases التي تمثل "قواعد العمل" (Business Rules) الخاصة
// بكل عملية على العقود. كل Use Case مسؤول عن مهمة واحدة فقط (SRP)، ويعتمد
// على IContractRepository دون معرفة تفاصيل التخزين الفعلية.
// ============================================================================

import 'dart:io';
import 'package:almugahed_cars/domain/entities/contract.dart';
import 'package:almugahed_cars/domain/repositories/i_contract_repository.dart';

class GetAllContractsUseCase {
  final IContractRepository repository;
  GetAllContractsUseCase(this.repository);

  Future<List<Contract>> call() => repository.getAllContracts();
}

class GetContractByIdUseCase {
  final IContractRepository repository;
  GetContractByIdUseCase(this.repository);

  Future<Contract?> call(String id) => repository.getContractById(id);
}

class AddContractUseCase {
  final IContractRepository repository;
  AddContractUseCase(this.repository);

  Future<void> call(
    Contract contract, {
    File? identityImageFile,
    File? licenseImageFile,
  }) {
    return repository.addContract(
      contract,
      identityImageFile: identityImageFile,
      licenseImageFile: licenseImageFile,
    );
  }
}

class UpdateContractUseCase {
  final IContractRepository repository;
  UpdateContractUseCase(this.repository);

  Future<void> call(
    Contract contract, {
    File? newIdentityImageFile,
    File? newLicenseImageFile,
  }) {
    return repository.updateContract(
      contract,
      newIdentityImageFile: newIdentityImageFile,
      newLicenseImageFile: newLicenseImageFile,
    );
  }
}

class DeleteContractUseCase {
  final IContractRepository repository;
  DeleteContractUseCase(this.repository);

  Future<void> call(String id) => repository.deleteContract(id);
}

class SearchContractsUseCase {
  final IContractRepository repository;
  SearchContractsUseCase(this.repository);

  Future<List<Contract>> call(String query) => repository.searchContracts(query);
}
