import 'package:smart_auth/smart_auth.dart';

import '../../../core.dart';
import '../../../data/services/sms_retriver_service.dart';
import '../../../utils/deep_link_service.dart';
import '../../auth/model/otp_reponse_model.dart';
import '../../home/view_model/home_view_model.dart';
import '../model/verify_otp_model.dart';
import '../repository/verify_otp_repository.dart';

class VerifyOtpViewModel with ChangeNotifier {
  final _myRepo = VerifyOtpRepository();

  late SmsRetriever smsRetriever;
  late TextEditingController pinController;
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
    pinController = TextEditingController();
    focusNode = FocusNode();
    phone = phoneNumber;
    otp = recievedOtp;
    smsRetriever = SmsRetrieverImpl(SmartAuth());
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
    print('=== VERIFY OTP BUTTON CLICKED ===');
    print('Payload Data: $data');
    print('Phone: $phone');
    print('OTP: $otp');
    print('Device ID: $deviceId');
    print('Pin Controller Value: ${pinController.text}');

    setVerifyOtpResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.verifyOtp(data);

    print('Response Received: $response');

    response.fold(
      (l) {
        print('ERROR Response: ${l.message}');
        print('Error Details: $l');
        setVerifyOtpResponse(ApiResponse.error(l.message));

        // Check if error message indicates user doesn't exist
        if (l.message?.toLowerCase().contains('user not exist') == true) {
          print('User Not Found - Redirecting to Registration');
          if (roleId == Constants.businessUser) {
            print('Redirecting to Business Registration');
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerBusinessView,
                arguments: phone);
          } else if (roleId == Constants.creatorUser) {
            print('Redirecting to Creator Registration');
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
        print('SUCCESS Response: ${r.message}');
        print('Response Data: ${r.data}');
        print('Is Registered: ${r.data!.isRegistered}');
        print('User Data: ${r.data}');

        setVerifyOtpResponse(ApiResponse.completed(r));
        stopTimer();
        if (r.data!.isRegistered == 0) {
          print('User Not Registered - Redirecting to Registration Screen');
          if (roleId == Constants.businessUser) {
            print('Redirecting to Business Registration');
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerBusinessView,
                arguments: phone);
          } else if (roleId == Constants.creatorUser) {
            print('Redirecting to Creator Registration');
            Navigator.pushNamed(
                navigatorKey.currentContext!, RoutesName.registerCreatorView,
                arguments: phone);
          }
        } else {
          // Check if user (business or creator) is inactive
          if (r.data!.isActive == 0) {
            print('User is inactive - Login blocked');
            Utils.toastMessage("Account is not active, please contact admin");
            setVerifyOtpResponse(ApiResponse.initial()); // Reset loading state
            notifyListeners();
            return; // Don't proceed with login
          }

          print('User Already Registered - Navigating to Home');
          await saveUserData(r.data!);

          // Check subscription for business users before navigating
          if (roleId == Constants.businessUser) {
            final homeViewModel = Provider.of<HomeViewModel>(
                navigatorKey.currentContext!,
                listen: false);
            await homeViewModel.checkBusinessSubscription();
          }

          Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
              RoutesName.homePage, (route) => false);

          // Check for pending deep link navigation after successful login
          // This handles the case where user opened a bill payment link but wasn't logged in
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
        // Utils.toastMessage("OTP is: ${r.data!.otp}");
        otp = r.data!.otp ?? '';
        print(otp);
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
    pinController.clear();
    pinController.dispose();
    phone = "";
    focusNode.dispose();
    stopTimer();
  }

  validateOtp(String value) {
    if (value!.isEmpty) {
      return "Please enter OTP";
    } else if (value.length != 6) {
      return "OTP should be of 6 digits";
    }
    return null;
  }
}
