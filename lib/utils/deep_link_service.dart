import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../core.dart';

/// Deep Link Service for handling app links and universal links
/// Supports Android App Links and handles /api/scan?businessId=XYZ deep links
class DeepLinkService {
  static StreamSubscription? _sub;
  static bool _isInitialized = false;
  static late AppLinks _appLinks;
  
  // Store pending deep link business ID for cold start navigation
  static int? _pendingBusinessId;

  /// Initialize deep link listener
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    if (_isInitialized) {
      log('DeepLinkService already initialized');
      return;
    }

    try {
      _appLinks = AppLinks();

      // Handle initial deep link (app was opened from terminated state)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        log('Initial deep link: $initialLink');
        _handleDeepLink(initialLink.toString(), isInitialLink: true);
      }

      // Listen for deep links when app is running or in background
      _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          log('Deep link received: $uri');
          _handleDeepLink(uri.toString(), isInitialLink: false);
        }
      }, onError: (err) {
        log('Deep link error: $err');
      });

      _isInitialized = true;
      log('DeepLinkService initialized successfully');
    } catch (e) {
      log('Failed to initialize DeepLinkService: $e');
    }
  }

  /// Dispose the deep link listener
  static void dispose() {
    _sub?.cancel();
    _isInitialized = false;
    _pendingBusinessId = null;
    log('DeepLinkService disposed');
  }

  /// Handle deep link and navigate to appropriate screen
  static void _handleDeepLink(String link, {bool isInitialLink = false}) {
    try {
      final uri = Uri.parse(link);
      log('Parsed URI - Host: ${uri.host}, Path: ${uri.path}, Query: ${uri.queryParameters}');

      // Validate domain
      if (uri.host != 'api.tapbill.in') {
        log('Invalid domain: ${uri.host}');
        return;
      }

      // Handle /api/scan route
      if (uri.path.contains('/api/scan')) {
        final businessId = uri.queryParameters['businessId'];
        
        if (businessId != null && businessId.isNotEmpty) {
          final parsedBusinessId = int.tryParse(businessId);
          
          if (parsedBusinessId != null) {
            log('Navigating to ProceedToCart with businessId: $parsedBusinessId');
            
            if (isInitialLink) {
              // For cold start, store the pending business ID and use longer delay with retry
              _pendingBusinessId = parsedBusinessId;
              _navigateToProceedToCartWithRetry(parsedBusinessId);
            } else {
              // For warm start, navigate immediately with short delay
              _navigateToProceedToCart(parsedBusinessId);
            }
          } else {
            log('Invalid businessId format: $businessId');
          }
        } else {
          log('businessId parameter is missing or empty');
        }
      } else {
        log('Unhandled deep link path: ${uri.path}');
      }
    } catch (e) {
      log('Error handling deep link: $e');
    }
  }

  /// Navigate to ProceedToCart page with businessId (for warm start)
  static void _navigateToProceedToCart(int businessId) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.pushNamed(
          context,
          RoutesName.proceedToCart,
          arguments: businessId,
        );
        log('Navigation to ProceedToCart completed');
      } else {
        log('Navigator context is null, cannot navigate');
      }
    });
  }

  /// Navigate with retry logic for cold start scenarios
  /// This sets up proper navigation stack with home screen as base
  static void _navigateToProceedToCartWithRetry(int businessId, [int attempt = 0]) {
    const maxAttempts = 10;
    const delayMs = 500;
    
    Future.delayed(Duration(milliseconds: delayMs), () {
      final context = navigatorKey.currentContext;
      
      if (context != null) {
        // Clear pending business ID since we're navigating now
        _pendingBusinessId = null;
        
        // For cold start, set up proper navigation stack:
        // 1. First navigate to home page and clear everything
        // 2. Then push ProceedToCart on top
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homePage,
          (route) => false, // Remove all previous routes
        );
        
        // Add a small delay before pushing ProceedToCart
        Future.delayed(const Duration(milliseconds: 100), () {
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            Navigator.pushNamed(
              ctx,
              RoutesName.proceedToCart,
              arguments: businessId,
            );
          }
        });
        
        log('Navigation to ProceedToCart completed on attempt ${attempt + 1}');
      } else if (attempt < maxAttempts) {
        log('Navigator context is null, retrying... (attempt ${attempt + 1}/$maxAttempts)');
        _navigateToProceedToCartWithRetry(businessId, attempt + 1);
      } else {
        log('Failed to navigate after $maxAttempts attempts. Navigator context still null.');
        _pendingBusinessId = null;
      }
    });
  }

  /// Check and handle any pending deep link navigation
  /// Call this from your main app widget's initState or after user login
  static void checkPendingNavigation() {
    if (_pendingBusinessId != null) {
      log('Found pending deep link navigation, businessId: $_pendingBusinessId');
      final businessId = _pendingBusinessId!;
      _pendingBusinessId = null;
      _navigateToProceedToCart(businessId);
    }
  }

  /// Get pending business ID if any (for custom handling)
  static int? get pendingBusinessId => _pendingBusinessId;
  
  /// Clear pending business ID
  static void clearPendingBusinessId() {
    _pendingBusinessId = null;
  }

  /// Manually handle a deep link (for testing or custom scenarios)
  static void handleLink(String link) {
    _handleDeepLink(link);
  }

  /// Parse business ID from scan URL
  /// Returns null if URL is invalid or businessId is not present
  static int? parseBusinessIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Validate domain and path
      if (uri.host != 'api.tapbill.in' || !uri.path.contains('/api/scan')) {
        return null;
      }

      final businessId = uri.queryParameters['businessId'];
      if (businessId != null && businessId.isNotEmpty) {
        return int.tryParse(businessId);
      }
      
      return null;
    } catch (e) {
      log('Error parsing business ID from URL: $e');
      return null;
    }
  }

  /// Validate if a URL is a valid Creatoo scan URL
  static bool isValidCreatooScanUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Check scheme (must be https)
      if (uri.scheme != 'https') {
        return false;
      }
      
      // Check domain
      if (uri.host != 'api.tapbill.in') {
        return false;
      }
      
      // Check path
      if (!uri.path.contains('/api/scan')) {
        return false;
      }
      
      // Check businessId parameter
      final businessId = uri.queryParameters['businessId'];
      if (businessId == null || businessId.isEmpty) {
        return false;
      }
      
      // Validate businessId is numeric
      if (int.tryParse(businessId) == null) {
        return false;
      }
      
      return true;
    } catch (e) {
      log('Error validating Creatoo scan URL: $e');
      return false;
    }
  }
}
