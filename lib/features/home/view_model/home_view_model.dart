import 'package:creatoo/core.dart';
import 'package:creatoo/features/bill_payment/view_model/bill_payment_view_model.dart';
import 'package:creatoo/features/home/model/home_screen_response_model.dart';
import 'package:creatoo/features/home/model/subscription_response_model.dart';
import 'package:creatoo/features/home/repository/home_repository.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';
import 'package:creatoo/features/wallet/repository/business_creatoo_wallet_repository.dart';
import 'package:creatoo/features/creator_wallet/repository/creator_creatoo_wallet_repository.dart';

import '../../settings/view_model/settings_view_model.dart';
import '../../../widgets/app_dialog.dart';

class HomeViewModel with ChangeNotifier {
  final HomeRepository _myRepo = HomeRepository();
  final UrlLauncherService _urlLauncherService = UrlLauncherService();
  final SharedPreferencesService prefs = SharedPreferencesService();
  final BusinessCreatooWalletRepository _businessWalletRepo = BusinessCreatooWalletRepository();
  final CreatorCreatooWalletRepository _creatorWalletRepo = CreatorCreatooWalletRepository();
  late UserData? user = UserData();
  bool isTrue = true;
  CarouselSliderController controller = CarouselSliderController();
  int position = 0;
  int count = 0;
  int _selectedIndex = 0;
  bool _creatooView = false;
  bool? isLogout;
  num walletCreatooPoints = 0;

  // Category details
  String? businessCategory;
  Map<String, dynamic>? categoryAttributes;

  // Subscription state for business users
  Subscription? businessSubscription;
  bool hasCheckedSubscription = false;

  bool get isSubscriptionLocked =>
      roleId == Constants.businessUser &&
      hasCheckedSubscription &&
      businessSubscription == null;

  int get selectedIndex => _selectedIndex;
  bool get creatooView => _creatooView;

  void changeIndex(int index, bool creatooView) {
    _selectedIndex = index;
    _creatooView = creatooView;
    notifyListeners();
  }

  ApiResponse<HomeDataResponse> homeResponse = ApiResponse.loading();

  setResponse(ApiResponse<HomeDataResponse> response) {
    homeResponse = response;
  }

  init() async {
    if (isLogout == null || isLogout == false) {
      await getProfile();
      await getHomeData();
      if (roleId == Constants.businessUser) {
        await checkBusinessSubscription();
      }
    }
  }

  void launchBannerUrl(String? url) async {
    if (url == null || url.isEmpty) {
      debugPrint('Banner URL is null or empty');
      return;
    }

    bool launched = false;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      launched = await _urlLauncherService.launchWebUrl(url);
    } else {
      launched = await _urlLauncherService.launchAppUrl(url);
    }

    if (!launched) {
      Utils.toastMessage('Could not launch URL');
    }
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  updateBannerIndex(index) {
    position = index;
    notifyListeners();
  }

  Future<void> _fetchWalletPoints() async {
    if (roleId == Constants.businessUser) {
      var data = {
        "business_id": userId,
        "from_date": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
        "to_date": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
      };
      var response = await _businessWalletRepo.getBusinessTransactionPointApi(data);
      response.fold(
        (l) {},
        (r) {
          walletCreatooPoints = r.data?.userCreatooPoints ?? 0;
        },
      );
    } else {
      var data = {"user_id": '$userId'};
      var response = await _creatorWalletRepo.fetchCreatooPointsTransactionApi(data);
      response.fold(
        (l) {},
        (r) {
          walletCreatooPoints = r.data?.creatooPoints ?? 0;
        },
      );
    }
    notifyListeners();
  }

