// ============================================================================
// ملف: contract_details_screen.dart
// الوظيفة: عرض كامل تفاصيل عقد معيّن (السيارة، المستأجر، العقد، المرفقات،
// التوقيع)، مع: تعديل، حذف (للمدير فقط)، تصدير/مشاركة PDF، وتسجيل الإرجاع
// الفعلي للسيارة مع احتساب غرامة التأخير تلقائيًا وإعادة السيارة إلى حالة
// "متاحة" في الأسطول.
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/services/notification_service.dart';
import 'package:almugahed_cars/core/services/pdf_contract_service.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/core/utils/date_helper.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/providers/contract_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/screens/add_edit_contract_screen.dart';
import 'package:almugahed_cars/presentation/widgets/full_screen_image_viewer.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String contractId;
  const ContractDetailsScreen({super.key, required this.contractId});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Contract contract) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العقد؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(contractsControllerProvider.notifier).deleteContract(contractId);
      await NotificationService.instance.cancelReminder(contractId);
      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف العقد بنجاح')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء حذف العقد')),
          );
        }
      }
    }
  }

  /// تسجيل الإرجاع الفعلي للسيارة: يطلب تاريخ الإرجاع، يحسب غرامة التأخير
  /// تلقائيًا بناءً على dailyLateFee، ثم يعيد السيارة لحالة "متاحة".
  Future<void> _registerActualReturn(BuildContext context, WidgetRef ref, Contract contract) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: contract.pickupDate,
      lastDate: DateTime(DateTime.now().year + 5),
      locale: const Locale('ar'),
      helpText: 'تاريخ الإرجاع الفعلي للسيارة',
    );
    if (picked == null || !context.mounted) return;

    final updatedContract = Contract(
      id: contract.id,
      vehicleId: contract.vehicleId,
      carType: contract.carType,
      plateNumber: contract.plateNumber,
      fullName: contract.fullName,
      birthDate: contract.birthDate,
      birthPlace: contract.birthPlace,
      nationalIdNumber: contract.nationalIdNumber,
      passportNumber: contract.passportNumber,
      licenseNumber: contract.licenseNumber,
      address: contract.address,
      phoneNumber: contract.phoneNumber,
      deliveryPlace: contract.deliveryPlace,
      pickupDate: contract.pickupDate,
      dropoffDate: contract.dropoffDate,
      numberOfDays: contract.numberOfDays,
      advancePayment: contract.advancePayment,
      dailyLateFee: contract.dailyLateFee,
      actualReturnDate: picked,
      rentalType: contract.rentalType,
      notes: contract.notes,
      identityImagePath: contract.identityImagePath,
      licenseImagePath: contract.licenseImagePath,
      signaturePath: contract.signaturePath,
      createdAt: contract.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await ref.read(contractsControllerProvider.notifier).updateContract(updatedContract);

    if (success && contract.vehicleId != null) {
      await ref
          .read(vehiclesControllerProvider.notifier)
          .setVehicleStatus(contract.vehicleId!, VehicleStatus.available);
      await NotificationService.instance.cancelReminder(contract.id);
    }

    if (context.mounted) {
      ref.invalidate(singleContractProvider(contractId));
      final lateFeeMsg = updatedContract.calculatedLateFee > 0
          ? ' — غرامة تأخير: ${updatedContract.calculatedLateFee.toStringAsFixed(2)}'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل الإرجاع الفعلي$lateFeeMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(singleContractProvider(contractId));
    final isManager = ref.watch(authControllerProvider.notifier).isManager;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل العقد'),
          actions: [
            contractAsync.when(
              data: (contract) => contract == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      tooltip: 'تصدير PDF',
                      onPressed: () => PdfContractService.previewAndPrint(contract),
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            contractAsync.when(
              data: (contract) => contract == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'تعديل',
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditContractScreen(existingContract: contract),
                          ),
                        );
                        if (updated == true) {
                          ref.invalidate(singleContractProvider(contractId));
                        }
                      },
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (isManager)
              contractAsync.when(
                data: (contract) => contract == null
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'حذف',
                        onPressed: () => _confirmDelete(context, ref, contract),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        ),
        body: contractAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('حدث خطأ: $e')),
          data: (contract) {
            if (contract == null) {
              return const Center(child: Text('لم يتم العثور على العقد'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (contract.isClosed)
                  Card(
                    color: contract.calculatedLateFee > 0
                        ? AppColors.error.withOpacity(0.08)
                        : AppColors.success.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            contract.calculatedLateFee > 0
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            color: contract.calculatedLateFee > 0
                                ? AppColors.error
                                : AppColors.success,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              contract.calculatedLateFee > 0
                                  ? 'تم إرجاع السيارة بتأخير ${contract.lateDays} يوم — غرامة: ${contract.calculatedLateFee.toStringAsFixed(2)}'
                                  : 'تم إرجاع السيارة في الموعد المحدد',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _registerActualReturn(context, ref, contract),
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('تسجيل الإرجاع الفعلي للسيارة'),
                  ),
                const SizedBox(height: 14),
                _InfoCard(
                  icon: Icons.directions_car_outlined,
                  title: 'بيانات السيارة',
                  rows: {
                    'نوع السيارة': contract.carType,
                    'رقم اللوحة': contract.plateNumber,
                  },
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  icon: Icons.person_outline,
                  title: 'بيانات المستأجر',
                  rows: {
                    'الاسم الكامل': contract.fullName,
                    'تاريخ الولادة': DateHelper.format(contract.birthDate),
                    'مكان الولادة': contract.birthPlace,
                    'رقم البطاقة الشخصية': contract.nationalIdNumber,
                    'رقم جواز السفر': contract.passportNumber,
                    'رقم رخصة القيادة': contract.licenseNumber,
                    'العنوان': contract.address,
                    'رقم الهاتف': contract.phoneNumber,
                  },
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  icon: Icons.description_outlined,
                  title: 'بيانات العقد',
                  rows: {
                    'مكان التسليم': contract.deliveryPlace,
                    'تاريخ الاستلام': DateHelper.format(contract.pickupDate),
                    'تاريخ التسليم': DateHelper.format(contract.dropoffDate),
                    'عدد الأيام': '${contract.numberOfDays} يوم',
                    'السلفة': contract.advancePayment.toStringAsFixed(2),
                    'غرامة التأخير اليومية': contract.dailyLateFee.toStringAsFixed(2),
                    'نوع التأجير': contract.rentalType.label,
                    if (contract.isClosed)
                      'تاريخ الإرجاع الفعلي': DateHelper.format(contract.actualReturnDate!),
                    if (contract.notes.isNotEmpty) 'ملاحظات': contract.notes,
                  },
                ),
                const SizedBox(height: 14),
                _AttachmentsCard(contract: contract),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Map<String, String> rows;

  const _InfoCard({required this.icon, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accentRed, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 24),
            ...rows.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(e.key, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(
                        e.value.isEmpty ? '-' : e.value,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  final Contract contract;
  const _AttachmentsCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file_outlined, color: AppColors.accentRed, size: 20),
                const SizedBox(width: 8),
                const Text('المرفقات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _AttachmentThumb(label: 'صورة الهوية', path: contract.identityImagePath),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AttachmentThumb(label: 'رخصة القيادة', path: contract.licenseImagePath),
                ),
              ],
            ),
            if (contract.signaturePath != null) ...[
              const SizedBox(height: 12),
              _AttachmentThumb(label: 'توقيع المستأجر', path: contract.signaturePath, fit: BoxFit.contain),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  final String label;
  final String? path;
  final BoxFit fit;

  const _AttachmentThumb({required this.label, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final hasImage = path != null && path!.isNotEmpty && File(path!).existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasImage
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(imageProvider: FileImage(File(path!))),
                    ),
                  )
              : null,
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              color: Colors.white,
              image: hasImage ? DecorationImage(image: FileImage(File(path!)), fit: fit) : null,
            ),
            child: !hasImage
                ? Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary.withOpacity(0.5))
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
