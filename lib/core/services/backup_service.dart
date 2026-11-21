// ============================================================================
// ملف: backup_service.dart
// الوظيفة: تصدير جميع بيانات التطبيق (العقود + السيارات + المستخدمين) إلى
// ملف JSON واحد يمكن مشاركته/حفظه خارج الجهاز، واستيراده لاحقًا لاستعادة
// البيانات (مثلاً بعد تهيئة الجهاز أو تثبيت التطبيق من جديد).
//
// ملاحظة مهمة: النسخة الاحتياطية تشمل "البيانات" فقط (نصوص/أرقام/تواريخ)
// وليس ملفات الصور الفعلية (الهوية/الرخصة/التوقيع)، لأن هذه الصور ضخمة الحجم
// نسبيًا وتُخزَّن كملفات منفصلة. عند الاستيراد على نفس الجهاز الذي لم تُحذف
// فيه مساحة تخزين التطبيق ستبقى الصور تعمل، أما عند الاستيراد على جهاز آخر
// فستظهر بطاقات المرفقات فارغة (يمكن رفع الصور من جديد لكل عقد عند الحاجة).
// ============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/data/datasources/auth_local_datasource.dart';
import 'package:almugahed_cars/data/datasources/contract_local_datasource.dart';
import 'package:almugahed_cars/data/datasources/vehicle_local_datasource.dart';
import 'package:almugahed_cars/data/models/contract_model.dart';
import 'package:almugahed_cars/data/models/maintenance_record_model.dart';
import 'package:almugahed_cars/data/models/user_model.dart';
import 'package:almugahed_cars/data/models/vehicle_model.dart';

class BackupService {
  final ContractLocalDataSource contractDataSource;
  final VehicleLocalDataSource vehicleDataSource;
  final AuthLocalDataSource authDataSource;

  BackupService({
    required this.contractDataSource,
    required this.vehicleDataSource,
    required this.authDataSource,
  });

  Map<String, dynamic> _contractToJson(ContractModel c) => {
        'id': c.id,
        'vehicleId': c.vehicleId,
        'carType': c.carType,
        'plateNumber': c.plateNumber,
        'fullName': c.fullName,
        'birthDate': c.birthDate.toIso8601String(),
        'birthPlace': c.birthPlace,
        'nationalIdNumber': c.nationalIdNumber,
        'passportNumber': c.passportNumber,
        'licenseNumber': c.licenseNumber,
        'address': c.address,
        'phoneNumber': c.phoneNumber,
        'deliveryPlace': c.deliveryPlace,
        'pickupDate': c.pickupDate.toIso8601String(),
        'dropoffDate': c.dropoffDate.toIso8601String(),
        'numberOfDays': c.numberOfDays,
        'advancePayment': c.advancePayment,
        'rentalTypeIndex': c.rentalTypeIndex,
        'notes': c.notes,
        'dailyLateFee': c.dailyLateFee,
        'actualReturnDate': c.actualReturnDate?.toIso8601String(),
        'identityImagePath': c.identityImagePath,
        'licenseImagePath': c.licenseImagePath,
        'signaturePath': c.signaturePath,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      };

