// ============================================================================
// ملف: contract.dart  (Domain Entity)
// الوظيفة: يمثل الكيان الأساسي "عقد التأجير" بشكل مستقل تمامًا عن أي تفاصيل
// تخزين (Hive/SQLite/إلخ). هذه الطبقة هي قلب Clean Architecture ولا تعرف شيئًا
// عن قواعد البيانات أو الواجهات، فقط منطق وبيانات العمل (Business Logic).
// ============================================================================

import 'package:almugahed_cars/core/constants/app_constants.dart';

class Contract {
  final String id;

  // بيانات السيارة (vehicleId يربط العقد بسيارة من شاشة إدارة الأسطول،
  // وcarType/plateNumber يُحفظان أيضًا داخل العقد كنسخة تاريخية ثابتة
  // حتى لو تم لاحقًا تعديل/حذف بيانات السيارة نفسها)
  final String? vehicleId;
  final String carType;
  final String plateNumber;

  // بيانات المستأجر
  final String fullName;
  final DateTime birthDate;
  final String birthPlace;
  final String nationalIdNumber;
  final String passportNumber;
  final String licenseNumber;
  final String address;
  final String phoneNumber;

  // بيانات العقد
  final String deliveryPlace;
  final DateTime pickupDate;
  final DateTime dropoffDate;
  final int numberOfDays;
  final double advancePayment;
  final RentalType rentalType;
  final String notes;

  // غرامة التأخير
  final double dailyLateFee; // قيمة الغرامة عن كل يوم تأخير
  final DateTime? actualReturnDate; // تاريخ إرجاع السيارة فعليًا (لإغلاق العقد)

  // المرفقات (مسارات الصور المحفوظة محليًا)
  final String? identityImagePath;
  final String? licenseImagePath;
  final String? signaturePath; // توقيع المستأجر الإلكتروني

  final DateTime createdAt;
  final DateTime updatedAt;

  const Contract({
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
    required this.rentalType,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.dailyLateFee = 0,
    this.actualReturnDate,
    this.identityImagePath,
    this.licenseImagePath,
    this.signaturePath,
  });

  /// عدد أيام التأخير الفعلية (0 لو لسا العقد ما انقفل أو ما في تأخير)
  int get lateDays {
    if (actualReturnDate == null) return 0;
    final diff = actualReturnDate!.difference(dropoffDate).inDays;
    return diff > 0 ? diff : 0;
  }

  /// قيمة غرامة التأخير المحسوبة تلقائيًا
  double get calculatedLateFee => lateDays * dailyLateFee;

  bool get isClosed => actualReturnDate != null;

  Contract copyWith({
    String? vehicleId,
    String? carType,
    String? plateNumber,
    String? fullName,
    DateTime? birthDate,
    String? birthPlace,
    String? nationalIdNumber,
    String? passportNumber,
    String? licenseNumber,
    String? address,
    String? phoneNumber,
    String? deliveryPlace,
    DateTime? pickupDate,
    DateTime? dropoffDate,
    int? numberOfDays,
    double? advancePayment,
    RentalType? rentalType,
    String? notes,
    double? dailyLateFee,
    DateTime? actualReturnDate,
    String? identityImagePath,
    String? licenseImagePath,
    String? signaturePath,
    DateTime? updatedAt,
  }) {
    return Contract(
      id: id,
      vehicleId: vehicleId ?? this.vehicleId,
      carType: carType ?? this.carType,
      plateNumber: plateNumber ?? this.plateNumber,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      nationalIdNumber: nationalIdNumber ?? this.nationalIdNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryPlace: deliveryPlace ?? this.deliveryPlace,
      pickupDate: pickupDate ?? this.pickupDate,
      dropoffDate: dropoffDate ?? this.dropoffDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      advancePayment: advancePayment ?? this.advancePayment,
      rentalType: rentalType ?? this.rentalType,
      notes: notes ?? this.notes,
      dailyLateFee: dailyLateFee ?? this.dailyLateFee,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      identityImagePath: identityImagePath ?? this.identityImagePath,
      licenseImagePath: licenseImagePath ?? this.licenseImagePath,
      signaturePath: signaturePath ?? this.signaturePath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
