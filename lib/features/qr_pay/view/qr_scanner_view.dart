import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:ui' as ui; // Import for ImageFilter
import 'package:image_picker/image_picker.dart'; // Import for image_picker

import '../../../core.dart';
import '../view_model/qr_pay_view_model.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({Key? key}) : super(key: key);

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> with WidgetsBindingObserver {
  String result = "";
  bool isScanned = false;
  late QrPayViewModel viewModel;
  final MobileScannerController _scannerController = MobileScannerController();

  final double _scanWindowWidth = 300;
  final double _scanWindowHeight = 300;
  final double _scanWindowVerticalOffset = 50; // How much above center
  bool _isTorchOn = false; // New state for torch

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isScanned) {
      _scannerController.start();
    } else if (state == AppLifecycleState.paused) {
      _scannerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<QrPayViewModel>(context);

    final Size screenSize = MediaQuery.of(context).size;
    final Rect scanWindow = Rect.fromCenter(
      center: Offset(
        screenSize.width / 2,
        screenSize.height / 2 - _scanWindowVerticalOffset,
      ),
      width: _scanWindowWidth,
      height: _scanWindowHeight,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen camera preview
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (BarcodeCapture barcodeCapture) async {
                if (isScanned) return;

                final barcode = barcodeCapture.barcodes.first;
                final qrCodeData = barcode.rawValue ?? "";

                log("Scanned result: \$qrCodeData");

                if (_validateAndExtractData(qrCodeData)) {
                  isScanned = true;
                  Navigator.pushReplacementNamed(
                    context,
                    RoutesName.proceedToCart,
                    arguments: viewModel.businessId,
                  );
                } else {
                  await _showInvalidScanDialog();
                }
              },
              fit: BoxFit.cover,
            ),
          ),

          // 2. Blurred overlay with transparent center square
          _buildBlurredOverlay(scanWindow),

          // 3. Corner markers
          _buildCornerMarkers(scanWindow),

          // NEW: Text above QR box
          Positioned(
            top: scanWindow.top - 90, // Position above the scan window, moved further up
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Scan only Creatoo QR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // NEW: Text below QR box
          Positioned(
            top: scanWindow.bottom + 20, // Position below the scan window
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Align QR code within the frame to scan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // NEW: Torch and Gallery icons, now positioned below the "Align QR code" text
          Positioned(
            top: scanWindow.bottom + 70, // Positioned below the "Align QR code" text
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Torch Icon
                GestureDetector(
                  onTap: () async {
                    await _scannerController.toggleTorch();
                    setState(() {
                      _isTorchOn = !_isTorchOn;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    radius: 25,
                    child: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                // Gallery Icon
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log("Selected image path from gallery: ${image.path}");
                      // TODO: Implement QR code analysis from the selected image.
                      // The MobileScannerController does not have a direct method for analyzing static images.
                      // Consider using a separate package or a custom implementation for image-based QR scanning.
                      // Example of how you would call if _scannerController had the method:
                      // final BarcodeCapture? barcodeCapture = await _scannerController.analyzeImageFromPath(image.path);
                      // if (barcodeCapture != null) {
                      //   final barcode = barcodeCapture.barcodes.first;
                      //   final qrCodeData = barcode.rawValue ?? "";
                      //   log("Scanned result from gallery: \$qrCodeData");
                      //
                      //   if (_validateAndExtractData(qrCodeData)) {
                      //     isScanned = true;
                      //     Navigator.pushReplacementNamed(
                      //       context,
                      //       RoutesName.proceedToCart,
                      //       arguments: viewModel.businessId,
                      //     );
                      //   } else {
                      //     await _showInvalidScanDialog();
                      //   }
                      // } else {
                      //   log("No QR code detected in the selected image.");
                      //   await _showInvalidScanDialog();
                      // }
                    } else {
                      log("No image selected from gallery.");
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    radius: 25,
                    child: const Icon(
                      Icons.image, // Or Icons.photo_library
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredOverlay(Rect scanWindow) {
    return Positioned.fill(
      child: ClipPath(
        clipper: _ScannerClipper(scanWindow),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent overlay to darken blurred area
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarkers(Rect scanWindow) {
    final double markerLength = _BorderCornerPainter().length;
    final double markerStrokeWidth = _BorderCornerPainter().strokeWidth;

    return Stack(
      children: [
        // Top-left
        Positioned(
          top: scanWindow.top - markerStrokeWidth,
          left: scanWindow.left - markerStrokeWidth,
          child: CustomPaint(
            size: Size(markerLength, markerLength),
            painter: _BorderCornerPainter(),
          ),
        ),
        // Top-right
        Positioned(
          top: scanWindow.top - markerStrokeWidth,
          left: scanWindow.right - markerLength + markerStrokeWidth,
          child: CustomPaint(
            size: Size(markerLength, markerLength),
            painter: _BorderCornerPainter(right: true),
          ),
        ),
        // Bottom-left
        Positioned(
          top: scanWindow.bottom - markerLength + markerStrokeWidth,
          left: scanWindow.left - markerStrokeWidth,
          child: CustomPaint(
            size: Size(markerLength, markerLength),
            painter: _BorderCornerPainter(bottom: true),
          ),
        ),
        // Bottom-right
        Positioned(
          top: scanWindow.bottom - markerLength + markerStrokeWidth,
          left: scanWindow.right - markerLength + markerStrokeWidth,
          child: CustomPaint(
            size: Size(markerLength, markerLength),
            painter: _BorderCornerPainter(right: true, bottom: true),
          ),
        ),
      ],
    );
  }

  //TODO: Need to change this
  bool _validateAndExtractData(String qrCodeData) {
    try {
      // Decode the Base64-encoded string
      final decodedData = utf8.decode(base64.decode(qrCodeData));

      // Check if the decoded string starts with "qr_" (case-insensitive)
      if (decodedData.toLowerCase().startsWith('qr_')) {
        final parts = decodedData.split('_');
        viewModel.businessId = int.tryParse(parts[1]);

        log("Decoded Data: $decodedData");
        log("Business ID: ${viewModel.businessId}");

        return true;
      }
    } catch (e) {
      log("Error decoding or parsing QR code data: $e");
    }

    return false;
  }

  Future<void> _showInvalidScanDialog() async {
    _scannerController.stop();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: AppTextWidget(text: "Invalid Scanner"),
          content: AppTextWidget(text: "Scanner is not valid. Please scan again."),
          actions: [
            TextButton(
              onPressed: () {
                isScanned = false;
                Navigator.of(context).pop();
              },
              child: AppTextWidget(text: "Rescan"),
            ),
          ],
        );
      },
    );
    _scannerController.start();
    //cameraDirection: CameraFacing.front
  }
}

// CustomClipper to create the transparent cutout
class _ScannerClipper extends CustomClipper<Path> {
  final Rect cutOutRect;

  _ScannerClipper(this.cutOutRect);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Full screen
      ..addRect(cutOutRect); // The hole
    return path..fillType = PathFillType.evenOdd; // Even-odd creates the hole
  }

  @override
  bool shouldReclip(_ScannerClipper oldClipper) =>
      oldClipper.cutOutRect != cutOutRect;
}

class _BorderCornerPainter extends CustomPainter {
  final bool right;
  final bool bottom;
  final double length;
  final double strokeWidth;

  _BorderCornerPainter({
    this.right = false,
    this.bottom = false,
    this.length = 40,
    this.strokeWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (!right && !bottom) {
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    }
    if (right && !bottom) {
      path.moveTo(size.width, length);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - length, 0);
    }
    if (!right && bottom) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    }
    if (right && bottom) {
      path.moveTo(size.width, size.height - length);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - length, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