  ContractModel _contractFromJson(Map<String, dynamic> j) => ContractModel(
        id: j['id'],
        vehicleId: j['vehicleId'],
        carType: j['carType'],
        plateNumber: j['plateNumber'],
        fullName: j['fullName'],
        birthDate: DateTime.parse(j['birthDate']),
        birthPlace: j['birthPlace'],
        nationalIdNumber: j['nationalIdNumber'],
        passportNumber: j['passportNumber'],
        licenseNumber: j['licenseNumber'],
        address: j['address'],
        phoneNumber: j['phoneNumber'],
        deliveryPlace: j['deliveryPlace'],
        pickupDate: DateTime.parse(j['pickupDate']),
        dropoffDate: DateTime.parse(j['dropoffDate']),
        numberOfDays: j['numberOfDays'],
        advancePayment: (j['advancePayment'] as num).toDouble(),
        rentalTypeIndex: j['rentalTypeIndex'],
        notes: j['notes'],
        dailyLateFee: ((j['dailyLateFee'] as num?) ?? 0).toDouble(),
        actualReturnDate:
            j['actualReturnDate'] != null ? DateTime.parse(j['actualReturnDate']) : null,
        identityImagePath: j['identityImagePath'],
        licenseImagePath: j['licenseImagePath'],
        signaturePath: j['signaturePath'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );

  Map<String, dynamic> _vehicleToJson(VehicleModel v) => {
        'id': v.id,
        'carType': v.carType,
        'plateNumber': v.plateNumber,
        'color': v.color,
        'statusIndex': v.statusIndex,
        'lastInsuranceDate': v.lastInsuranceDate?.toIso8601String(),
        'lastLicenseDate': v.lastLicenseDate?.toIso8601String(),
        'maintenanceRecords': v.maintenanceRecords
            .map((m) => {
                  'id': m.id,
                  'date': m.date.toIso8601String(),
                  'description': m.description,
                  'cost': m.cost,
                })
            .toList(),
        'createdAt': v.createdAt.toIso8601String(),
        'updatedAt': v.updatedAt.toIso8601String(),
      };

  VehicleModel _vehicleFromJson(Map<String, dynamic> j) => VehicleModel(
        id: j['id'],
        carType: j['carType'],
        plateNumber: j['plateNumber'],
        color: j['color'],
        statusIndex: j['statusIndex'],
        lastInsuranceDate:
            j['lastInsuranceDate'] != null ? DateTime.parse(j['lastInsuranceDate']) : null,
        lastLicenseDate:
            j['lastLicenseDate'] != null ? DateTime.parse(j['lastLicenseDate']) : null,
        maintenanceRecords: (j['maintenanceRecords'] as List)
            .map((m) => MaintenanceRecordModel(
                  id: m['id'],
                  date: DateTime.parse(m['date']),
                  description: m['description'],
                  cost: (m['cost'] as num).toDouble(),
                ))
            .toList(),
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
      );

  Map<String, dynamic> _userToJson(UserModel u) => {
        'id': u.id,
        'username': u.username,
        'passwordHash': u.passwordHash,
        'roleIndex': u.roleIndex,
        'createdAt': u.createdAt.toIso8601String(),
      };

  UserModel _userFromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        username: j['username'],
        passwordHash: j['passwordHash'],
        roleIndex: j['roleIndex'],
        createdAt: DateTime.parse(j['createdAt']),
      );

  /// يبني ملف JSON بكل بيانات التطبيق، يحفظه محليًا، ثم يفتح نافذة المشاركة
  /// النظامية (حفظ/إرسال) عبر share_plus. يرجع مسار الملف الناتج.
  Future<File> exportBackup() async {
    final data = {
      'app': 'ALMUGAHED_CARS_BACKUP',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'contracts': contractDataSource.getAll().map(_contractToJson).toList(),
      'vehicles': vehicleDataSource.getAll().map(_vehicleToJson).toList(),
      'users': authDataSource.getAll().map(_userToJson).toList(),
    };

    final appDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(appDir.path, AppConstants.exportsFolder));
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(exportsDir.path, 'almugahed_backup_$timestamp.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية - ALMUGAHED CARS');

    return file;
  }

  /// يقرأ ملف نسخة احتياطية سابق ويستبدل كل البيانات الحالية بمحتواه.
  /// (يُفترض أن يسبقه تأكيد صريح من المستخدم في الواجهة قبل الاستدعاء).
  Future<void> importBackup(File file) async {
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (data['app'] != 'ALMUGAHED_CARS_BACKUP') {
      throw Exception('ملف غير صالح: ليس نسخة احتياطية لتطبيق ALMUGAHED CARS');
    }

    final contracts = (data['contracts'] as List).map((e) => _contractFromJson(e)).toList();
    final vehicles = (data['vehicles'] as List).map((e) => _vehicleFromJson(e)).toList();
    final users = (data['users'] as List).map((e) => _userFromJson(e)).toList();

    await contractDataSource.clearAll();
    for (final c in contracts) {
      await contractDataSource.save(c);
    }

    await vehicleDataSource.clearAll();
    for (final v in vehicles) {
      await vehicleDataSource.save(v);
    }

    await authDataSource.clearAll();
    for (final u in users) {
      await authDataSource.save(u);
    }
  }
}
