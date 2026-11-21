// ============================================================================
// ملف: settings_providers.dart
// الوظيفة: إدارة إعدادات التطبيق العامة (حاليًا: الوضع الداكن/الفاتح) وحفظها
// في صندوق Hive بسيط (settings_box) بحيث تبقى محفوظة بين مرات فتح التطبيق.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';

Box get _settingsBox => Hive.box(AppConstants.settingsBoxName);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController()
      : super(
          (_settingsBox.get(AppConstants.themeModeKey) as bool? ?? false)
              ? ThemeMode.dark
              : ThemeMode.light,
        );

  Future<void> toggle(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await _settingsBox.put(AppConstants.themeModeKey, isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});
