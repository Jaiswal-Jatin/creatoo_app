import 'dart:ui' as ui;
import 'package:creatoo/features/business_profile/repository/business_profile_repository.dart';
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
  final String? upiId;

  const BusinessQrView({
    super.key,
    required this.businessId,
    required this.businessName,
    this.upiId,
  });

  @override
  State<BusinessQrView> createState() => _BusinessQrViewState();
}

class _BusinessQrViewState extends State<BusinessQrView> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;
  String? _upiId;
  bool _isLoadingUpi = true;

  @override
  void initState() {
    super.initState();
    if (widget.upiId != null && widget.upiId!.isNotEmpty) {
      _upiId = widget.upiId;
      _isLoadingUpi = false;
    } else {
      _fetchUpiId();
    }
  }

  Future<void> _fetchUpiId() async {
    try {
      final repo = BusinessProfileRepository();
      final response = await repo.fetchBusinessProfileApi({
        "id": widget.businessId,
        "role_id": 2,
      });
      response.fold(
        (l) => debugPrint("Failed to fetch profile: ${l.message}"),
        (r) {
          if (r.data?.upiId != null && r.data!.upiId!.isNotEmpty) {
            _upiId = r.data!.upiId;
          }
        },
      );
    } catch (e) {
      debugPrint("Error fetching UPI ID: $e");
    }
    if (mounted) setState(() => _isLoadingUpi = false);
  }

  String get _qrData {
    if (_upiId != null && _upiId!.isNotEmpty) {
      return QrCodeGenerator.generateUpiQrData(_upiId!, widget.businessName);
    }
    return QrCodeGenerator.generateQrUrl(widget.businessId);
  }

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

                  if (_isLoadingUpi)
                    Padding(padding: EdgeInsets.symmetric(vertical: 120.h), child: const AppLoadingWidget())

                  else if (_upiId == null) ...[
                    SizedBox(height: 80.h),
                    Container(
                      width: 80.w, height: 80.w,
                      decoration: BoxDecoration(color: AppColor.premiumAccent.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.account_balance_wallet_outlined, color: AppColor.premiumAccent, size: 36.sp),
                    ),
                    SizedBox(height: 24.h),
                    Text("UPI ID Not Set", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        "Set your UPI ID in Edit Profile to generate a payment QR code",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(color: AppColor.premiumTextSecondary, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    AppButton(
                      onTap: () => Navigator.pushNamed(context, RoutesName.editBusinessProfile, arguments: "Shop"),
                      text: "Go to Edit Profile",
                      isIconEnabled: true,
                      icon: Icons.edit_rounded,
                    ),
                    SizedBox(height: 80.h),
                  ] else ...[
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
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                              child: Text("UPI Ready", style: GoogleFonts.montserrat(color: Colors.greenAccent, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(height: 24.h),

                            RepaintBoundary(
                              key: _qrKey,
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                                ),
                                child: QrCodeGenerator.generateUpiBrandedQrWidget(upiId: _upiId!, businessName: widget.businessName, size: 200),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.account_balance_wallet_rounded, color: AppColor.premiumAccent, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text(_upiId!, style: GoogleFonts.montserrat(color: AppColor.premiumTextSecondary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () { Clipboard.setData(ClipboardData(text: _upiId!)); Utils.toastMessage('UPI ID copied!'); },
                                  child: Icon(Icons.copy_rounded, color: Colors.white38, size: 16.sp),
                                ),
                              ]),
                            ),
                            SizedBox(height: 16.h),
                            Text("SCAN TO PAY", style: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 13.sp, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          ]),
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    _buildInstruction(Icons.qr_code_scanner_rounded, "Display at checkout counter"),
                    _buildInstruction(Icons.payments_rounded, "Scan with GPay, PhonePe or Paytm"),
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
                  ],
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
