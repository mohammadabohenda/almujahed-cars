// ============================================================================
// ملف: splash_screen.dart
// الوظيفة: شاشة البداية التي تظهر عند فتح التطبيق، تعرض شعار الشركة على
// خلفية داكنة (منسجمة مع ألوان الشعار)، ثم تنتقل تلقائيًا إلى الشاشة الرئيسية
// بعد تهيئة قاعدة البيانات المحلية (Hive).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/presentation/providers/auth_providers.dart';
import 'package:almugahed_cars/presentation/screens/login_screen.dart';
import 'package:almugahed_cars/presentation/screens/main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // لو كانت هناك جلسة محفوظة (تسجيل دخول سابق) نذهب مباشرة للشاشة الرئيسية،
    // وإلا نطلب من المستخدم تسجيل الدخول أولًا.
    final currentUser = ref.read(authControllerProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => currentUser != null ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // مكان شعار الشركة - يتم تحميله من الأصول (assets/logo/logo.png)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                AppConstants.logoPath,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.secondaryWhite, width: 1),
                  ),
                  child: const Icon(Icons.directions_car_filled,
                      color: AppColors.secondaryWhite, size: 64),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppColors.secondaryWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'نظام إدارة عقود تأجير السيارات',
              style: TextStyle(
                color: AppColors.secondaryWhite.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.accentRed,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
