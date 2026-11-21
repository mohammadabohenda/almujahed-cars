// ============================================================================
// ملف: vehicles_list_screen.dart
// الوظيفة: عرض جميع سيارات الأسطول مع حالتها (متاحة/مؤجرة/بالصيانة) وتنبيه
// بصري لو كان التأمين أو الترخيص قارب على الانتهاء. المدير فقط يمكنه إضافة/
// حذف سيارة؛ الموظف يمكنه فقط العرض وفتح التفاصيل (لتسجيل صيانة مثلاً).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/providers/vehicle_providers.dart';
import 'package:almugahed_cars/presentation/screens/add_edit_vehicle_screen.dart';
import 'package:almugahed_cars/presentation/screens/vehicle_details_screen.dart';
import 'package:almugahed_cars/presentation/widgets/empty_state.dart';
import 'package:almugahed_cars/presentation/widgets/vehicle_status_badge.dart';

class VehiclesListScreen extends ConsumerWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesControllerProvider);
    final isManager = ref.watch(authControllerProvider.notifier).isManager;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الأسطول')),
        body: Builder(
          builder: (context) {
            if (state.status == VehiclesStatus.loading && state.vehicles.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.vehicles.isEmpty) {
              return const EmptyState(
                icon: Icons.directions_car_outlined,
                message: 'لا توجد سيارات مضافة بعد',
              );
            }
            return RefreshIndicator(
              onRefresh: ref.read(vehiclesControllerProvider.notifier).load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: state.vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final v = state.vehicles[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDetailsScreen(vehicleId: v.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlack,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.directions_car_filled,
                                  color: AppColors.secondaryWhite),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.carType,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 3),
                                  Text('${v.plateNumber} • ${v.color}',
                                      style: TextStyle(
                                          color: AppColors.textSecondary, fontSize: 12.5)),
                                  if (v.hasExpiryWarning) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            size: 14, color: AppColors.warning),
                                        const SizedBox(width: 4),
                                        Text('التأمين/الترخيص قارب على الانتهاء',
                                            style: TextStyle(
                                                color: AppColors.warning, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            VehicleStatusBadge(status: v.status),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: isManager
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditVehicleScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('سيارة جديدة'),
              )
            : null,
      ),
    );
  }
}
