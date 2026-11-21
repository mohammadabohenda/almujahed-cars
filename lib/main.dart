

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/services/notification_service.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/data/datasources/auth_local_datasource.dart';
import 'package:almugahed_cars/data/models/contract_model.dart';
import 'package:almugahed_cars/data/models/maintenance_record_model.dart';
import 'package:almugahed_cars/data/models/user_model.dart';
import 'package:almugahed_cars/data/models/vehicle_model.dart';
import 'package:almugahed_cars/presentation/providers/settings_providers.dart';
import 'package:almugahed_cars/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تثبيت اتجاه الشاشة (اختياري - يمكن حذفه للسماح بالتدوير)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Hive وتسجيل كل الـ Adapters (لكل نوع typeId فريد وثابت)
  await Hive.initFlutter();
  Hive.registerAdapter(ContractModelAdapter());     // typeId 0
  Hive.registerAdapter(VehicleModelAdapter());      // typeId 1
  Hive.registerAdapter(MaintenanceRecordModelAdapter()); // typeId 2
  Hive.registerAdapter(UserModelAdapter());         // typeId 3

  await Hive.openBox<ContractModel>(AppConstants.contractsBoxName);
  await Hive.openBox<VehicleModel>(AppConstants.vehiclesBoxName);
  await Hive.openBox<UserModel>(AppConstants.usersBoxName);
  await Hive.openBox(AppConstants.settingsBoxName); // صندوق إعدادات عام (dynamic)

  // زرع حساب مدير افتراضي (admin/admin123) إن كان صندوق المستخدمين فارغًا
  await AuthLocalDataSource().seedDefaultAdminIfNeeded();

  // تهيئة الإشعارات المحلية (لا تحتاج إنترنت)
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: AlmugahedCarsApp()));
}

class AlmugahedCarsApp extends ConsumerWidget {
  const AlmugahedCarsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // دعم اللغة العربية واتجاه RTL على مستوى التطبيق بالكامل
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      home: const SplashScreen(),
    );
  }
}
