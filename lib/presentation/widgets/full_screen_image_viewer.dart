// ============================================================================
// ملف: full_screen_image_viewer.dart
// الوظيفة: عرض أي صورة (هوية / رخصة قيادة) بالحجم الكامل مع دعم التكبير
// والتصغير والتحريك (Pinch to Zoom) باستخدام حزمة photo_view.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullScreenImageViewer({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
