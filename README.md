# ALMUGAHED CARS 🚗
تطبيق Flutter احترافي متكامل لإدارة شركة تأجير سيارات — يعمل بالكامل بدون إنترنت (Offline-First)، بواجهة عربية RTL، ومبني وفق Clean Architecture. **الإصدار 2.0** يضيف: تصدير PDF، تذكير مواعيد التسليم، غرامة تأخير تلقائية، إدارة أسطول كاملة، نسخ احتياطي، تسجيل دخول بصلاحيات، الوضع الداكن، وتوقيع إلكتروني.

---

## 1) طريقة التشغيل

> بيئة إنشاء هذا المشروع لا تحتوي على Flutter SDK، لذلك كل كود Dart مكتوب ومُراجَع يدويًا بعناية (تم التحقق من توازن الأقواس وتطابق كل الاستيرادات الداخلية)، لكن **مجلدات المنصّات الأصلية (android/ios) غير مولّدة بعد**.

```bash
cd almugahed_cars
flutter create .        # لأول مرة فقط — يولّد android/ios
flutter pub get
flutter run
```

### أذونات لا بد من إضافتها بعد `flutter create .`
| المنصة | الإذن | السبب |
|---|---|---|
| Android (`AndroidManifest.xml`) | `CAMERA`, `READ_MEDIA_IMAGES` | التقاط/اختيار صور الهوية والرخصة |
| Android | `POST_NOTIFICATIONS` (Android 13+) | تذكير موعد التسليم |
| Android | `SCHEDULE_EXACT_ALARM` أو استخدام `AndroidScheduleMode.inexactAllowWhileIdle` | جدولة إشعار دقيق بالوقت |
| iOS (`Info.plist`) | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` | نفس أذونات الصور |

### بيانات الدخول الافتراضية (أول تشغيل)
يُزرع تلقائيًا حساب **مدير**: `admin` / `admin123` — **يجب تغييره** فور أول استخدام حقيقي (لا توجد حاليًا شاشة "تغيير كلمة المرور" فيمكن حذف المستخدم القديم وإضافة مدير جديد من شاشة الإعدادات، أو تعديل `AppConstants.defaultAdminPassword` قبل أول تشغيل).

---

## 2) هيكل المشروع (Clean Architecture)

```
lib/
├── main.dart                    # تهيئة Hive (كل الصناديق) + الإشعارات + زرع المدير الافتراضي + ProviderScope
│
├── core/
│   ├── theme/app_theme.dart          # الألوان + ثيم فاتح/داكن + خط Cairo محلي
│   ├── constants/app_constants.dart  # كل الثوابت + Enums (RentalType, VehicleStatus, UserRole)
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_helper.dart
│   │   └── password_hasher.dart      # SHA-256 لتشفير كلمات المرور
│   └── services/
│       ├── pdf_contract_service.dart   # توليد عقد PDF (خط عربي + RTL + صور + توقيع)
│       ├── notification_service.dart   # جدولة/إلغاء تذكير التسليم
│       └── backup_service.dart         # تصدير/استيراد كل بيانات التطبيق (JSON)
│
├── domain/
│   ├── entities/ (contract, vehicle, maintenance_record, app_user)
│   ├── repositories/ (i_contract_repository, i_vehicle_repository, i_auth_repository)
│   └── usecases/ (contract_usecases, vehicle_usecases)
│
├── data/
│   ├── models/  (+ TypeAdapters يدوية: Contract=0, Vehicle=1, MaintenanceRecord=2, User=3)
│   ├── datasources/ (contract/vehicle/auth local datasources + image_storage_service)
│   └── repositories/ (التنفيذ الفعلي لكل IRepository)
│
└── presentation/
    ├── providers/ (contract, vehicle, auth, settings, backup)
    ├── screens/
    │   ├── splash_screen → login_screen (أو main_shell لو الجلسة محفوظة)
    │   ├── main_shell.dart             # Bottom Nav: العقود / الأسطول / الإعدادات
    │   ├── home_screen.dart            # قائمة العقود + بحث
    │   ├── add_edit_contract_screen.dart  # اختيار سيارة + بيانات + غرامة تأخير + توقيع
    │   ├── contract_details_screen.dart   # PDF + تسجيل إرجاع فعلي + حذف (مدير فقط)
    │   ├── vehicles_list_screen.dart / add_edit_vehicle_screen.dart / vehicle_details_screen.dart
    │   ├── signature_capture_screen.dart
    │   └── settings_screen.dart        # داكن/فاتح + نسخ احتياطي + مستخدمون + خروج
    └── widgets/ (custom_text_field, image_picker_field, contract_card, vehicle_status_badge, ...)
