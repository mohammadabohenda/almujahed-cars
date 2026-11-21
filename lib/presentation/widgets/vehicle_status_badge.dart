// ============================================================================
// ملف: vehicle_status_badge.dart
// الوظيفة: شارة صغيرة ملوّنة تعرض حالة السيارة (متاحة/مؤجرة/بالصيانة).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';

class VehicleStatusBadge extends StatelessWidget {
  final VehicleStatus status;
  const VehicleStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case VehicleStatus.available:
        return AppColors.success;
      case VehicleStatus.rented:
        return AppColors.accentRed;
      case VehicleStatus.maintenance:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
