// ============================================================================
// ملف: notification_service.dart
// الوظيفة: جدولة/إلغاء إشعار محلي (لا يحتاج إنترنت) يذكّر بموعد تسليم السيارة
// قبل يوم واحد من تاريخ dropoffDate، لتفادي تأخر العملاء عن الإرجاع.
// ============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // يستخدم التوقيت المحلي الافتراضي للجهاز تلقائيًا (لا حاجة لضبط منطقة زمنية
    // يدويًا) عبر tz.local الذي توفره حزمة timezone.

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: 'تنبيه قبل يوم واحد من موعد تسليم السيارة',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// معرّف إشعار فريد ومستقر مبني على معرّف العقد (نفس العقد = نفس المعرّف
  /// دائمًا، ليسهل إلغاؤه أو استبداله عند التعديل).
  int _notificationIdFor(String contractId) => contractId.hashCode & 0x7FFFFFFF;

  /// جدولة تذكير الساعة 9 صباحًا من اليوم السابق لتاريخ التسليم.
  /// لا تُجدوَل أي إشعارات لعقود مغلقة أو لمواعيد في الماضي.
  Future<void> scheduleReturnReminder(Contract contract) async {
    await cancelReminder(contract.id);
    if (contract.isClosed) return;

    final reminderDateTime = tz.TZDateTime(
      tz.local,
      contract.dropoffDate.year,
      contract.dropoffDate.month,
      contract.dropoffDate.day - 1,
      AppConstants.returnReminderHour,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (reminderDateTime.isBefore(now)) return;

    await _plugin.zonedSchedule(
      _notificationIdFor(contract.id),
      'تذكير بموعد تسليم سيارة',
      'موعد تسليم سيارة "${contract.carType}" للمستأجر ${contract.fullName} غدًا.',
      reminderDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String contractId) async {
    await _plugin.cancel(_notificationIdFor(contractId));
  }
}
