import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Utility class for generating QR codes for business deep links
class QrCodeGenerator {
  /// Generate QR code URL for a business
  /// Format: https://api.creatoo.co.in/api/scan?businessId={businessId}
  static String generateQrUrl(int businessId) {
    return 'https://api.creatoo.co.in/api/scan?businessId=$businessId';
  }

  /// Generate QR code widget for a business
  /// 
  /// Parameters:
  /// - businessId: The unique ID of the business
  /// - size: Size of the QR code (default: 280)
  /// - backgroundColor: Background color (default: white)
  /// - foregroundColor: QR code color (default: black)
  static Widget generateQrWidget({
    required int businessId,
    double size = 280.0,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    bool embeddedImage = false,
  }) {
    final qrUrl = generateQrUrl(businessId);
    
    return QrImageView(
      data: qrUrl,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
  }

  /// Generate QR code with custom styling and branding
  static Widget generateBrandedQrWidget({
    required int businessId,
    required String businessName,
    double size = 300.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Business name header
          Text(
            businessName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan to Pay',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          
          // QR Code
          generateQrWidget(
            businessId: businessId,
            size: size,
          ),
          
          const SizedBox(height: 20),
          
          // Footer text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Powered by Creatoo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get QR URL as string (useful for sharing or displaying)
  static String getQrUrlText(int businessId) {
    return generateQrUrl(businessId);
  }
}
