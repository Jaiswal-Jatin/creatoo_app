import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:ui' as ui;
import 'package:creatoo/core.dart';
import 'package:creatoo/data/services/shared_preference_service.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';
import 'package:creatoo/features/card/data/activate_card_request_model.dart';
import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String cardNumber, String userName)? onCardActivated;
  const QRScannerScreen({super.key, this.onCardActivated});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false; // Prevent multiple scans
  UserData? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userData = await SharedPreferencesService().getUserData();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  /// Extract 4-digit code from QR string
  String? extractCardCode(String qrValue) {
    // QR me sirf 4 digit code hai
    final RegExp digitRegex = RegExp(r'^\d{4}$');

    // Check if QR value is exactly 4 digits
    if (digitRegex.hasMatch(qrValue.trim())) {
      return qrValue.trim();
    }

    // Agar QR me kuch aur bhi hai, toh 4 digit extract karo
    final RegExp extractRegex = RegExp(r'\d{4}');
    final match = extractRegex.firstMatch(qrValue);
    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return; // Already scanned, prevent multiple calls

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String qrValue = barcode.rawValue!;
        final String? cardCode = extractCardCode(qrValue);

        if (cardCode != null && cardCode.length == 4) {
          setState(() {
            isScanned = true;
          });

          // Stop camera
          cameraController.stop();

          // Call activate card API
          _activateCard(cardCode);
          break;
        } else {
          Utils.flushBar('Invalid QR Code. Please scan a valid card QR.',
              result: Result.error);
        }
      }
    }
  }

  void _activateCard(String cardCode) {
    if (userData == null || userData!.name == null) {
      Utils.flushBar('User data not found. Please login again.',
          result: Result.error);
      Navigator.pop(context);
      return;
    }

    final cardViewModel = Provider.of<CardViewModel>(context, listen: false);

    // API call with scanned code and user name
    cardViewModel.activeCard(
      context,
      ActivateCardRequestModel(
        name: userData!.name,
        number: cardCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Theme.of(context).platform == TargetPlatform.iOS
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Card QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Flash toggle
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          // Camera switch
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay with scanning frame
          _buildScannerOverlay(),

          // Bottom instruction text
          Positioned(
            bottom: 100.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 40.sp,
                ),
                SizedBox(height: 15.h),
                Text(
                  'Point camera at QR code on your card',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'QR code will be scanned automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay when scanning
          if (isScanned)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColor.primary,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Activating Card...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2.5;
        final scanWindow = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

        return Stack(
          children: [
            // Dark blurred overlay with cutout
            Positioned.fill(
              child: ClipPath(
                clipper: _ScannerClipper(scanWindow),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            // Corner decorations
            Positioned(
              left: left,
              top: top,
              child: _buildCorner(Alignment.topLeft),
            ),
            Positioned(
              right: left,
              top: top,
              child: _buildCorner(Alignment.topRight),
            ),
            Positioned(
              left: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomLeft),
            ),
            Positioned(
              right: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomRight),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const cornerSize = 30.0;
    const strokeWidth = 4.0;

    return SizedBox(
      width: cornerSize,
      height: cornerSize,
      child: CustomPaint(
        painter: CornerPainter(
          alignment: alignment,
          color: AppColor.primary,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// Custom painter for scanner corners
class CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double strokeWidth;

  CornerPainter({
    required this.alignment,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// CustomClipper to create the transparent cutout with rounded corners
class _ScannerClipper extends CustomClipper<Path> {
  final Rect cutOutRect;

  _ScannerClipper(this.cutOutRect);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Full screen
      ..addRRect(RRect.fromRectAndRadius(
          cutOutRect, const Radius.circular(20))); // Rounded hole
    return path..fillType = PathFillType.evenOdd; // Even-odd creates the hole
  }

  @override
  bool shouldReclip(_ScannerClipper oldClipper) =>
      oldClipper.cutOutRect != cutOutRect;
}
