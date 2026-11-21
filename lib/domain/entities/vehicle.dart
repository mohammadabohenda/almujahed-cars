// ============================================================================
// ملف: vehicle.dart  (Domain Entity)
// الوظيفة: يمثل سيارة ضمن أسطول الشركة: بياناتها الأساسية، حالتها الحالية
// (متاحة / مؤجرة / بالصيانة)، تواريخ آخر تأمين وترخيص، وسجل صيانتها الكامل.
// ============================================================================

import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/domain/entities/maintenance_record.dart';

class Vehicle {
  final String id;
  final String carType;
  final String plateNumber;
  final String color;
  final VehicleStatus status;
  final DateTime? lastInsuranceDate;
  final DateTime? lastLicenseDate;
  final List<MaintenanceRecord> maintenanceRecords;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.carType,
    required this.plateNumber,
    required this.color,
    required this.status,
    required this.maintenanceRecords,
    required this.createdAt,
    required this.updatedAt,
    this.lastInsuranceDate,
    this.lastLicenseDate,
  });

  Vehicle copyWith({
    String? carType,
    String? plateNumber,
    String? color,
    VehicleStatus? status,
    DateTime? lastInsuranceDate,
    DateTime? lastLicenseDate,
    List<MaintenanceRecord>? maintenanceRecords,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id,
      carType: carType ?? this.carType,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      status: status ?? this.status,
      lastInsuranceDate: lastInsuranceDate ?? this.lastInsuranceDate,
      lastLicenseDate: lastLicenseDate ?? this.lastLicenseDate,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// تنبيه: هل التأمين أو الترخيص قارب على الانتهاء (خلال 30 يوم) أو منتهٍ فعلاً؟
  bool get hasExpiryWarning {
    final now = DateTime.now();
    bool checkExpiry(DateTime? date) {
      if (date == null) return false;
      final daysLeft = date.difference(now).inDays;
      return daysLeft <= 30;
    }
    return checkExpiry(lastInsuranceDate) || checkExpiry(lastLicenseDate);
  }
}
