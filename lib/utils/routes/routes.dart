import 'package:creatoo/core.dart';
import 'package:creatoo/features/add_post/view/add_post_view.dart';
import 'package:creatoo/features/add_post_payment_summary/view/add_post_payment_summary_view.dart';
import 'package:creatoo/features/bill_payment/view/payment_success_view.dart';
import 'package:creatoo/features/bill_payment/view/proceed_to_cart.dart';
import 'package:creatoo/features/bill_payment/view/proceed_to_pay.dart';
import 'package:creatoo/features/business/qr_code/view/business_qr_view.dart';
import 'package:creatoo/features/business_profile/view/business_profile.dart';
import 'package:creatoo/features/business_profile/view/edit_business_profile.dart';
import 'package:creatoo/features/coming_soon/view/coming_soon_view.dart';
import 'package:creatoo/features/creator_home/view/creator_home_view.dart';
import 'package:creatoo/features/creator_profile/view/creator_profile_detail_view.dart';
import 'package:creatoo/features/creator_profile/view/edit_creator_profile_view.dart';
import 'package:creatoo/features/creator_wallet/view/creator_wallet_view.dart';
import 'package:creatoo/features/earn_creatoo_points/view/earn_creatoo_points_view.dart';
import 'package:creatoo/features/feedback/view/thank_you_feedback.dart';
import 'package:creatoo/features/home/view/home_page.dart';
import 'package:creatoo/features/home/view/home_view.dart';
import 'package:creatoo/features/notification/view/notification_view.dart';
import 'package:creatoo/features/payment_details/view/payment_detail_view.dart';
import 'package:creatoo/features/post/view/post_view.dart';
import 'package:creatoo/features/post_detail/view/post_detail_view.dart';
import 'package:creatoo/features/qr_pay/view/pay_transfer_view.dart';
import 'package:creatoo/features/qr_pay/view/qr_scanner_view.dart';
import 'package:creatoo/features/register_business/view/register_business_view.dart';
import 'package:creatoo/features/register_creator/view/register_creator_view.dart';
import 'package:creatoo/features/review/view/reviews_view.dart';
import 'package:creatoo/features/scanner/view/scanner_view.dart';
import 'package:creatoo/features/search/view/business_description_view.dart';
import 'package:creatoo/features/search/view/search_view.dart';
import 'package:creatoo/features/shortlist/view/shortlist_view.dart';
import 'package:creatoo/features/verify_otp/view/verify_otp_view.dart';
import 'package:creatoo/features/wallet/view/business_wallet_view.dart';
import 'package:creatoo/features/wallet/view/wallet_view.dart';
import 'package:creatoo/widgets/app_success_widget.dart';
import 'package:creatoo/features/card/view/card_screen.dart';
import 'package:creatoo/features/force_update/view/force_update_screen.dart';

