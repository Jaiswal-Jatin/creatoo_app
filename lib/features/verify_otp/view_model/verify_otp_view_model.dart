import 'package:creatoo/utils/deep_link_service.dart';
import 'package:otp_autofill/otp_autofill.dart';

import '../../../core.dart';
import '../../auth/model/otp_reponse_model.dart';
import '../../home/view_model/home_view_model.dart';
import '../../settings/view_model/settings_view_model.dart';
import '../model/verify_otp_model.dart';
import '../repository/verify_otp_repository.dart';

class VerifyOtpViewModel with ChangeNotifier {
  final _myRepo = VerifyOtpRepository();

  late OTPTextEditController pinController;
  late FocusNode focusNode;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TimerHelper _timerService = TimerHelper();
  String phone = "";
  String otp = "";
  int timerDuration = 0;
  late bool timerActive = false;
  bool forceValidation = false;
  String? deviceId;

  ApiResponse<VerifyOtpResponse> verifyOtp = ApiResponse.initial();
  ApiResponse<OtpResponse> resendOtpResponse = ApiResponse.initial();

  setVerifyOtpResponse(ApiResponse<VerifyOtpResponse> response) {
    verifyOtp = response;
  }

  setResendOtpResponse(ApiResponse<OtpResponse> response) {
    resendOtpResponse = response;
  }

  updateValidation(bool value) {
    forceValidation = value;
    notifyListeners();
  }

  init(phoneNumber, recievedOtp) async {
    focusNode = FocusNode();
    phone = phoneNumber;
    otp = recievedOtp;

    // Setup OTP auto-fill using the new logic
    pinController = OTPTextEditController(
      codeLength: 6,
      onCodeReceive: (code) {
        print('🟠 [OTP AUTOFILL] Code Received: $code');
        if (code.length == 6) {
          pinController.text = code;
          final creatorVerifyPayload = {
            "mobile": phone,
            "otp": code,
            "device_id": deviceId,
            "remember_token": fcmToken,
          };
          final businessVerifyPayload = {
            "business_mobile": phone,
            "otp": code,
            "device_id": deviceId,
            "remember_token": fcmToken,
          };
          verifyOtpFromServer(
            roleId == Constants.creatorUser ? creatorVerifyPayload : businessVerifyPayload,
          );
        }
      },
    )..startListenUserConsent((code) {
        final exp = RegExp(r'(\d{6})');
        return exp.stringMatch(code ?? '') ?? '';
      });

    deviceId = await getDeviceId();
  }

  Future<String?> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String? deviceId = '';

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }

    return deviceId;
  }

  Future<void> verifyOtpFromServer(dynamic data) async {
    if (verifyOtp.status == Status.loading) return;
    
    print('=== VERIFY OTP START ===');
    setVerifyOtpResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.verifyOtp(data);

    response.fold(
      (l) {
        setVerifyOtpResponse(ApiResponse.error(l.message));
        if (l.message.toLowerCase().contains('user not exist')) {
          if (roleId == Constants.businessUser) {
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerBusinessView,
                arguments: phone);
          } else if (roleId == Constants.creatorUser) {
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerCreatorView,
                arguments: phone);
          }
        } else {
          Utils.toastMessage(l.message.toString());
        }
        notifyListeners();
      },
      (r) async {
        setVerifyOtpResponse(ApiResponse.completed(r));
        stopTimer();
        if (r.data!.isRegistered == 0) {
          if (roleId == Constants.businessUser) {
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerBusinessView,
                arguments: phone);
          } else if (roleId == Constants.creatorUser) {
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerCreatorView,
                arguments: phone);
          }
        } else {
          if (r.data!.isActive == 0) {
            Utils.toastMessage("Account is not active, please contact admin");
            setVerifyOtpResponse(ApiResponse.initial());
            notifyListeners();
            return;
          }
          await saveUserData(r.data!);
          roleId = r.data!.roleId ?? roleId;
          await SharedPreferencesService().saveUserRoleId(roleId!);
          final homeViewModel = Provider.of<HomeViewModel>(
              navigatorKey.currentContext!,
              listen: false);
          homeViewModel.isLogout = false;
          homeViewModel.homeResponse = ApiResponse.initial();
          if (roleId == Constants.businessUser) {
            await homeViewModel.checkBusinessSubscription();
          }
          Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
              RoutesName.homePage, (route) => false);
          await Future.delayed(const Duration(milliseconds: 500));
          DeepLinkService.checkPendingNavigation();
        }
        Utils.toastMessage(r.message.toString());
      },
    );
    notifyListeners();
  }

  Future<void> resendOtpFromServer(body) async {
    pinController.clear();
    setResendOtpResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.resendOtp(body);
    response.fold(
      (l) {
        Utils.toastMessage(l.message.toString());
        setResendOtpResponse(ApiResponse.error(l.message));
      },
      (r) async {
        setResendOtpResponse(ApiResponse.completed(r));
        otp = r.data!.otp ?? '';
        startTimer();
      },
    );
    notifyListeners();
  }

  startTimer() {
    timerActive = true;
    _timerService.startTimer(const Duration(seconds: 30), (time) {
      timerDuration = time;
      notifyListeners();
    });
  }

  stopTimer() {
    if (timerActive) {
      _timerService.cancelTimer();
    }
    timerDuration = 0;
    notifyListeners();
  }

  saveUserData(UserData data) async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    await prefs.saveUserData(data);
  }

  void disposeData() {
    pinController.stopListen(); // Stop listening for SMS
    pinController.dispose();
    phone = "";
    focusNode.dispose();
    stopTimer();
  }

  validateOtp(String value) {
    if (value.isEmpty) {
      return "Please enter OTP";
    } else if (value.length != 6) {
      return "OTP should be of 6 digits";
    }
    return null;
  }
}
