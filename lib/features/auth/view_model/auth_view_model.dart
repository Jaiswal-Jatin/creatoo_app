import 'package:creatoo/core.dart';

import '../model/otp_reponse_model.dart';
import '../repository/auth_repository.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _myRepo = AuthRepository();
  late TextEditingController phoneController;
  late GlobalKey<FormState> formKey;
  String countryCode = "+91";

  bool hasError = false;

  ApiResponse<OtpResponse> otp = ApiResponse.initial();

  setResponse(ApiResponse<OtpResponse> response) {
    otp = response;
  }

  init() {
    formKey = GlobalKey<FormState>();
    phoneController = TextEditingController();
  }

  Future<void> getOtpFromServer(dynamic data) async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.getOtp(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // Utils.toastMessage("OTP is: ${r.data!.otp}");
        Utils.toastMessage(r.message.toString());
        setResponse(ApiResponse.completed(r));
        Navigator.pushNamed(
          navigatorKey.currentContext!,
          RoutesName.verifyOtpView,
          arguments: {"phone": phoneController.text, "otp": r.data!.otp},
        );
        phoneController.clear();
      },
    );
    notifyListeners();
  }

  void disposeData() {
    phoneController.clear();
    phoneController.dispose();
  }
}
