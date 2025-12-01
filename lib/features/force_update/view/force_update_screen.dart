import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  final String message;
  final String currentVersion;
  final String latestVersion;

  const ForceUpdateScreen({
    Key? key,
    required this.message,
    required this.currentVersion,
    required this.latestVersion,
  }) : super(key: key);

  // Play Store URL - replace with your actual app package name
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.creatoo.app';
  
  // App Store URL - replace with your actual app id  
  static const String appStoreUrl =
      'https://apps.apple.com/app/idYOUR_APP_ID';

  Future<void> _launchStore() async {
    final String url = Platform.isAndroid ? playStoreUrl : appStoreUrl;
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch store URL');
      }
    } catch (e) {
      print('Error launching store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disable back button
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  
                  // Update Icon with animation container
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 60,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Main Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          'Update Required',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1a1a2e),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Version info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE8EBFF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildVersionColumn(
                                'Current',
                                currentVersion.split('+').first,
                                const Color(0xFF999999),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                              _buildVersionColumn(
                                'Latest',
                                latestVersion.split('+').first,
                                const Color(0xFF667eea),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _launchStore,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadowColor: const Color(0xFF667eea).withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upgrade_rounded,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Update Now',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Footer text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Please update to continue using the app',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionColumn(String label, String version, Color versionColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'v$version',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: versionColor,
          ),
        ),
      ],
    );
  }
}