```

---

## 3) قاعدة البيانات (Hive) — أربعة صناديق

| الصندوق | النوع المخزَّن | typeId |
|---|---|---|
| `contracts_box` | `ContractModel` | 0 |
| `vehicles_box` | `VehicleModel` (يحوي قائمة `MaintenanceRecordModel`) | 1 / 2 |
| `users_box` | `UserModel` (كلمة المرور كـ SHA-256 hash) | 3 |
| `settings_box` | صندوق `dynamic` بسيط (الوضع الداكن + جلسة الدخول) | - |

كل `TypeAdapter` مكتوب يدويًا (بدون build_runner). عقد التأجير الآن يحمل أيضًا: `vehicleId` (ربط بسيارة من الأسطول)، `dailyLateFee` و`actualReturnDate` (لحساب غرامة التأخير)، و`signaturePath` (توقيع المستأجر).

الصور والتوقيعات تُخزَّن كملفات فعلية:
```
ApplicationDocumentsDirectory/
├── identity_images/  ├── license_images/  ├── signatures/  └── exports/  (ملفات النسخ الاحتياطي JSON)
```

---

## 4) الميزات المضافة في الإصدار 2.0

### 📄 تصدير PDF جاهز للطباعة والتوقيع
`PdfContractService` يبني مستند PDF كامل (بيانات السيارة/المستأجر/العقد + صور المرفقات + صورة التوقيع) بخط **Cairo** عربي مرفق محليًا واتجاه RTL صحيح عبر `pw.Directionality`، ثم يُفتح مباشرة لمعاينة الطباعة/المشاركة عبر حزمة `printing`. زر "تصدير PDF" موجود في شريط شاشة تفاصيل العقد.

### 🔔 تذكير قبل موعد التسليم بيوم
`NotificationService` يجدول إشعارًا محليًا (لا يحتاج إنترنت) الساعة 9 صباحًا من اليوم السابق لـ `dropoffDate`، عبر `flutter_local_notifications` + `timezone`. يُجدوَل تلقائيًا عند حفظ العقد، ويُلغى تلقائيًا عند حذف العقد أو تسجيل إرجاع السيارة فعليًا.

### ⏱️ غرامة تأخير تلقائية
كل عقد يحمل حقل `dailyLateFee` (قيمة الغرامة اليومية). عند الضغط على "تسجيل الإرجاع الفعلي" في شاشة تفاصيل العقد وتحديد التاريخ، يحسب التطبيق تلقائيًا `lateDays` و`calculatedLateFee` (معرّفة كـ getters داخل `Contract` entity) ويعرضهما، ويعيد السيارة تلقائيًا إلى حالة "متاحة" في الأسطول.

### 🚙 إدارة الأسطول الكاملة
شاشة "الأسطول" (تبويب منفصل) تعرض كل السيارات مع حالتها (متاحة/مؤجرة/بالصيانة) وتنبيه بصري لو اقترب التأمين أو الترخيص من الانتهاء (خلال 30 يومًا). كل سيارة لها سجل صيانة كامل (تاريخ + وصف + تكلفة). عند إنشاء عقد جديد تُختار السيارة من **قائمة منسدلة** مرتبطة بالأسطول (بدل الكتابة اليدوية)، وتتغيّر حالتها تلقائيًا بين "مؤجرة" و"متاحة" حسب حالة العقد.

### 💾 نسخ احتياطي (تصدير/استيراد)
`BackupService` يجمّع كل العقود والسيارات والمستخدمين في ملف JSON واحد (`exports/almugahed_backup_<timestamp>.json`) ويفتح نافذة المشاركة النظامية لحفظه/إرساله (`share_plus`). الاستيراد (`file_picker`) يستبدل البيانات الحالية بمحتوى الملف بعد تأكيد صريح من المستخدم. **ملاحظة:** النسخة الاحتياطية تشمل البيانات النصية فقط وليس ملفات الصور/التوقيعات نفسها (لأنها كبيرة نسبيًا وتبقى مرتبطة بمساحة تخزين الجهاز).

### 🔐 تسجيل دخول بصلاحيات (مدير / موظف)
`AuthController` يدير الجلسة (تبقى محفوظة بين مرات فتح التطبيق حتى تسجيل الخروج صراحة). **المدير** فقط يمكنه: إضافة/تعديل/حذف سيارات، حذف عقود، تصدير/استيراد نسخة احتياطية، وإضافة مستخدمين جدد. **الموظف** يمكنه: إضافة/تعديل العقود والاطّلاع على الأسطول فقط.

### 🌙 الوضع الداكن
مفتاح تبديل في شاشة الإعدادات، محفوظ في `settings_box`، عبر `ThemeModeController` (Riverpod) وثيم داكن كامل مطابق لهوية الألوان في `AppTheme.darkTheme`.

### ✍️ توقيع إلكتروني للمستأجر
شاشة `SignatureCaptureScreen` (حزمة `signature`) تسمح للمستأجر بالتوقيع بإصبعه، يُحفظ كصورة PNG محليًا ويُربط بالعقد، ويظهر في شاشة التفاصيل وملف الـ PDF المُصدَّر.

---

## 5) قائمة الحزم (Packages) الكاملة وسبب كل واحدة

| الحزمة | السبب |
|---|---|
| `flutter_riverpod` | إدارة حالة قوية وآمنة النوع، تدعم فصل الطبقات (Clean Architecture) |
| `hive` / `hive_flutter` | قاعدة بيانات محلية NoSQL سريعة بدون إنترنت |
| `path_provider` / `path` | تحديد ومعالجة مسارات تخزين الصور/التوقيعات/النسخ الاحتياطية |
| `image_picker` | التقاط/اختيار صور الهوية ورخصة القيادة |
| `intl` | تنسيق التواريخ |
| `photo_view` | عرض الصور بالحجم الكامل مع تكبير/تصغير |
| `uuid` | توليد معرّفات فريدة للعقود/السيارات/سجلات الصيانة |
| `flutter_localizations` | دعم اللغة العربية الرسمي (Date Picker وغيره) |
| `crypto` | تشفير SHA-256 لكلمات مرور المستخدمين |
| `pdf` / `printing` | بناء ومعاينة/طباعة/مشاركة عقد PDF |
| `signature` | لوحة توقيع إلكتروني |
| `flutter_local_notifications` / `timezone` | جدولة تذكير التسليم محليًا بالتوقيت الصحيح |
| `share_plus` | مشاركة ملفات النسخة الاحتياطية |
| `file_picker` | اختيار ملف JSON عند الاستيراد |
| `flutter_screenutil` | (اختياري) لتحسينات تجاوب إضافية مستقبلًا — غير مُفعَّل حاليًا في الشاشات |

---

## 6) الخط العربي (Cairo)
الخط مرفق فعليًا داخل `assets/fonts/Cairo-Regular.ttf` (وليس عبر `google_fonts` الذي يحتاج إنترنت عند أول استخدام) حتى يعمل التطبيق بالكامل دون اتصال، ويُستخدم في كل من واجهة التطبيق وملف الـ PDF المُصدَّر. الخط مرخّص بموجب **SIL Open Font License** (رخصة مفتوحة تسمح بالتضمين في التطبيقات التجارية مجانًا) — المصدر: [Google Fonts / Cairo](https://github.com/google/fonts).

---

## 7) ملاحظة حول الألوان
تم استخراج الألوان الثلاثة من الشعار المرسل: أسود `#0D0D0D` (خلفية الشعار)، أبيض `#FFFFFF` (رسمة السيارة والنص)، وأحمر `#C41E3A` (اللمسة الحمراء أسفل الشعار). كل الألوان معرّفة في مكان واحد فقط: `lib/core/theme/app_theme.dart` (class `AppColors`) — عند إرسال نسخة أعلى دقة من الشعار يمكن ضبط القيم الدقيقة هناك مباشرة.

## 8) القيود الحالية (شفافية كاملة)
- لا يوجد Flutter SDK في بيئة الإنشاء، لذا لم يتم تشغيل `flutter analyze` أو تجربة بناء APK فعلي؛ تم التحقق يدويًا من توازن الأقواس وتطابق كل الاستيرادات الداخلية مع الملفات الفعلية.
- النسخة الاحتياطية لا تشمل ملفات الصور/التوقيعات، فقط البيانات النصية.
- لا توجد حاليًا شاشة "تغيير كلمة المرور" مباشرة؛ الحل المؤقت مذكور أعلاه في قسم بيانات الدخول الافتراضية.
#   a l m u j a h e d - c a r s  
 