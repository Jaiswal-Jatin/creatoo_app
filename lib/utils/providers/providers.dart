import 'package:creatoo/features/bill_payment/view_model/bill_payment_view_model.dart';
import 'package:creatoo/features/category/view_model/category_view_model.dart';
import 'package:creatoo/features/creator_contact/view_model/creator_contact_view_model.dart';
import 'package:creatoo/features/feedback/view_model/feedback_view_model.dart';
import 'package:creatoo/features/notification/view_model/notification_view_model.dart';
import 'package:creatoo/features/qr_pay/view_model/qr_pay_view_model.dart';
import 'package:creatoo/features/review/view_model/reviews_view_model.dart';
import 'package:creatoo/features/scanner/view_model/scanner_view_model.dart';
import 'package:provider/single_child_widget.dart';

import '../../core.dart';
import '../../features/add_post/view_model/add_post_view_model.dart';
import '../../features/add_post_payment_summary/view_model/add_post_payment_summary_view_model.dart';
import '../../features/auth/view_model/auth_view_model.dart';
import '../../features/business_profile/view_model/business_profile_view_model.dart';
import '../../features/business_profile/view_model/edit_business_profile_view_model.dart';
import '../../features/creator_home/view_model/creator_home_view_model.dart';
import '../../features/creator_profile/view_model/creator_profile_detail_view_model.dart';
import '../../features/creator_profile/view_model/edit_creator_profile_view_model.dart';
import '../../features/creator_wallet/view_model/creator_wallet_view_model.dart';
import '../../features/earn_creatoo_points/view_model/earn_creatoo_points_view_model.dart';
import '../../features/home/view_model/home_view_model.dart';
import '../../features/opportunity/view_model/opportunity_view_model.dart';
import '../../features/payment_details/view_model/payment_detail_view_model.dart';
import '../../features/post/view_model/post_view_model.dart';
import '../../features/post_detail/view_model/post_detail_view_model.dart';
import '../../features/register_business/view_model/register_business_view_model.dart';
import '../../features/register_creator/view_model/register_creator_view_model.dart';
import '../../features/search/view_model/search_view_model.dart';
import '../../features/settings/view_model/settings_view_model.dart';
import '../../features/shortlist/view_model/shortlist_view_model.dart';
import '../../features/startup/view_model/startup_view_model.dart';
import '../../features/verify_otp/view_model/verify_otp_view_model.dart';
import '../../features/wallet/view_model/businees_wallet_creatoo_view_model.dart';
import '../../features/wallet/view_model/business_wallet_earning_view_model.dart';
import '../../features/wallet/view_model/wallet_view_model.dart';

class Providers {
  static List<SingleChildWidget> getAllProviders() {
    List<SingleChildWidget> providers = [
      ChangeNotifierProvider(
        create: (BuildContext context) => StartupViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => AuthViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => VerifyOtpViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => RegisterCreatorViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => RegisterBusinessViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => HomeViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => SearchViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => SettingsViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => PostViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => BusinessProfileViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => EditBusinessProfileViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => WalletViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => AddPostViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => AddPostSummaryViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ShortlistViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => CreatorHomeViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => OpportunityViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => PostDetailViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => EarnCreatooPointsViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => CreatorProfileDetailViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => EditCreatorProfileViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => PaymentDetailViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => CreatorContactViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => BusinessWalletEarningViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => QrPayViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => BusinessWalletCreatooViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => ScannerViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => NotificationViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => CategoryViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => BillPaymentViewModel(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => FeedbackViewModel(),
      ),
      ChangeNotifierProvider(create: (BuildContext context) => ReviewsViewModel()),
      ChangeNotifierProvider(create: (BuildContext context) => CreatorWalletViewModel())
    ];
    return providers;
  }
}
