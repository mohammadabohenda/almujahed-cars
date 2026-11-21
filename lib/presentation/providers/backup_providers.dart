// ============================================================================
// ملف: backup_providers.dart
// الوظيفة: ربط BackupService بمصادر البيانات الثلاثة عبر Riverpod ليسهل
// استخدامها في شاشة الإعدادات.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/services/backup_service.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/providers/contract_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    contractDataSource: ref.watch(contractLocalDataSourceProvider),
    vehicleDataSource: ref.watch(vehicleLocalDataSourceProvider),
    authDataSource: ref.watch(authLocalDataSourceProvider),
  );
});
