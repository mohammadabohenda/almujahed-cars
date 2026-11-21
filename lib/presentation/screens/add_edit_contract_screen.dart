// ============================================================================
// ملف: add_edit_contract_screen.dart
// الوظيفة: شاشة موحّدة لإضافة عقد جديد أو تعديل عقد موجود (نفس النموذج).
// تحتوي على: اختيار السيارة من قائمة الأسطول (بدل الكتابة اليدوية)، بيانات
// المستأجر، بيانات العقد (تواريخ + حساب أيام تلقائي + غرامة تأخير يومية)،
// نوع التأجير، الملاحظات، رفع صورتي الهوية ورخصة القيادة، وتوقيع المستأجر.
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/core/utils/date_helper.dart';
import 'package:almugahed_cars/core/utils/validators.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/services/notification_service.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';
import 'package:almugahed_cars/presentation/providers/contract_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/screens/add_edit_vehicle_screen.dart';
import 'package:almugahed_cars/presentation/screens/signature_capture_screen.dart';
import 'package:almugahed_cars/presentation/widgets/custom_text_field.dart';
import 'package:almugahed_cars/presentation/widgets/image_picker_field.dart';

class AddEditContractScreen extends ConsumerStatefulWidget {
  /// إذا كان [existingContract] غير null فإن الشاشة تعمل في وضع "تعديل"،
  /// وإلا فهي في وضع "إضافة".
  final Contract? existingContract;

  const AddEditContractScreen({super.key, this.existingContract});

  @override
  ConsumerState<AddEditContractScreen> createState() =>
      _AddEditContractScreenState();
}

