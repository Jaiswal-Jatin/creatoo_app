import 'package:creatoo/core.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';

import '../../home/view_model/home_view_model.dart';
import '../model/logout_model.dart';
import '../model/settings_item.dart';
import '../repository/settings_repository.dart';

class SettingsViewModel with ChangeNotifier {
  final SettingsRepository _myRepo = SettingsRepository();

  Map<String, String> data = {};
  UserData? userData = UserData();
  bool isLoading = false;
  ApiResponse<LogoutResponse> apiResponse = ApiResponse.initial();

  setResponse(ApiResponse<LogoutResponse> response) {
    apiResponse = response;
  }

  List<SettingsItem> itemList = [];

  init() async {
    fetchProfileItems();
    if (roleId == Constants.businessUser) {
      await fetchUserProfileDetails();
    } else {
      await fetchCreatorProfileDetails();
    }
  }

  Future<void> logout() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.logoutApi();
    response.fold(
      (failure) {
        setResponse(ApiResponse.error(failure.message));
        Utils.toastMessage(failure.message.toString());
      },
      (data) async {
        setResponse(ApiResponse.completed(data));
        await deleteLocalData();
        token = null;
        userId = null;
        roleId = null;
        Utils.toastMessage(data.message.toString());
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, RoutesName.startupView, (route) => false);
      },
    );
    notifyListeners();
  }

  Future<void> inactiveUser() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.inactiveUserApi();
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        await deleteLocalData();
        Utils.toastMessage(r.message.toString());
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, RoutesName.startupView, (route) => false);
      },
    );
    notifyListeners();
  }

  Future<void> fetchUserProfileDetails() async {
    isLoading = true;
    var body = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchBusinessProfileApi(body);
    response.fold(
      (l) {
        // Utils.toastMessage(l.message.toString());
      },
      (r) async {
        userData?.gst = r.data!.gstNumber;
        userData?.image = r.data!.businessImage!;
        userData?.name = r.data!.businessFullname!;
        userData?.mobile = r.data!.businessMobile!;
      },
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCreatorProfileDetails() async {
    isLoading = true;
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchCreatorProfileApi(data);
    response.fold(
      (l) {
        // Utils.toastMessage(l.message.toString());
      },
      (r) async {
        if (r.data?.userImage != null) {
          userData?.image = r.data!.userImage!;
        }
        userData?.name = r.data!.name!;
        userData?.mobile = r.data!.mobile!;
        // Utils.toastMessage(r.message.toString());
      },
    );
    isLoading = false;
    notifyListeners();
  }

  deleteLocalData() async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    await prefs.deleteAll();
  }

  fetchProfileItems() {
    itemList = [
      SettingsItem(
        iconData: Icons.account_circle_outlined,
        name: "My Profile",
        onTap: () async {
          if (roleId == Constants.businessUser) {
            await Navigator.pushNamed(navigatorKey.currentContext!, RoutesName.editBusinessProfile);
            await fetchUserProfileDetails();
          } else {
            await Navigator.pushNamed(
              navigatorKey.currentContext!,
              RoutesName.editCreatorProfileView,
            );
            await fetchCreatorProfileDetails();
          }
        },
      ),
      // if (roleId == Constants.creatorUser)
      //   SettingsItem(
      //     iconData: Icons.account_balance_wallet_outlined,
      //     name: "Bank Details",
      //     onTap: () async {
      //       Navigator.pushNamed(navigatorKey.currentContext!, RoutesName.paymentDetail);
      //     },
      //   ),
      SettingsItem(
        iconData: Icons.info_outline,
        name: "Privacy Policy",
        onTap: () async {
          await Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.webView,
            arguments: WebViewData(
              "",
              "${AppUrl.host}/api/privacy-policy.html",
              enableAppBar: true,
            ),
          );
          await init();
        },
      ),
      SettingsItem(
        iconData: Icons.policy_outlined,
        name: "Terms And Conditions",
        onTap: () async {
          await Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.webView,
            arguments: WebViewData(
              "",
              "${AppUrl.host}/api/Terms-And-Conditions.html",
              enableAppBar: true,
            ),
          );
          await init();
        },
      ),
      SettingsItem(
        iconData: Icons.payment_outlined,
        name: "Return And Refund",
        onTap: () async {
          await Navigator.pushNamed(
            navigatorKey.currentContext!,
            RoutesName.webView,
            arguments: WebViewData(
              "",
              "${AppUrl.host}/api/refund-policy.html",
              enableAppBar: true,
            ),
          );
          await init();
        },
      ),
      SettingsItem(
        iconData: Icons.currency_rupee_rounded,
        name: "Pricing",
        onTap: () async {
          await AppDialog.showPricingDialog();
        },
      ),
      // ProfileItem(
      //     iconData: Icons.contact_phone_outlined,
      //     name: "Contact Us",
      //     onTap: () async {}),
      SettingsItem(
        iconData: Icons.manage_accounts_outlined,
        name: "Delete My Account",
        onTap: () async {
          bool? confirm = await AppDialog.showConfirmationDialog(content: "Are you sure you want to delete your account?");
          if (confirm == null) {
            return Utils.toastMessage("Something went wrong, Please try again!");
          }
          if (confirm) {
            await inactiveUser();
          }
        },
      ),
      SettingsItem(
        iconData: Icons.logout,
        name: "Logout",
        onTap: () async {
          bool? confirm = await AppDialog.showConfirmationDialog(content: "Are you sure you want to logout?");
          if (confirm == null) {
            return Utils.toastMessage("Something went wrong, Please try again!");
          }
          if (confirm) {
            await logout();
            Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).isLogout = true;
            Provider.of<HomeViewModel>(navigatorKey.currentContext!, listen: false).changeIndex(
              0,
              true,
            );
          }
        },
      ),
    ];
  }
}
