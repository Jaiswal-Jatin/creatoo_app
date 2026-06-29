import 'dart:ui' as ui;
import 'package:creatoo/utils/qr_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/rendering.dart';
import '../../../../core.dart';
import '../../../../widgets/custom_back_button.dart';

class BusinessQrView extends StatefulWidget {
  final int businessId;
  final String businessName;

  const BusinessQrView({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  State<BusinessQrView> createState() => _BusinessQrViewState();
}

class _BusinessQrViewState extends State<BusinessQrView> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  String get _qrData => QrCodeGenerator.generateQrUrl(widget.businessId);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -100.h, right: -50.w, child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withOpacity(0.15))),
          )),
          Positioned(bottom: 100.h, left: -80.w, child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(width: 300.w, height: 300.w, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.1))),
          )),

          Positioned(top: 0, left: 0, right: 0, child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(children: [
                const CustomBackButton(),
                SizedBox(width: 14.w),
                Text('Payment QR', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700)),
              ]),
            ),
          )),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(children: [
                  SizedBox(height: 20.h),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(children: [
                          Container(
                            width: 52.w, height: 52.w,
                            decoration: BoxDecoration(
                              color: AppColor.premiumAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(
                              (widget.businessName.isNotEmpty ? widget.businessName[0] : 'B').toUpperCase(),
                              style: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 20.sp, fontWeight: FontWeight.w800),
                            )),
                          ),
                          SizedBox(height: 12.h),
                          Text(widget.businessName, textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text("Creatoo QR", style: GoogleFonts.montserrat(color: Colors.lightBlueAccent, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: 24.h),

                          RepaintBoundary(
                            key: _qrKey,
                            child: QrCodeGenerator.generateBrandedQrWidget(
                              businessId: widget.businessId,
                              businessName: widget.businessName ?? 'Business',
                              size: 200,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          SizedBox(height: 16.h),
                          Text("SCAN TO PAY", style: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 13.sp, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        ]),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  _buildInstruction(Icons.qr_code_scanner_rounded, "Display at checkout counter"),
                  _buildInstruction(Icons.phone_android_rounded, "Scan with Creatoo app to pay directly"),
                  _buildInstruction(Icons.cloud_download_rounded, "Save image for printing"),

                  SizedBox(height: 28.h),

                  Row(children: [
                    Expanded(child: AppButton(onTap: _saveQrCode, text: _isSaving ? 'Saving...' : 'Save Image', isIconEnabled: true, icon: Icons.download_rounded)),
                    SizedBox(width: 14.w),
                    Expanded(child: AppButton(
                      onTap: () { Clipboard.setData(ClipboardData(text: _qrData)); Utils.toastMessage('Copied!'); },
                      text: 'Copy', isIconEnabled: true, icon: Icons.link_rounded,
                      buttonColor: Colors.white.withOpacity(0.06), textColor: Colors.white,
                    )),
                  ]),
                  SizedBox(height: 40.h),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppColor.premiumAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColor.premiumAccent, size: 18.sp),
        ),
        SizedBox(width: 14.w),
        Text(text, style: GoogleFonts.montserrat(color: AppColor.premiumTextSecondary, fontSize: 13.sp, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Future<void> _saveQrCode() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Failed to capture QR code');
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert image to bytes');
      final result = await ImageGallerySaverPlus.saveImage(
        byteData.buffer.asUint8List(), quality: 100,
        name: 'creatoo_qr_${widget.businessId}_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result['isSuccess'] == true) {
        if (mounted) Utils.toastMessage('QR saved to gallery');
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      debugPrint('Error saving QR code: $e');
      if (mounted) Utils.toastMessage('Failed to save QR code');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
