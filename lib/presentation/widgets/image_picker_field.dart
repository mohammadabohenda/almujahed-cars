// ============================================================================
// ملف: image_picker_field.dart
// الوظيفة: مكوّن قابل لإعادة الاستخدام لالتقاط/اختيار صورة (كاميرا أو معرض)
// وعرضها كمعاينة مصغّرة، مع دعم عرض صورة محفوظة مسبقًا (عند التعديل) وإمكانية
// حذفها أو استبدالها.
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';
import 'package:almugahed_cars/presentation/widgets/full_screen_image_viewer.dart';

class ImagePickerField extends StatelessWidget {
  final String title;
  final File? pickedFile;
  final String? existingImagePath; // مسار صورة محفوظة مسبقًا عند التعديل
  final ValueChanged<File> onImagePicked;
  final VoidCallback onImageRemoved;

  const ImagePickerField({
    super.key,
    required this.title,
    required this.onImagePicked,
    required this.onImageRemoved,
    this.pickedFile,
    this.existingImagePath,
  });

  bool get _hasImage => pickedFile != null || existingImagePath != null;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      onImagePicked(File(xFile.path));
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openFullImage(BuildContext context) {
    final imageProvider = pickedFile != null
        ? FileImage(pickedFile!) as ImageProvider
        : FileImage(File(existingImagePath!));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageProvider: imageProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _hasImage
              ? () => _openFullImage(context)
              : () => _showSourceSheet(context),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
              color: AppColors.surfaceGrey.withOpacity(0.04),
              image: _hasImage
                  ? DecorationImage(
                      image: pickedFile != null
                          ? FileImage(pickedFile!) as ImageProvider
                          : FileImage(File(existingImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !_hasImage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppColors.textSecondary, size: 32),
                      const SizedBox(height: 8),
                      Text('اضغط لإضافة صورة',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  )
                : null,
          ),
        ),
        if (_hasImage)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => _showSourceSheet(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('تغيير'),
                ),
                TextButton.icon(
                  onPressed: onImageRemoved,
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  label: Text('حذف', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
