// ============================================================================
// ملف: pdf_contract_service.dart
// الوظيفة: توليد ملف PDF كامل لعقد التأجير (بيانات السيارة/المستأجر/العقد
// وصورة التوقيع إن وجدت) بخط عربي (Cairo) واتجاه RTL صحيح، ثم فتحه
// للمعاينة/الطباعة/المشاركة عبر حزمة printing.
// ============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:almugahed_cars/core/constants/app_constants.dart';
import 'package:almugahed_cars/core/utils/date_helper.dart';
import 'package:almugahed_cars/domain/entities/contract.dart';

class PdfContractService {
  static pw.Font? _cairoFont;

  static Future<pw.Font> _loadFont() async {
    if (_cairoFont != null) return _cairoFont!;
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    _cairoFont = pw.Font.ttf(fontData);
    return _cairoFont!;
  }

  /// يبني مستند PDF كامل لعقد تأجير معيّن ويرجعه كـ bytes.
  static Future<Uint8List> buildContractPdf(Contract contract) async {
    final font = await _loadFont();
    final doc = pw.Document();

    pw.MemoryImage? identityImage;
    pw.MemoryImage? licenseImage;
    pw.MemoryImage? signatureImage;

    if (contract.identityImagePath != null &&
        File(contract.identityImagePath!).existsSync()) {
      identityImage = pw.MemoryImage(File(contract.identityImagePath!).readAsBytesSync());
    }
    if (contract.licenseImagePath != null &&
        File(contract.licenseImagePath!).existsSync()) {
      licenseImage = pw.MemoryImage(File(contract.licenseImagePath!).readAsBytesSync());
    }
    if (contract.signaturePath != null &&
        File(contract.signaturePath!).existsSync()) {
      signatureImage = pw.MemoryImage(File(contract.signaturePath!).readAsBytesSync());
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                pw.SizedBox(height: 18),
                _sectionTitle('بيانات السيارة'),
                _infoTable({
                  'نوع السيارة': contract.carType,
                  'رقم اللوحة': contract.plateNumber,
                }),
                pw.SizedBox(height: 14),
                _sectionTitle('بيانات المستأجر'),
                _infoTable({
                  'الاسم الكامل': contract.fullName,
                  'تاريخ الولادة': DateHelper.format(contract.birthDate),
                  'مكان الولادة': contract.birthPlace,
                  'رقم البطاقة الشخصية': contract.nationalIdNumber,
                  'رقم جواز السفر': contract.passportNumber,
                  'رقم رخصة القيادة': contract.licenseNumber,
                  'العنوان': contract.address,
                  'رقم الهاتف': contract.phoneNumber,
                }),
                pw.SizedBox(height: 14),
                _sectionTitle('بيانات العقد'),
                _infoTable({
                  'مكان التسليم': contract.deliveryPlace,
                  'تاريخ الاستلام': DateHelper.format(contract.pickupDate),
                  'تاريخ التسليم': DateHelper.format(contract.dropoffDate),
                  'عدد الأيام': '${contract.numberOfDays} يوم',
                  'السلفة': contract.advancePayment.toStringAsFixed(2),
                  'نوع التأجير': contract.rentalType.label,
                  if (contract.isClosed)
                    'تاريخ الإرجاع الفعلي': DateHelper.format(contract.actualReturnDate!),
                  if (contract.isClosed && contract.lateDays > 0)
                    'أيام التأخير': '${contract.lateDays} يوم',
                  if (contract.isClosed && contract.calculatedLateFee > 0)
                    'غرامة التأخير': contract.calculatedLateFee.toStringAsFixed(2),
                  if (contract.notes.isNotEmpty) 'ملاحظات': contract.notes,
                }),
                if (identityImage != null || licenseImage != null) ...[
                  pw.SizedBox(height: 14),
                  _sectionTitle('المرفقات'),
                  pw.Row(
                    children: [
                      if (identityImage != null)
                        pw.Expanded(child: _attachmentBox('صورة الهوية', identityImage)),
                      if (identityImage != null && licenseImage != null)
                        pw.SizedBox(width: 10),
                      if (licenseImage != null)
                        pw.Expanded(child: _attachmentBox('رخصة القيادة', licenseImage)),
                    ],
                  ),
                ],
                pw.SizedBox(height: 24),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('توقيع المستأجر', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 6),
                        if (signatureImage != null)
                          pw.Container(
                            width: 160,
                            height: 70,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                            ),
                            child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                          )
                        else
                          pw.Container(
                            width: 160,
                            height: 70,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                            ),
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ختم/توقيع الشركة', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          width: 160,
                          height: 70,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'تم إنشاء هذا العقد إلكترونيًا عبر تطبيق ${AppConstants.appName}',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: const pw.BoxDecoration(color: PdfColors.black),
      child: pw.Column(
        children: [
          pw.Text(
            AppConstants.appName,
            style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'عقد تأجير سيارة',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
      ),
    );
  }

  static pw.Widget _infoTable(Map<String, String> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: rows.entries.map((e) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.key, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.value.isEmpty ? '-' : e.value, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _attachmentBox(String label, pw.MemoryImage image) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 110,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
          child: pw.Image(image, fit: pw.BoxFit.cover),
        ),
      ],
    );
  }

  /// فتح معاينة الطباعة/المشاركة مباشرة لملف PDF العقد.
  static Future<void> previewAndPrint(Contract contract) async {
    final bytes = await buildContractPdf(contract);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  /// مشاركة ملف الـ PDF مباشرة (واتساب/بريد/إلخ) دون فتح شاشة معاينة الطباعة.
  static Future<void> share(Contract contract) async {
    final bytes = await buildContractPdf(contract);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'contract_${contract.id}.pdf',
    );
  }
}
