// ============================================================================
// ملف: empty_state.dart
// الوظيفة: عرض رسالة وأيقونة مناسبة عند عدم وجود عقود (سواء لعدم الإضافة
// بعد، أو لعدم وجود نتائج مطابقة للبحث).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    this.message = 'لا توجد عقود بعد',
    this.icon = Icons.receipt_long_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
