// ============================================================================
// ملف: signature_capture_screen.dart
// الوظيفة: شاشة كاملة للسماح للمستأجر بالتوقيع إلكترونيًا بإصبعه/بالقلم على
// الشاشة. عند الضغط على "حفظ التوقيع" يتم تحويل الرسمة إلى صورة PNG وإرجاع
// الـ bytes الخاصة بها للشاشة السابقة (add_edit_contract_screen) لحفظها.
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:almugahed_cars/core/theme/app_theme.dart';

class SignatureCaptureScreen extends StatefulWidget {
  const SignatureCaptureScreen({super.key});

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primaryBlack,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التوقيع أولًا قبل الحفظ')),
      );
      return;
    }
    final Uint8List? bytes = await _controller.toPngBytes();
    if (bytes != null && mounted) {
      Navigator.pop(context, bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('توقيع المستأجر'),
          actions: [
            IconButton(
              tooltip: 'مسح',
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.clear(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'وقّع بإصبعك داخل الإطار أدناه',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('حفظ التوقيع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
