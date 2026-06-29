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

class _QrScannerViewState extends State<QrScannerView>
    with WidgetsBindingObserver {
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

                await _handleScannedData(qrCodeData);
              },
              fit: BoxFit.cover,
            ),
          ),

          // 2. Blurred overlay with transparent center square
          _buildBlurredOverlay(scanWindow),

          // 3. Corner markers
          _buildCornerMarkers(scanWindow),

          // Back button in top left
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // NEW: Text above QR box
          Positioned(
            top: scanWindow.top -
                90, // Position above the scan window, moved further up
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
            top: scanWindow.bottom +
                70, // Positioned below the "Align QR code" text
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
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log("Selected image path from gallery: ${image.path}");

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );

                      try {
                        // Use MobileScannerController to analyze image from path
                        final BarcodeCapture? barcodeCapture =
                            await _scannerController.analyzeImage(image.path);

                        // Close loading dialog
                        if (context.mounted) Navigator.of(context).pop();

                        if (barcodeCapture != null &&
                            barcodeCapture.barcodes.isNotEmpty) {
                          final barcode = barcodeCapture.barcodes.first;
                          final qrCodeData = barcode.rawValue ?? "";
                          log("Scanned result from gallery: $qrCodeData");

                          await _handleScannedData(qrCodeData);
                        } else {
                          log("No QR code detected in the selected image.");
                          _showNoQrFoundDialog();
                        }
                      } catch (e) {
                        log("Error analyzing image: $e");
                        // Close loading dialog if still open
                        if (context.mounted) Navigator.of(context).pop();
                        _showNoQrFoundDialog();
                      }
                    } else {
                      log("No image selected from gallery.");
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
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
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerMarkers(Rect scanWindow) {
    const double markerLength = 40;
    const double markerStrokeWidth = 5;

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

  /// Validate and extract data from scanned QR code
  /// Supports both:
  /// 1. New URL format: https://api.creatoo.co.in/api/scan?businessId=123
  /// 2. Legacy Base64 format: qr_123 (base64 encoded)
  bool _validateAndExtractData(String qrCodeData) {
    try {
      // First, try to parse as URL (new format)
      if (qrCodeData.startsWith('http://') ||
          qrCodeData.startsWith('https://')) {
        return _validateUrlFormat(qrCodeData);
      }

      // Fallback to Base64 format (legacy support)
      return _validateBase64Format(qrCodeData);
    } catch (e) {
      log("Error validating QR code data: $e");
      return false;
    }
  }

  String? _extractUpiId(String qrCodeData) {
    final lowerData = qrCodeData.toLowerCase().trim();
    // 1. Check if it's a upi:// link
    if (lowerData.startsWith('upi://')) {
      try {
        // Replace spaces with %20 to avoid FormatException in Uri.parse
        final safeUrl = qrCodeData.replaceAll(' ', '%20');
        final uri = Uri.parse(safeUrl);
        // Look for 'pa' parameter case-insensitively
        for (final key in uri.queryParameters.keys) {
          if (key.toLowerCase() == 'pa') {
            return uri.queryParameters[key];
          }
        }
      } catch (e) {
        log("Error parsing UPI URI: $e");
      }
    }
    
    // 2. Check if it's a direct UPI ID (contains '@' and no spaces)
    if (qrCodeData.contains('@') && !qrCodeData.contains(' ')) {
      // Clean query params if any, e.g. test@upi?am=100
      final cleanData = qrCodeData.split('?').first.trim();
      return cleanData;
    }

    return null;
  }

  Future<void> _handleScannedData(String qrCodeData) async {
    if (isScanned) return;

    log("Scanned result: $qrCodeData");

    // 1. Check if it is a UPI QR or UPI ID
    final upiId = _extractUpiId(qrCodeData);
    if (upiId != null) {
      isScanned = true;
      log("Detected UPI ID: $upiId. Querying database...");
      
      // Stop scanner temporarily
      _scannerController.stop();

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final businessData = await viewModel.fetchBusinessByUpiId(upiId);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (businessData != null) {
        log("Business found! Navigating to UserPaymentSubmitScreen with: $businessData");
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            RoutesName.userPaymentSubmitView,
            arguments: {
              'businessId': businessData['businessId'],
              'businessName': businessData['businessName'],
              'businessImage': businessData['businessImage'],
            },
          );
        }
      } else {
        isScanned = false; // Reset scan state so they can scan again
        _scannerController.start(); // Restart camera scanning
      }
      return;
    }

    // 2. Otherwise, check if it's a standard Creatoo QR
    if (_validateAndExtractData(qrCodeData)) {
      isScanned = true;
      _scannerController.stop();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      await viewModel.getBusinessData();

      if (mounted) Navigator.of(context).pop();

      if (viewModel.businessData != null && mounted) {
        Navigator.pushReplacementNamed(
          context,
          RoutesName.userPaymentSubmitView,
          arguments: {
            'businessId': viewModel.businessId,
            'businessName': viewModel.businessData!.businessName ?? 'Business',
            'businessImage': viewModel.businessData!.businessImage,
          },
        );
      } else {
        isScanned = false;
        _scannerController.start();
      }
    } else {
      await _showInvalidScanDialog();
    }
  }

  /// Validate URL-based QR format
  bool _validateUrlFormat(String url) {
    try {
      final uri = Uri.parse(url);

      log("Validating URL QR - Host: ${uri.host}, Path: ${uri.path}");

      // Validate scheme
      if (uri.scheme != 'https') {
        log("Invalid scheme: ${uri.scheme}");
        return false;
      }

      // Validate domain
      if (uri.host != 'api.creatoo.co.in') {
        log("Invalid domain: ${uri.host}");
        return false;
      }

      // Validate path contains /api/scan
      if (!uri.path.contains('/api/scan')) {
        log("Invalid path: ${uri.path}");
        return false;
      }

      // Extract and validate businessId
      final businessIdStr = uri.queryParameters['businessId'];
      if (businessIdStr == null || businessIdStr.isEmpty) {
        log("businessId parameter is missing");
        return false;
      }

      final parsedBusinessId = int.tryParse(businessIdStr);
      if (parsedBusinessId == null) {
        log("businessId is not a valid number: $businessIdStr");
        return false;
      }

      // Set the businessId in viewModel
      viewModel.businessId = parsedBusinessId;
      log("✅ Valid Creatoo URL QR - Business ID: $parsedBusinessId");
      return true;
    } catch (e) {
      log("Error parsing URL QR: $e");
      return false;
    }
  }

  /// Validate Base64-based QR format (legacy)
  bool _validateBase64Format(String qrCodeData) {
    try {
      // Decode the Base64-encoded string
      final decodedData = utf8.decode(base64.decode(qrCodeData));

      // Check if the decoded string starts with "qr_" (case-insensitive)
      if (decodedData.toLowerCase().startsWith('qr_')) {
        final parts = decodedData.split('_');
        if (parts.length >= 2) {
          viewModel.businessId = int.tryParse(parts[1]);

          log("✅ Valid Legacy Base64 QR - Decoded Data: $decodedData");
          log("Business ID: ${viewModel.businessId}");

          return viewModel.businessId != null;
        }
      }
    } catch (e) {
      log("Error decoding or parsing Base64 QR code data: $e");
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
          content:
              AppTextWidget(text: "Scanner is not valid. Please scan again."),
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

  Future<void> _showNoQrFoundDialog() async {
    _scannerController.stop();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: AppTextWidget(text: "No QR Found"),
          content: AppTextWidget(
              text:
                  "No QR code was found in the selected image. Please try with another image."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: AppTextWidget(text: "OK"),
            ),
          ],
        );
      },
    );
    _scannerController.start();
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

  _BorderCornerPainter({
    this.right = false,
    this.bottom = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double length = 40;
    const double strokeWidth = 5;

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
