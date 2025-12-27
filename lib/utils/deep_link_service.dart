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
  
  // Track last processed initial link to avoid duplicate processing on restart
  static String? _lastProcessedInitialLink;
  
  // Session counter to cancel stale futures on hot restart
  static int _sessionId = 0;

  /// Initialize deep link listener
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    // Increment session ID to invalidate any pending futures from previous session
    _sessionId++;
    
    if (_isInitialized) {
      log('DeepLinkService already initialized, session: $_sessionId');
      return;
    }

    try {
      _appLinks = AppLinks();

      // Handle initial deep link (app was opened from terminated state)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        final linkStr = initialLink.toString();
        // Skip if we've already processed this exact link (prevents duplicate on restart)
        if (_lastProcessedInitialLink == linkStr) {
          log('Initial deep link already processed, skipping: $linkStr');
        } else {
          _lastProcessedInitialLink = linkStr;
          log('Initial deep link: $initialLink');
          _handleDeepLink(linkStr, isInitialLink: true);
        }
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

      // Validate domain/scheme
      if (uri.scheme == 'creatoo') {
        log('Custom scheme detected: ${uri.scheme}://${uri.host}');
        // Handle custom scheme specific logic here if needed
        if (uri.host == 'payment-response') {
          log('Handling payment response custom scheme');
          // Add navigation for payment response if necessary
          return;
        }
      } else if (uri.host != 'api.creatoo.co.in') {
        log('Invalid domain: ${uri.host}. Only api.creatoo.co.in and creatoo:// are supported.');
        return;
      }

      // Handle /api/scan route
      if (uri.path.contains('/api/scan')) {
        final businessId = uri.queryParameters['businessId'];
        
        if (businessId != null && businessId.isNotEmpty) {
          final parsedBusinessId = int.tryParse(businessId);
          
          if (parsedBusinessId != null) {
            log('Deep link received with businessId: $parsedBusinessId');
            
            // Store the business ID for later use
            _pendingBusinessId = parsedBusinessId;
            
            if (isInitialLink) {
              // For cold start, use longer delay with retry to wait for app initialization
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
    // First attempt waits longer to let app initialization complete
    // Subsequent attempts use shorter delay
    final delayMs = attempt == 0 ? 2000 : 300;
    
    // Capture current session ID to detect hot restart
    final currentSessionId = _sessionId;
    
    Future.delayed(Duration(milliseconds: delayMs), () async {
      // Check if session changed (hot restart happened) - cancel this stale future
      if (_sessionId != currentSessionId) {
        log('Session changed (hot restart detected), cancelling stale navigation');
        return;
      }
      
      final context = navigatorKey.currentContext;
      
      if (context != null) {
        // Check if user is logged in (token is set)
        if (token == null) {
          log('User not logged in, skipping deep link navigation. Business ID stored for later: $businessId');
          // Keep _pendingBusinessId so it can be used after login
          return;
        }
        
        // Clear pending business ID since we're navigating now
        _pendingBusinessId = null;
        
        // For cold start, set up proper navigation stack:
        // HomePage → BusinessDescriptionView → ProceedToCart
        // This ensures back button from ProceedToCart goes to BusinessDescriptionView
        print('🟢 [DEEPLINK] Step 1: Pushing HomePage');
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homePage,
          (route) => false, // Remove all previous routes
        );
        
        // Wait for HomePage to fully load
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Push BusinessDescriptionView
        final ctx1 = navigatorKey.currentContext;
        print('🟢 [DEEPLINK] Step 2: Context after HomePage: $ctx1');
        if (ctx1 != null) {
          print('🟢 [DEEPLINK] Step 2: Pushing BusinessDescriptionView with businessId: $businessId');
          print('🟢 [DEEPLINK] Step 2: Route name: ${RoutesName.businessDescriptionView}');
          Navigator.pushNamed(
            ctx1,
            RoutesName.businessDescriptionView,
            arguments: businessId,
          );
          
          // Wait for BusinessDescriptionView to load
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Then push ProceedToCart on top
          final ctx2 = navigatorKey.currentContext;
          print('🟢 [DEEPLINK] Step 3: Context after BusinessDescriptionView: $ctx2');
          if (ctx2 != null) {
            print('🟢 [DEEPLINK] Step 3: Pushing ProceedToCart with businessId: $businessId');
            print('🟢 [DEEPLINK] Step 3: Route name: ${RoutesName.proceedToCart}');
            Navigator.pushNamed(
              ctx2,
              RoutesName.proceedToCart,
              arguments: businessId,
            );
          }
        }
        
        log('Navigation stack created: HomePage → BusinessDescriptionView → ProceedToCart on attempt ${attempt + 1}');
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
      if (uri.host != 'api.creatoo.co.in' || !uri.path.contains('/api/scan')) {
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
      if (uri.host != 'api.creatoo.co.in') {
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
