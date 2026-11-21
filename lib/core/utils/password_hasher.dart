// ============================================================================
// ملف: password_hasher.dart
// الوظيفة: تشفير كلمات المرور محليًا (SHA-256) بحيث لا تُخزَّن أي كلمة مرور
// كنص صريح داخل قاعدة البيانات، حتى لو كانت التخزين محليًا بالكامل.
// ============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static String hash(String plainPassword) {
    final bytes = utf8.encode(plainPassword);
    return sha256.convert(bytes).toString();
  }

  static bool verify(String plainPassword, String storedHash) {
    return hash(plainPassword) == storedHash;
  }
}