import '../../features/add_post/model/add_post_model.dart';
import '../../features/auth/view/auth_view.dart';
import '../../features/creator_contact/view/creator_contact_view.dart';
import '../../features/feedback/view/feedback.dart';
import '../../features/onboarding/view/onboarding_view.dart';
import '../../features/opportunity/view/opportunity_view.dart';
import '../../features/qr_pay/view/pay_transfer_success_view.dart';
import '../../features/qr_pay/view/scanner_pay_view.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/startup/view/startup_view.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🔵 [ROUTES] Requested route: "${settings.name}" with arguments: ${settings.arguments}');
    
    // Handle deep link URL pattern: /api/scan?businessId=XXX
    // This happens when app resumes from background via deep link
    if (settings.name != null && settings.name!.contains('/api/scan')) {
      print('🟡 [ROUTES] Detected deep link URL pattern, extracting businessId');
      try {
        final uri = Uri.parse('https://api.creatoo.co.in${settings.name}');
        final businessIdStr = uri.queryParameters['businessId'];
        if (businessIdStr != null) {
          final businessId = int.tryParse(businessIdStr);
          if (businessId != null) {
            print('🟢 [ROUTES] Extracted businessId: $businessId, navigating to BusinessDescriptionView');
            return _buildRoute(
              settings,
              BusinessDescriptionView(businessId: businessId),
            );
          }
        }
      } catch (e) {
        print('🔴 [ROUTES] Error parsing deep link URL: $e');
      }
    }
    
    switch (settings.name) {
      case RoutesName.onboardingView:
        return _buildRoute(settings, OnboardingView());

      case RoutesName.forceUpdateView:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          settings,
          ForceUpdateScreen(
            message: args['message'] ?? 'A new update is available',
            currentVersion: args['currentVersion'] ?? '',
            latestVersion: args['latestVersion'] ?? '',
          ),
        );

      case RoutesName.startupView:
        return _buildRoute(settings, StartupView());

      case RoutesName.authView:
        return _buildRoute(settings, const AuthView());

      case RoutesName.verifyOtpView:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
            settings,
            VerifyOtpView(
              phone: args["phone"],
              otp: args["otp"],
            ));

      case RoutesName.registerBusinessView:
        return _buildRoute(
            settings,
            RegisterBusinessView(
              phone: settings.arguments as String,
            ));

      case RoutesName.registerCreatorView:
        return _buildRoute(
            settings,
            RegisterCreatorView(
              phone: settings.arguments as String,
            ));

      case RoutesName.homePage:
        return _buildRoute(settings, HomePage());

      case RoutesName.homeView:
        return _buildRoute(settings, const HomeView());

      case RoutesName.paymentSuccessView:
        return _buildRoute(settings, const PaymentSuccessView());

      case RoutesName.searchView:
        return _buildRoute(settings, const SearchView());

      case RoutesName.walletView:
        return _buildRoute(settings, const WalletView());

      case RoutesName.settingsView:
        return _buildRoute(settings, SettingsView());

      case RoutesName.postView:
        return _buildRoute(settings, const PostView());

      case RoutesName.addPostView:
        return _buildRoute(settings, const AddPostView());

      case RoutesName.businessProfile:
        return _buildRoute(settings, const BusinessProfileView());

      case RoutesName.editBusinessProfile:
        return _buildRoute(
          settings,
          EditBusinessProfile(
            initialTab: settings.arguments == null ? "My Profile" : settings.arguments as String,
          ),
        );

      case RoutesName.webView:
        return _buildRoute(settings, AppWebView(data: settings.arguments as WebViewData));

      case RoutesName.addPostPaymentSummary:
        return _buildRoute(
            settings,
            AddPostPaymentSummaryView(
              data: settings.arguments as AddPostModel,
            ));

      case RoutesName.shortlistView:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          settings,
          ShortlistView(
            postId: args['id'],
            minCreatorsRequired: args['minCreatorsRequired'],
          ),
        );

      case RoutesName.successView:
        return _buildRoute(settings, const AppSuccessWidget());

      case RoutesName.creatorHomeView:
        return _buildRoute(settings, const CreatorHomeView());

      case RoutesName.editCreatorProfileView:
        return _buildRoute(settings, const EditCreatorProfileView());

      case RoutesName.creatorProfileDetailView:
        return _buildRoute(
            settings,
            CreatorProfileDetailView(
              id: settings.arguments as int,
            ));

      case RoutesName.creatorWalletView:
        return _buildRoute(settings, CreatorWalletView());

      case RoutesName.applicationView:
        return _buildRoute(settings, OpportunityView(searchKey: settings.arguments as String));

      case RoutesName.earnCreatooPointsView:
        return _buildRoute(settings, EarnCreatooPointsView());

      case RoutesName.loading:
        return _buildRoute(settings, AppLoadingWidget());

      case RoutesName.postDetailView:
        return _buildRoute(settings, PostDetailView(postId: settings.arguments as int));

      case RoutesName.paymentDetail:
        return _buildRoute(settings, PaymentDetailView());

      case RoutesName.thankYouFeedback:
        return _buildRoute(settings, ThankYouFeedback());

      case RoutesName.creatorContactView:
        return _buildRoute(
          settings,
          CreatorContactView(
            postId: settings.arguments as int,
          ),
        );

      case RoutesName.scannerView:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
            settings,
            ScannerView(
              qrUrl: args['qrUrl'],
              businessName: args['businessName'],
            ));

      case RoutesName.scannerPayView:
        return _buildRoute(settings, ScannerPayView());

      case RoutesName.qrScannerView:
        return _buildRoute(settings, QrScannerView());

      case RoutesName.payTransferView:
        return _buildRoute(settings, PayTransferView());

      case RoutesName.payTransferSuccessView:
        return _buildRoute(settings, PayTransferSuccessView());

      case RoutesName.businessWalletView:
        return _buildRoute(
          settings,
          BusinessWalletView(
            index: settings.arguments as int? ?? 0,
          ),
        );

      case RoutesName.notificationView:
        return _buildRoute(settings, NotificationView());

      case RoutesName.businessDescriptionView:
        return _buildRoute(
          settings,
          BusinessDescriptionView(
            businessId: settings.arguments as int? ?? 0,
          ),
        );

      case RoutesName.proceedToCart:
        return _buildRoute(
          settings,
          ProceedToCart(
            businessId: settings.arguments as int? ?? 0,
          ),
        );

      case RoutesName.proceedToPay:
        return _buildRoute(settings, ProceedToPay());

      case RoutesName.comingSoonView:
        return _buildRoute(settings, ComingSoonView());

      case RoutesName.feedbackScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
            settings,
            FeedbackScreen(
              businessName: args['businessName'],
              businessId: args['businessId'],
              orderId: args['orderId'],
            ));

      case RoutesName.reviewView:
        return _buildRoute(
            settings,
            ReviewsView(
              creatorId: settings.arguments as int? ?? 0,
              business_id: settings.arguments as int,
            ));

      case RoutesName.cardView:
        return _buildRoute(settings, const CardScreen());

      case RoutesName.businessQrView:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          settings,
          BusinessQrView(
            businessId: args['businessId'] as int,
            businessName: args['businessName'] as String,
          ),
        );

      default:
        print('🔴 [ROUTES] NO ROUTE FOUND for: "${settings.name}"');
        return _buildRoute(
          settings,
          const Scaffold(
            body: Center(
              child: Text('No route defined'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      settings: settings,
    );
  }
}
