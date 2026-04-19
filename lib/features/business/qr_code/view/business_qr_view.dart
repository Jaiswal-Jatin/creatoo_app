import 'package:creatoo/utils/qr_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../../../core.dart';
import '../../../../widgets/app_text_widget.dart';

class BusinessQrView extends StatefulWidget {
  final int businessId;
  final String businessName;

  const BusinessQrView({
    Key? key,
    required this.businessId,
    required this.businessName,
  }) : super(key: key);

  @override
  State<BusinessQrView> createState() => _BusinessQrViewState();
}

class _BusinessQrViewState extends State<BusinessQrView> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final qrUrl = QrCodeGenerator.generateQrUrl(widget.businessId);

    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Business QR Code',
        useCustomBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructions
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColor.primary.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(
            //             Icons.info_outline,
            //             color: AppColor.primary,
            //             size: 20,
            //           ),
            //           const SizedBox(width: 8),
            //           AppTextWidget(
            //             text: 'How to use',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 12),
            //       AppTextWidget(
            //         text: '1. Display this QR code at your business location',
            //         fontSize: 14,
            //         color: AppColor.black,
            //       ),
            //       const SizedBox(height: 6),
            //       AppTextWidget(
            //         text: '2. Customers can scan it to proceed to payment',
            //         fontSize: 14,
            //         color: AppColor.black,
            //       ),
            //       const SizedBox(height: 6),
            //       AppTextWidget(
            //         text: '3. Works with any QR scanner or Creatoo app',
            //         fontSize: 14,
            //         color: AppColor.black,
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 30),

            // QR Code with branding
            RepaintBoundary(
              key: _qrKey,
              child: QrCodeGenerator.generateBrandedQrWidget(
                businessId: widget.businessId,
                businessName: widget.businessName,
                size: 250,
              ),
            ),

            const SizedBox(height: 30),

            // Business info
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       AppTextWidget(
            //         text: 'Business Details',
            //         fontSize: 14,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.grey[700],
            //       ),
            //       const SizedBox(height: 12),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           AppTextWidget(
            //             text: 'Business Name:',
            //             fontSize: 14,
            //           ),
            //           Flexible(
            //             child: AppTextWidget(
            //               text: widget.businessName,
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 8),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           AppTextWidget(
            //             text: 'Business ID:',
            //             fontSize: 14,
            //           ),
            //           AppTextWidget(
            //             text: '${widget.businessId}',
            //             fontSize: 14,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 20),

            // QR URL Display
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.grey[300]!),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       AppTextWidget(
            //         text: 'QR Code URL',
            //         fontSize: 14,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.grey[700],
            //       ),
            //       const SizedBox(height: 8),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: AppTextWidget(
            //               text: qrUrl,
            //               fontSize: 12,
            //               color: AppColor.primary,
            //             ),
            //           ),
            //           IconButton(
            //             icon: const Icon(Icons.copy, size: 20),
            //             onPressed: () => _copyToClipboard(qrUrl),
            //             tooltip: 'Copy URL',
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 30),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onTap: _saveQrCode,
                    text: _isSaving ? 'Saving...' : 'Save QR Code',
                    isIconEnabled: false,
                    buttonColor: AppColor.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    onTap: () => _shareQrUrl(qrUrl),
                    text: 'Share Link',
                    isIconEnabled: false,
                    buttonColor: AppColor.white,
                    textColor: AppColor.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQrCode() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Failed to capture QR code');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final result = await ImageGallerySaverPlus.saveImage(
        byteData.buffer.asUint8List(),
        quality: 100,
        name:
            'creatoo_qr_${widget.businessId}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppTextWidget(text: 'QR code saved to gallery'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      log('Error saving QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppTextWidget(text: 'Failed to save QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _shareQrUrl(String url) {
    // Note: url_launcher is already in pubspec.yaml
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppTextWidget(
          text: 'URL copied! Share it with your customers.',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
