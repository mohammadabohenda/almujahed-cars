// ============================================================================
// ملف: custom_text_field.dart
// الوظيفة: حقل نصي موحّد الشكل يُستخدم في جميع نماذج التطبيق، يدعم:
// - أيقونة بادئة، لوحة مفاتيح مخصصة، وضع القراءة فقط (Read Only مع onTap)
// - التحقق من الصحة عبر validator، ودعم عدد الأسطر المتعدد (للملاحظات).
// ============================================================================

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 22) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
