import 'package:smart_auth/smart_auth.dart';

import '../../../core.dart';
import '../../../data/services/sms_retriver_service.dart';
import '../../auth/model/otp_reponse_model.dart';
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
  int otp = 0;
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
    setVerifyOtpResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.verifyOtp(data);
    response.fold(
      (l) {
        setVerifyOtpResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
        notifyListeners();
      },
      (r) async {
        setVerifyOtpResponse(ApiResponse.completed(r));
        stopTimer();
        if (r.data!.isRegistered == 0) {
          if (roleId == Constants.businessUser) {
            Navigator.pushNamed(navigatorKey.currentContext!, RoutesName.registerBusinessView, arguments: phone);
          } else if (roleId == Constants.creatorUser) {
            Navigator.pushNamed(navigatorKey.currentContext!, RoutesName.registerCreatorView, arguments: phone);
          }
        } else {
          await saveUserData(r.data!);
          Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!, RoutesName.homePage, (route) => false);
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
        otp = r.data!.otp!;
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
