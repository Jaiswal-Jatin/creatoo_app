import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: _BorderCornerPainter(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: _BorderCornerPainter(right: true),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: _BorderCornerPainter(bottom: true),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: _BorderCornerPainter(right: true, bottom: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan Business QR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
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