class _AddEditContractScreenState extends ConsumerState<AddEditContractScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  // بيانات المستأجر
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _passportCtrl;
  late final TextEditingController _licenseNumberCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;

  // بيانات العقد
  late final TextEditingController _deliveryPlaceCtrl;
  late final TextEditingController _daysCtrl;
  late final TextEditingController _advanceCtrl;
  late final TextEditingController _dailyLateFeeCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _birthDate;
  DateTime? _pickupDate;
  DateTime? _dropoffDate;
  RentalType _rentalType = RentalType.withoutDriver;

  // السيارة المختارة من الأسطول
  String? _selectedVehicleId;
  String _selectedCarType = '';
  String _selectedPlateNumber = '';

  File? _identityImageFile;
  File? _licenseImageFile;
  bool _identityImageRemoved = false;
  bool _licenseImageRemoved = false;

  // التوقيع الإلكتروني: مسار محفوظ فعليًا على القرص (وليس bytes مؤقتة)
  String? _signaturePath;
  bool _signatureRemoved = false;

  bool _isSaving = false;
  bool get _isEditMode => widget.existingContract != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingContract;

    _fullNameCtrl = TextEditingController(text: c?.fullName ?? '');
    _birthPlaceCtrl = TextEditingController(text: c?.birthPlace ?? '');
    _nationalIdCtrl = TextEditingController(text: c?.nationalIdNumber ?? '');
    _passportCtrl = TextEditingController(text: c?.passportNumber ?? '');
    _licenseNumberCtrl = TextEditingController(text: c?.licenseNumber ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _phoneCtrl = TextEditingController(text: c?.phoneNumber ?? '');
    _deliveryPlaceCtrl = TextEditingController(text: c?.deliveryPlace ?? '');
    _daysCtrl = TextEditingController(text: c?.numberOfDays.toString() ?? '1');
    _advanceCtrl = TextEditingController(
        text: c?.advancePayment != null ? c!.advancePayment.toString() : '');
    _dailyLateFeeCtrl = TextEditingController(
        text: c != null ? c.dailyLateFee.toString() : '0');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');

    _birthDate = c?.birthDate;
    _pickupDate = c?.pickupDate;
    _dropoffDate = c?.dropoffDate;
    _rentalType = c?.rentalType ?? RentalType.withoutDriver;

    _selectedVehicleId = c?.vehicleId;
    _selectedCarType = c?.carType ?? '';
    _selectedPlateNumber = c?.plateNumber ?? '';
    _signaturePath = c?.signaturePath;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _nationalIdCtrl.dispose();
    _passportCtrl.dispose();
    _licenseNumberCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _deliveryPlaceCtrl.dispose();
    _daysCtrl.dispose();
    _advanceCtrl.dispose();
    _dailyLateFeeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? initialValue,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialValue ?? now,
      firstDate: firstDate ?? DateTime(1940),
      lastDate: lastDate ?? DateTime(now.year + 5),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      onPicked(picked);
      _recalculateDays();
    }
  }

  /// إعادة حساب عدد الأيام تلقائيًا كلما تغيّر تاريخ الاستلام أو التسليم
  void _recalculateDays() {
    if (_pickupDate != null && _dropoffDate != null) {
      final days = DateHelper.calculateDays(_pickupDate!, _dropoffDate!);
      setState(() {
        _daysCtrl.text = days.toString();
      });
    }
  }

  Future<void> _captureSignature() async {
    final bytes = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(builder: (_) => const SignatureCaptureScreen()),
    );
    if (bytes == null) return;

    // نحفظ صورة التوقيع فورًا كملف دائم، ونخزّن مساره فقط.
    final imageStorage = ref.read(imageStorageServiceProvider);
    final path = await imageStorage.saveImageBytes(bytes, AppConstants.signaturesFolder);
    setState(() {
      _signaturePath = path;
      _signatureRemoved = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVehicleId == null) {
      _showSnack('يرجى اختيار سيارة من قائمة الأسطول');
      return;
    }
    if (_birthDate == null) {
      _showSnack('يرجى تحديد تاريخ الولادة');
      return;
    }
    if (_pickupDate == null) {
      _showSnack('يرجى تحديد تاريخ الاستلام');
      return;
    }
    if (_dropoffDate == null) {
      _showSnack('يرجى تحديد تاريخ التسليم');
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final id = widget.existingContract?.id ?? _uuid.v4();

    final contract = Contract(
      id: id,
      vehicleId: _selectedVehicleId,
      carType: _selectedCarType,
      plateNumber: _selectedPlateNumber,
      fullName: _fullNameCtrl.text.trim(),
      birthDate: _birthDate!,
      birthPlace: _birthPlaceCtrl.text.trim(),
      nationalIdNumber: _nationalIdCtrl.text.trim(),
      passportNumber: _passportCtrl.text.trim(),
      licenseNumber: _licenseNumberCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      deliveryPlace: _deliveryPlaceCtrl.text.trim(),
      pickupDate: _pickupDate!,
      dropoffDate: _dropoffDate!,
      numberOfDays: int.tryParse(_daysCtrl.text.trim()) ?? 1,
      advancePayment: double.tryParse(_advanceCtrl.text.trim()) ?? 0,
      dailyLateFee: double.tryParse(_dailyLateFeeCtrl.text.trim()) ?? 0,
      actualReturnDate: widget.existingContract?.actualReturnDate,
      rentalType: _rentalType,
      notes: _notesCtrl.text.trim(),
      identityImagePath: _isEditMode
          ? (_identityImageRemoved ? null : widget.existingContract!.identityImagePath)
          : null,
      licenseImagePath: _isEditMode
          ? (_licenseImageRemoved ? null : widget.existingContract!.licenseImagePath)
          : null,
      signaturePath: _signatureRemoved ? null : _signaturePath,
      createdAt: widget.existingContract?.createdAt ?? now,
      updatedAt: now,
    );

    final controller = ref.read(contractsControllerProvider.notifier);
    bool success;

    if (_isEditMode) {
      success = await controller.updateContract(
        contract,
        newIdentityImageFile: _identityImageFile,
        newLicenseImageFile: _licenseImageFile,
      );
    } else {
      success = await controller.addContract(
        contract,
        identityImageFile: _identityImageFile,
        licenseImageFile: _licenseImageFile,
      );
    }

    // بمجرد إسناد عقد جديد لسيارة، نجعل حالتها "مؤجرة" تلقائيًا (إن لم تكن
    // كذلك بالفعل)، حتى لا يتم اختيارها بالخطأ لعقد آخر في نفس الفترة.
    if (success) {
      await ref
          .read(vehiclesControllerProvider.notifier)
          .setVehicleStatus(_selectedVehicleId!, VehicleStatus.rented);
      // جدولة/تحديث تذكير موعد التسليم (يوم واحد قبل dropoffDate الساعة 9 صباحًا)
      await NotificationService.instance.scheduleReturnReminder(contract);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSnack(_isEditMode ? 'تم تعديل العقد بنجاح' : 'تم إضافة العقد بنجاح');
      Navigator.pop(context, true);
    } else {
      _showSnack('حدث خطأ أثناء حفظ العقد، حاول مرة أخرى');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesState = ref.watch(vehiclesControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'تعديل العقد' : 'عقد تأجير جديد'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _SectionTitle(icon: Icons.directions_car_outlined, title: 'السيارة'),
              const SizedBox(height: 12),
              if (vehiclesState.vehicles.isEmpty)
                Card(
                  color: AppColors.warning.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لا توجد سيارات في الأسطول بعد. أضف سيارة أولًا لتتمكن من ربطها بالعقد.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة سيارة الآن'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'اختر السيارة',
                    prefixIcon: Icon(Icons.directions_car_filled_outlined),
                  ),
                  items: vehiclesState.vehicles.map((v) {
                    final isTakenByOther = v.status == VehicleStatus.rented &&
                        v.id != widget.existingContract?.vehicleId;
                    return DropdownMenuItem(
                      value: v.id,
                      enabled: !isTakenByOther,
                      child: Text(
                        '${v.carType} - ${v.plateNumber}${isTakenByOther ? ' (مؤجرة حاليًا)' : ''}',
                        style: TextStyle(
                          color: isTakenByOther ? AppColors.textSecondary : null,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final vehicle = vehiclesState.vehicles.firstWhere((v) => v.id == id);
                    setState(() {
                      _selectedVehicleId = id;
                      _selectedCarType = vehicle.carType;
                      _selectedPlateNumber = vehicle.plateNumber;
                    });
                  },
                  validator: (v) => v == null ? 'يرجى اختيار سيارة' : null,
                ),

              const SizedBox(height: 26),
              _SectionTitle(icon: Icons.person_outline, title: 'بيانات المستأجر'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _fullNameCtrl,
                label: 'الاسم الكامل',
                icon: Icons.badge_outlined,
                validator: (v) => Validators.required(v, fieldName: 'الاسم الكامل'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: TextEditingController(
                  text: _birthDate != null ? DateHelper.format(_birthDate!) : '',
                ),
                label: 'تاريخ الولادة',
                icon: Icons.cake_outlined,
                readOnly: true,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () => _pickDate(
                  initialValue: _birthDate,
                  lastDate: DateTime.now(),
                  onPicked: (d) => setState(() => _birthDate = d),
                ),
                validator: (_) => _birthDate == null ? 'تاريخ الولادة مطلوب' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _birthPlaceCtrl,
                label: 'مكان الولادة',
                icon: Icons.location_on_outlined,
                validator: (v) => Validators.required(v, fieldName: 'مكان الولادة'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _nationalIdCtrl,
                label: 'رقم البطاقة الشخصية',
                icon: Icons.credit_card_outlined,
                validator: (v) => Validators.generalId(v, fieldName: 'رقم البطاقة الشخصية'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _passportCtrl,
                label: 'رقم جواز السفر',
                icon: Icons.menu_book_outlined,
                validator: (v) => Validators.generalId(v, fieldName: 'رقم جواز السفر'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _licenseNumberCtrl,
                label: 'رقم رخصة القيادة',
                icon: Icons.badge_outlined,
                validator: (v) => Validators.generalId(v, fieldName: 'رقم رخصة القيادة'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _addressCtrl,
                label: 'العنوان',
                icon: Icons.home_outlined,
                maxLines: 2,
                validator: (v) => Validators.required(v, fieldName: 'العنوان'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneCtrl,
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),

              const SizedBox(height: 26),
              _SectionTitle(icon: Icons.description_outlined, title: 'بيانات العقد'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _deliveryPlaceCtrl,
                label: 'مكان التسليم',
                icon: Icons.place_outlined,
                validator: (v) => Validators.required(v, fieldName: 'مكان التسليم'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(
                        text: _pickupDate != null ? DateHelper.format(_pickupDate!) : '',
                      ),
                      label: 'تاريخ الاستلام',
                      icon: Icons.event_available_outlined,
                      readOnly: true,
                      onTap: () => _pickDate(
                        initialValue: _pickupDate,
                        onPicked: (d) => setState(() => _pickupDate = d),
                      ),
                      validator: (_) => _pickupDate == null ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(
                        text: _dropoffDate != null ? DateHelper.format(_dropoffDate!) : '',
                      ),
                      label: 'تاريخ التسليم',
                      icon: Icons.event_busy_outlined,
                      readOnly: true,
                      onTap: () => _pickDate(
                        initialValue: _dropoffDate,
                        firstDate: _pickupDate,
                        onPicked: (d) => setState(() => _dropoffDate = d),
                      ),
                      validator: (_) => _dropoffDate == null ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _daysCtrl,
                      label: 'عدد الأيام',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.positiveInt(v, fieldName: 'عدد الأيام'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _advanceCtrl,
                      label: 'السلفة',
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => Validators.numeric(v, allowEmpty: true, fieldName: 'السلفة'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 4),
                child: Text(
                  'يتم احتساب عدد الأيام تلقائيًا، ويمكنك تعديله يدويًا عند الحاجة.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _dailyLateFeeCtrl,
                label: 'غرامة التأخير عن كل يوم',
                icon: Icons.rule_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => Validators.numeric(v, allowEmpty: true, fieldName: 'غرامة التأخير'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 4),
                child: Text(
                  'تُستخدم لاحتساب غرامة التأخير تلقائيًا عند تسجيل الإرجاع الفعلي للسيارة بعد موعد التسليم.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 18),
              Text('نوع التأجير',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RentalTypeChip(
                      label: RentalType.withoutDriver.label,
                      selected: _rentalType == RentalType.withoutDriver,
                      onTap: () => setState(() => _rentalType = RentalType.withoutDriver),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RentalTypeChip(
                      label: RentalType.withDriver.label,
                      selected: _rentalType == RentalType.withDriver,
                      onTap: () => setState(() => _rentalType = RentalType.withDriver),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _notesCtrl,
                label: 'ملاحظات',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 26),
              _SectionTitle(icon: Icons.attach_file_outlined, title: 'المرفقات'),
              const SizedBox(height: 12),
              ImagePickerField(
                title: 'صورة الهوية الشخصية',
                pickedFile: _identityImageFile,
                existingImagePath:
                    _identityImageRemoved ? null : widget.existingContract?.identityImagePath,
                onImagePicked: (file) => setState(() {
                  _identityImageFile = file;
                  _identityImageRemoved = false;
                }),
                onImageRemoved: () => setState(() {
                  _identityImageFile = null;
                  _identityImageRemoved = true;
                }),
              ),
              const SizedBox(height: 18),
              ImagePickerField(
                title: 'صورة رخصة القيادة',
                pickedFile: _licenseImageFile,
                existingImagePath:
                    _licenseImageRemoved ? null : widget.existingContract?.licenseImagePath,
                onImagePicked: (file) => setState(() {
                  _licenseImageFile = file;
                  _licenseImageRemoved = false;
                }),
                onImageRemoved: () => setState(() {
                  _licenseImageFile = null;
                  _licenseImageRemoved = true;
                }),
              ),

              const SizedBox(height: 26),
              _SectionTitle(icon: Icons.draw_outlined, title: 'توقيع المستأجر'),
              const SizedBox(height: 12),
              if (_signaturePath != null && !_signatureRemoved)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: FileImage(File(_signaturePath!)),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _captureSignature,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('إعادة التوقيع'),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _signaturePath = null;
                              _signatureRemoved = true;
                            }),
                            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            label: Text('حذف', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _captureSignature,
                  icon: const Icon(Icons.draw_outlined),
                  label: const Text('التقاط توقيع المستأجر'),
                ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondaryWhite,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isEditMode ? 'حفظ التعديلات' : 'حفظ العقد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentRed, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _RentalTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RentalTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlack : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.secondaryWhite : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
