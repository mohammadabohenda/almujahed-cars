// ============================================================================
// ملف: image_storage_service.dart
// الوظيفة: نسخ الصور المُختارة (الهوية / رخصة القيادة) إلى مجلد دائم داخل
// مساحة تخزين التطبيق (Application Documents Directory)، وإرجاع المسار
// النهائي لحفظه مع العقد في قاعدة البيانات. كما توفر دالة حذف للصور القديمة.
// ============================================================================

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';

class ImageStorageService {
  static const _uuid = Uuid();

  /// ينسخ ملف الصورة إلى مجلد دائم ويرجع المسار الجديد.
  /// [folderName] يحدد المجلد الفرعي (هوية / رخصة).
  Future<String> saveImage(File sourceFile, String folderName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, folderName));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final extension = p.extension(sourceFile.path);
    final newFileName = '${_uuid.v4()}$extension';
    final newPath = p.join(targetDir.path, newFileName);

    await sourceFile.copy(newPath);
    return newPath;
  }

  /// يحفظ بيانات صورة (bytes) مباشرة كملف داخل مجلد دائم، ويرجع المسار.
  /// تُستخدم لحفظ توقيع المستأجر الإلكتروني (الذي يُنتَج كـ PNG bytes وليس
  /// كملف مُلتَقط من الكاميرا أو المعرض).
  Future<String> saveImageBytes(List<int> bytes, String folderName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, folderName));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final newFileName = '${_uuid.v4()}.png';
    final newPath = p.join(targetDir.path, newFileName);
    final file = File(newPath);
    await file.writeAsBytes(bytes);
    return newPath;
  }

  /// حذف صورة قديمة عند استبدالها أو حذف العقد بالكامل.
  Future<void> deleteImage(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
