// ============================================================================
// ملف: add_edit_vehicle_screen.dart
// الوظيفة: شاشة موحّدة لإضافة سيارة جديدة للأسطول أو تعديل بياناتها، بما في
// ذلك حالتها وتاريخ آخر تأمين وترخيص.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/core/utils/date_helper.dart';
import 'package:almugahed_cars/core/utils/validators.dart';
import 'package:almugahed_cars/domain/entities/vehicle.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/widgets/custom_text_field.dart';

class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle? existingVehicle;
  const AddEditVehicleScreen({super.key, this.existingVehicle});

  @override
  ConsumerState<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  late final TextEditingController _carTypeCtrl;
  late final TextEditingController _plateNumberCtrl;
  late final TextEditingController _colorCtrl;

  VehicleStatus _status = VehicleStatus.available;
  DateTime? _lastInsuranceDate;
  DateTime? _lastLicenseDate;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.existingVehicle;
    _carTypeCtrl = TextEditingController(text: v?.carType ?? '');
    _plateNumberCtrl = TextEditingController(text: v?.plateNumber ?? '');
    _colorCtrl = TextEditingController(text: v?.color ?? '');
    _status = v?.status ?? VehicleStatus.available;
    _lastInsuranceDate = v?.lastInsuranceDate;
    _lastLicenseDate = v?.lastLicenseDate;
  }

  @override
  void dispose() {
    _carTypeCtrl.dispose();
    _plateNumberCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime? initial, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ar'),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final vehicle = Vehicle(
      id: widget.existingVehicle?.id ?? _uuid.v4(),
      carType: _carTypeCtrl.text.trim(),
      plateNumber: _plateNumberCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      status: _status,
      lastInsuranceDate: _lastInsuranceDate,
      lastLicenseDate: _lastLicenseDate,
      maintenanceRecords: widget.existingVehicle?.maintenanceRecords ?? const [],
      createdAt: widget.existingVehicle?.createdAt ?? now,
      updatedAt: now,
    );

    final controller = ref.read(vehiclesControllerProvider.notifier);
    final success = _isEditMode
        ? await controller.updateVehicle(vehicle)
        : await controller.addVehicle(vehicle);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء حفظ السيارة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'تعديل السيارة' : 'سيارة جديدة')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: _carTypeCtrl,
                label: 'نوع السيارة',
                icon: Icons.directions_car_outlined,
                validator: (v) => Validators.required(v, fieldName: 'نوع السيارة'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _plateNumberCtrl,
                label: 'رقم اللوحة',
                icon: Icons.confirmation_number_outlined,
                validator: (v) => Validators.generalId(v, fieldName: 'رقم اللوحة'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _colorCtrl,
                label: 'اللون',
                icon: Icons.color_lens_outlined,
                validator: (v) => Validators.required(v, fieldName: 'اللون'),
              ),
              const SizedBox(height: 18),
              Text('حالة السيارة',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: VehicleStatus.values.map((s) {
                  final selected = _status == s;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _status = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: TextEditingController(
                  text: _lastInsuranceDate != null ? DateHelper.format(_lastInsuranceDate!) : '',
                ),
                label: 'تاريخ آخر تأمين',
                icon: Icons.shield_outlined,
                readOnly: true,
                onTap: () => _pickDate(_lastInsuranceDate, (d) => setState(() => _lastInsuranceDate = d)),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: TextEditingController(
                  text: _lastLicenseDate != null ? DateHelper.format(_lastLicenseDate!) : '',
                ),
                label: 'تاريخ آخر ترخيص',
                icon: Icons.assignment_turned_in_outlined,
                readOnly: true,
                onTap: () => _pickDate(_lastLicenseDate, (d) => setState(() => _lastLicenseDate = d)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  'سيظهر تنبيه تلقائي في شاشة الأسطول لو اقترب التأمين أو الترخيص من الانتهاء (خلال 30 يومًا).',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryWhite),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isEditMode ? 'حفظ التعديلات' : 'حفظ السيارة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
