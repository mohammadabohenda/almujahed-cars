// ============================================================================
// ملف: contract_model.dart  (Data Layer)
// الوظيفة: تمثيل عقد التأجير كما يُخزَّن فعليًا داخل قاعدة بيانات Hive،
// ويحتوي أيضًا على TypeAdapter مكتوب يدويًا (Manual Adapter) بدلاً من الاعتماد
// على build_runner / hive_generator، وذلك لتجنّب أي خطوة بناء إضافية وجعل
// المشروع يعمل مباشرة. كما يحتوي على دوال تحويل (Mapping) من/إلى Entity.
// ============================================================================

import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';

class ContractModel extends HiveObject {
  String id;
  String? vehicleId;
  String carType;
  String plateNumber;
  String fullName;
  DateTime birthDate;
  String birthPlace;
  String nationalIdNumber;
  String passportNumber;
  String licenseNumber;
  String address;
  String phoneNumber;
  String deliveryPlace;
  DateTime pickupDate;
  DateTime dropoffDate;
  int numberOfDays;
  double advancePayment;
  int rentalTypeIndex; // 0 = بدون سائق, 1 = مع سائق
  String notes;
  double dailyLateFee;
  DateTime? actualReturnDate;
  String? identityImagePath;
  String? licenseImagePath;
  String? signaturePath;
  DateTime createdAt;
  DateTime updatedAt;

  ContractModel({
    required this.id,
    this.vehicleId,
    required this.carType,
    required this.plateNumber,
    required this.fullName,
    required this.birthDate,
    required this.birthPlace,
    required this.nationalIdNumber,
    required this.passportNumber,
    required this.licenseNumber,
    required this.address,
    required this.phoneNumber,
    required this.deliveryPlace,
    required this.pickupDate,
    required this.dropoffDate,
    required this.numberOfDays,
    required this.advancePayment,
    required this.rentalTypeIndex,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.dailyLateFee = 0,
    this.actualReturnDate,
    this.identityImagePath,
    this.licenseImagePath,
    this.signaturePath,
  });

  /// تحويل من Entity (طبقة Domain) إلى Model (طبقة Data لتخزينه في Hive)
  factory ContractModel.fromEntity(Contract entity) {
    return ContractModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      carType: entity.carType,
      plateNumber: entity.plateNumber,
      fullName: entity.fullName,
      birthDate: entity.birthDate,
      birthPlace: entity.birthPlace,
      nationalIdNumber: entity.nationalIdNumber,
      passportNumber: entity.passportNumber,
      licenseNumber: entity.licenseNumber,
      address: entity.address,
      phoneNumber: entity.phoneNumber,
      deliveryPlace: entity.deliveryPlace,
      pickupDate: entity.pickupDate,
      dropoffDate: entity.dropoffDate,
      numberOfDays: entity.numberOfDays,
      advancePayment: entity.advancePayment,
      rentalTypeIndex: entity.rentalType.index,
      notes: entity.notes,
      dailyLateFee: entity.dailyLateFee,
      actualReturnDate: entity.actualReturnDate,
      identityImagePath: entity.identityImagePath,
      licenseImagePath: entity.licenseImagePath,
      signaturePath: entity.signaturePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// تحويل من Model إلى Entity لاستخدامه في باقي طبقات التطبيق
  Contract toEntity() {
    return Contract(
      id: id,
      vehicleId: vehicleId,
      carType: carType,
      plateNumber: plateNumber,
      fullName: fullName,
      birthDate: birthDate,
      birthPlace: birthPlace,
      nationalIdNumber: nationalIdNumber,
      passportNumber: passportNumber,
      licenseNumber: licenseNumber,
      address: address,
      phoneNumber: phoneNumber,
      deliveryPlace: deliveryPlace,
      pickupDate: pickupDate,
      dropoffDate: dropoffDate,
      numberOfDays: numberOfDays,
      advancePayment: advancePayment,
      rentalType: RentalType.values[rentalTypeIndex],
      notes: notes,
      dailyLateFee: dailyLateFee,
      actualReturnDate: actualReturnDate,
      identityImagePath: identityImagePath,
      licenseImagePath: licenseImagePath,
      signaturePath: signaturePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// TypeAdapter مكتوب يدويًا لتعليم Hive كيف يحوّل ContractModel إلى/من Binary.
/// typeId = 0 (يجب أن يبقى ثابتًا ولا يتكرر مع أي Adapter آخر في المشروع).
class ContractModelAdapter extends TypeAdapter<ContractModel> {
  @override
  final int typeId = 0;

  @override
  ContractModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContractModel(
      id: fields[0] as String,
      carType: fields[1] as String,
      plateNumber: fields[2] as String,
      fullName: fields[3] as String,
      birthDate: fields[4] as DateTime,
      birthPlace: fields[5] as String,
      nationalIdNumber: fields[6] as String,
      passportNumber: fields[7] as String,
      licenseNumber: fields[8] as String,
      address: fields[9] as String,
      phoneNumber: fields[10] as String,
      deliveryPlace: fields[11] as String,
      pickupDate: fields[12] as DateTime,
      dropoffDate: fields[13] as DateTime,
      numberOfDays: fields[14] as int,
      advancePayment: fields[15] as double,
      rentalTypeIndex: fields[16] as int,
      notes: fields[17] as String,
      identityImagePath: fields[18] as String?,
      licenseImagePath: fields[19] as String?,
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
      vehicleId: fields[22] as String?,
      dailyLateFee: (fields[23] as double?) ?? 0,
      actualReturnDate: fields[24] as DateTime?,
      signaturePath: fields[25] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContractModel obj) {
    writer
      ..writeByte(26) // عدد الحقول
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.carType)
      ..writeByte(2)
      ..write(obj.plateNumber)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.birthDate)
      ..writeByte(5)
      ..write(obj.birthPlace)
      ..writeByte(6)
      ..write(obj.nationalIdNumber)
      ..writeByte(7)
      ..write(obj.passportNumber)
      ..writeByte(8)
      ..write(obj.licenseNumber)
      ..writeByte(9)
      ..write(obj.address)
      ..writeByte(10)
      ..write(obj.phoneNumber)
      ..writeByte(11)
      ..write(obj.deliveryPlace)
      ..writeByte(12)
      ..write(obj.pickupDate)
      ..writeByte(13)
      ..write(obj.dropoffDate)
      ..writeByte(14)
      ..write(obj.numberOfDays)
      ..writeByte(15)
      ..write(obj.advancePayment)
      ..writeByte(16)
      ..write(obj.rentalTypeIndex)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.identityImagePath)
      ..writeByte(19)
      ..write(obj.licenseImagePath)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.vehicleId)
      ..writeByte(23)
      ..write(obj.dailyLateFee)
      ..writeByte(24)
      ..write(obj.actualReturnDate)
      ..writeByte(25)
      ..write(obj.signaturePath);
  }
}
