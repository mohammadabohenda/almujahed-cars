// ============================================================================
// ملف: vehicle_details_screen.dart
// الوظيفة: عرض تفاصيل سيارة معيّنة، حالتها، تواريخ التأمين/الترخيص، وسجل
// الصيانة الكامل، مع إمكانية إضافة سجل صيانة جديد (تاريخ + وصف + تكلفة).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/core/utils/date_helper.dart';
import 'package:almugahed_cars/core/utils/validators.dart';
import 'package:almugahed_cars/domain/entities/maintenance_record.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/screens/add_edit_vehicle_screen.dart';
import 'package:almugahed_cars/presentation/widgets/vehicle_status_badge.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  final String vehicleId;
  const VehicleDetailsScreen({super.key, required this.vehicleId});

  Future<void> _showAddMaintenanceDialog(BuildContext context, WidgetRef ref) async {
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة سجل صيانة'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('تاريخ الصيانة: ${DateHelper.format(selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
                  TextFormField(
                    controller: descCtrl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(labelText: 'وصف الصيانة'),
                    validator: (v) => Validators.required(v, fieldName: 'الوصف'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: costCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'التكلفة'),
                    validator: (v) => Validators.numeric(v, fieldName: 'التكلفة'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final record = MaintenanceRecord(
                  id: const Uuid().v4(),
                  date: selectedDate,
                  description: descCtrl.text.trim(),
                  cost: double.tryParse(costCtrl.text.trim()) ?? 0,
                );
                await ref
                    .read(vehiclesControllerProvider.notifier)
                    .addMaintenanceRecord(vehicleId, record);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(singleVehicleProvider(vehicleId));
    final isManager = ref.watch(authControllerProvider.notifier).isManager;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل السيارة'),
          actions: [
            if (isManager)
              vehicleAsync.when(
                data: (v) => v == null
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditVehicleScreen(existingVehicle: v),
                            ),
                          );
                          if (updated == true) {
                            ref.invalidate(singleVehicleProvider(vehicleId));
                          }
                        },
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        ),
        body: vehicleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('حدث خطأ: $e')),
          data: (vehicle) {
            if (vehicle == null) {
              return const Center(child: Text('لم يتم العثور على السيارة'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(vehicle.carType,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            VehicleStatusBadge(status: vehicle.status),
                          ],
                        ),
                        const Divider(height: 24),
                        _row('رقم اللوحة', vehicle.plateNumber),
                        _row('اللون', vehicle.color),
                        _row(
                          'آخر تأمين',
                          vehicle.lastInsuranceDate != null
                              ? DateHelper.format(vehicle.lastInsuranceDate!)
                              : '-',
                        ),
                        _row(
                          'آخر ترخيص',
                          vehicle.lastLicenseDate != null
                              ? DateHelper.format(vehicle.lastLicenseDate!)
                              : '-',
                        ),
                        if (vehicle.hasExpiryWarning)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'التأمين أو الترخيص قارب على الانتهاء (خلال 30 يومًا) أو انتهى بالفعل.',
                                    style: TextStyle(color: AppColors.warning, fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سجل الصيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () => _showAddMaintenanceDialog(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة سجل'),
                    ),
                  ],
                ),
                if (vehicle.maintenanceRecords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('لا توجد سجلات صيانة بعد',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...vehicle.maintenanceRecords.reversed.map(
                    (m) => Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        leading: Icon(Icons.build_outlined, color: AppColors.accentRed),
                        title: Text(m.description),
                        subtitle: Text(DateHelper.format(m.date)),
                        trailing: Text(
                          m.cost.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
