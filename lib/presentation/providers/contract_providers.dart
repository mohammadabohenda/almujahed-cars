// ============================================================================
// ملف: contract_providers.dart
// الوظيفة: نقطة التجميع بين كل الطبقات (Data / Domain) عبر Riverpod.
// يحتوي على:
//   - Providers لمصادر البيانات والمستودعات وحالات الاستخدام.
//   - StateNotifier (ContractsController) الذي يدير حالة قائمة العقود
//     (تحميل / نجاح / خطأ) ويعرض دوال الإضافة والتعديل والحذف والبحث.
// ============================================================================

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/data/datasources/contract_local_datasource.dart';
import 'package:almugahed_cars/data/datasources/image_storage_service.dart';
import 'package:almugahed_cars/data/repositories/contract_repository_impl.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';
import 'package:almugahed_cars/domain/repositories/i_contract_repository.dart';
import 'package:almugahed_cars/domain/usecases/contract_usecases.dart';

// ---------------------------------------------------------------------------
// Data Sources & Services
// ---------------------------------------------------------------------------
final contractLocalDataSourceProvider = Provider<ContractLocalDataSource>((ref) {
  return ContractLocalDataSource();
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------
final contractRepositoryProvider = Provider<IContractRepository>((ref) {
  return ContractRepositoryImpl(
    localDataSource: ref.watch(contractLocalDataSourceProvider),
    imageStorageService: ref.watch(imageStorageServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------
final getAllContractsUseCaseProvider = Provider((ref) {
  return GetAllContractsUseCase(ref.watch(contractRepositoryProvider));
});

final getContractByIdUseCaseProvider = Provider((ref) {
  return GetContractByIdUseCase(ref.watch(contractRepositoryProvider));
});

final addContractUseCaseProvider = Provider((ref) {
  return AddContractUseCase(ref.watch(contractRepositoryProvider));
});

final updateContractUseCaseProvider = Provider((ref) {
  return UpdateContractUseCase(ref.watch(contractRepositoryProvider));
});

final deleteContractUseCaseProvider = Provider((ref) {
  return DeleteContractUseCase(ref.watch(contractRepositoryProvider));
});

final searchContractsUseCaseProvider = Provider((ref) {
  return SearchContractsUseCase(ref.watch(contractRepositoryProvider));
});

// ---------------------------------------------------------------------------
// حالة قائمة العقود
// ---------------------------------------------------------------------------
enum ContractsStatus { initial, loading, loaded, error }

class ContractsState {
  final ContractsStatus status;
  final List<Contract> contracts;
  final String searchQuery;
  final String? errorMessage;

  const ContractsState({
    this.status = ContractsStatus.initial,
    this.contracts = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  ContractsState copyWith({
    ContractsStatus? status,
    List<Contract>? contracts,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ContractsController extends StateNotifier<ContractsState> {
  final GetAllContractsUseCase _getAllContracts;
  final AddContractUseCase _addContract;
  final UpdateContractUseCase _updateContract;
  final DeleteContractUseCase _deleteContract;
  final SearchContractsUseCase _searchContracts;

  ContractsController({
    required GetAllContractsUseCase getAllContracts,
    required AddContractUseCase addContract,
    required UpdateContractUseCase updateContract,
    required DeleteContractUseCase deleteContract,
    required SearchContractsUseCase searchContracts,
  })  : _getAllContracts = getAllContracts,
        _addContract = addContract,
        _updateContract = updateContract,
        _deleteContract = deleteContract,
        _searchContracts = searchContracts,
        super(const ContractsState()) {
    loadContracts();
  }

  Future<void> loadContracts() async {
    state = state.copyWith(status: ContractsStatus.loading);
    try {
      final contracts = await _getAllContracts();
      state = state.copyWith(
        status: ContractsStatus.loaded,
        contracts: contracts,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContractsStatus.error,
        errorMessage: 'حدث خطأ أثناء تحميل العقود: $e',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, status: ContractsStatus.loading);
    try {
      final results = await _searchContracts(query);
      state = state.copyWith(
        status: ContractsStatus.loaded,
        contracts: results,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContractsStatus.error,
        errorMessage: 'حدث خطأ أثناء البحث: $e',
      );
    }
  }

  Future<bool> addContract(
    Contract contract, {
    File? identityImageFile,
    File? licenseImageFile,
  }) async {
    try {
      await _addContract(
        contract,
        identityImageFile: identityImageFile,
        licenseImageFile: licenseImageFile,
      );
      await loadContracts();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ContractsStatus.error,
        errorMessage: 'حدث خطأ أثناء إضافة العقد: $e',
      );
      return false;
    }
  }

  Future<bool> updateContract(
    Contract contract, {
    File? newIdentityImageFile,
    File? newLicenseImageFile,
  }) async {
    try {
      await _updateContract(
        contract,
        newIdentityImageFile: newIdentityImageFile,
        newLicenseImageFile: newLicenseImageFile,
      );
      await loadContracts();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ContractsStatus.error,
        errorMessage: 'حدث خطأ أثناء تعديل العقد: $e',
      );
      return false;
    }
  }

  Future<bool> deleteContract(String id) async {
    try {
      await _deleteContract(id);
      await loadContracts();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ContractsStatus.error,
        errorMessage: 'حدث خطأ أثناء حذف العقد: $e',
      );
      return false;
    }
  }
}

final contractsControllerProvider =
    StateNotifierProvider<ContractsController, ContractsState>((ref) {
  return ContractsController(
    getAllContracts: ref.watch(getAllContractsUseCaseProvider),
    addContract: ref.watch(addContractUseCaseProvider),
    updateContract: ref.watch(updateContractUseCaseProvider),
    deleteContract: ref.watch(deleteContractUseCaseProvider),
    searchContracts: ref.watch(searchContractsUseCaseProvider),
  );
});

/// Provider لجلب عقد واحد بالتفصيل عبر id (يُستخدم في شاشة التفاصيل/التعديل)
final singleContractProvider =
    FutureProvider.family<Contract?, String>((ref, id) async {
  final useCase = ref.watch(getContractByIdUseCaseProvider);
  return useCase(id);
});