  Future<void> getHomeData() async {
    setResponse(ApiResponse.loading());
    var response = await _myRepo.getHomeDataApi();
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        await _fetchWalletPoints();
        if (roleId == Constants.creatorUser) {
          if (r.data?.isPendingReviewFlag != null) {
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.feedbackScreen,
                arguments: {
                  'businessName':
                      r.data?.isPendingReviewFlag?.businessName ?? "Unknown",
                  'businessId': r.data?.isPendingReviewFlag?.businessId ?? 125,
                  'orderId': r.data?.isPendingReviewFlag?.orderId ??
                      "order_Q9TCU7fsYEF5XA",
                });
          }
          if (r.data?.orderId != null && r.data!.orderId!.isNotEmpty) {
            BillPaymentViewModel billPaymentViewModel =
                Provider.of<BillPaymentViewModel>(navigatorKey.currentContext!,
                    listen: false);
            billPaymentViewModel.init();
            await billPaymentViewModel.checkTransactionStatusApiCall(
                orderId: r.data!.orderId!,
                onSuccess: () async {
                  await getHomeData();
                });
          }
        } else if (r.data?.roleSpecificData?.profileCompletionStatus != null) {
          // BillPaymentViewModel billPaymentViewModel = Provider.of<BillPaymentViewModel>(navigatorKey.currentContext!, listen: false);
          // billPaymentViewModel.init();
          // await billPaymentViewModel.checkTransactionStatus('MT6805f3c480');
          if (r.data?.roleSpecificData?.profileCompletionStatus == 0) {
            final category = businessCategory ?? 'restaurant';
            await AppDialog.showCompleteProfileDialog(
                businessCategory: category,
                onClicked: () async {
                  Provider.of<HomeViewModel>(navigatorKey.currentContext!,
                          listen: false)
                      .changeIndex(2, true);
                  Navigator.of(navigatorKey.currentContext!).pop(true);
                  await Navigator.pushNamed(navigatorKey.currentContext!,
                      RoutesName.editBusinessProfile,
                      arguments: "My Profile");
                  await Provider.of<SettingsViewModel>(
                          navigatorKey.currentContext!,
                          listen: false)
                      .fetchUserProfileDetails();
                });
          } else if (r.data?.roleSpecificData?.profileCompletionStatus == 1) {
            await AppDialog.showBusinessInfoIncompleteDialog(
                title: "Complete Your Business Description!",
                content:
                    "You haven't finished setting up your business. Complete the process to start attracting customers!",
                mandatoryFields:
                    "Business Images 4, Opening Time & Closing Time",
                buttonLabel: "Proceed To Finish",
                onClicked: () async {
                  Provider.of<HomeViewModel>(navigatorKey.currentContext!,
                          listen: false)
                      .changeIndex(2, true);
                  Navigator.of(navigatorKey.currentContext!).pop(true);
                  await Navigator.pushNamed(navigatorKey.currentContext!,
                      RoutesName.editBusinessProfile,
                      arguments: "Details");
                  await Provider.of<SettingsViewModel>(
                          navigatorKey.currentContext!,
                          listen: false)
                      .fetchUserProfileDetails();
                });
          } else if (r.data?.roleSpecificData?.profileCompletionStatus == 2) {
            await AppDialog.showBusinessInfoIncompleteDialog(
                title: "Complete Your Registration!",
                content:
                    "You haven't finished setting up your business. Complete the process to start attracting customers!",
                mandatoryFields:
                    "Discount Fields, Min order Value & Points Expiry Date",
                buttonLabel: "Proceed To Finish",
                onClicked: () async {
                  Provider.of<HomeViewModel>(navigatorKey.currentContext!,
                          listen: false)
                      .changeIndex(2, true);
                  Navigator.of(navigatorKey.currentContext!).pop(true);
                  await Navigator.pushNamed(navigatorKey.currentContext!,
                      RoutesName.editBusinessProfile,
                      arguments: "Set Discount");
                  await Provider.of<SettingsViewModel>(
                          navigatorKey.currentContext!,
                          listen: false)
                      .fetchUserProfileDetails();
                });
          }
        }
      },
    );
    notifyListeners();
  }

  Future<void> fetchCreatorProfile() async {
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchCreatorProfileApi(data);
    response.fold(
      (l) {},
      (r) async {
        // isTrue = true;

        user?.name = r.data!.name;
        user?.image = r.data!.userImage;
        user?.email = r.data!.email;
        user?.mobile = r.data!.mobile;
        user?.instagramVerificationStatus =
            r.data!.instagramVerificationStatus!;
        // if (r.data!.instagramVerificationStatus == InstagramStatus.initial.index ||
        //     r.data!.instagramVerificationStatus == InstagramStatus.rejected.index) {
        //   log("API COUNT : ${count}");
        //   if (count == 0) {
        //     ++count;
        //     notifyListeners();
        //     bool? confirm = await AppDialog.showConfirmationDialog(
        //         title: "Verify Instagram Account", content: "Please Verify Your Account to Access the Creatoo App", confirm: "Go");
        //     if (confirm!) {
        //       await Navigator.pushNamed(
        //         navigatorKey.currentContext!,
        //         RoutesName.creatorProfileDetailView,
        //         arguments: userId,
        //       );
        //     }
        //   }
        // }
      },
    );
    notifyListeners();
  }

  Future<void> fetchBusinessProfile() async {
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchBusinessProfileApi(data);
    response.fold(
      (l) {},
      (r) async {
        user?.name = r.data!.businessName;
        user?.image = r.data!.businessImage;
        user?.email = r.data!.businessEmail;
        user?.mobile = r.data!.businessMobile;
        businessCategory = r.data!.businessCategory;
        categoryAttributes = r.data!.categoryAttributes;

        // if (r.data!.instagramVerificationStatus == InstagramStatus.initial.index ||
        //     r.data!.instagramVerificationStatus == InstagramStatus.rejected.index) {
        //   log("API COUNT : ${count}");
        //   if (count == 0) {
        //     ++count;
        //     notifyListeners();
        //     bool? confirm = await AppDialog.showConfirmationDialog(
        //         title: "Verify Instagram Account", content: "Please Verify Your Account to Access the Creatoo App", confirm: "Go");
        //     if (confirm!) {
        //       await Navigator.pushNamed(
        //         navigatorKey.currentContext!,
        //         RoutesName.creatorProfileDetailView,
        //         arguments: userId,
        //       );
        //     }
        //   }
        // }
      },
    );

    notifyListeners();
  }

  getProfile() async {
    if (roleId == Constants.businessUser) {
      await fetchBusinessProfile();
    } else {
      await fetchCreatorProfile();
    }
  }

  Future<void> checkBusinessSubscription() async {
    if (roleId == Constants.businessUser && !hasCheckedSubscription) {
      var response = await _myRepo.checkBusinessSubscription();
      response.fold(
        (l) {
          // Handle error - log it
          debugPrint('Subscription check failed: ${l.message}');
        },
        (r) {
          businessSubscription = r.subscription;
          hasCheckedSubscription = true;
          if (businessSubscription == null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              AppDialog.showSubscriptionRequiredDialog();
            });
          }
          notifyListeners();
        },
      );
    }
  }
}
