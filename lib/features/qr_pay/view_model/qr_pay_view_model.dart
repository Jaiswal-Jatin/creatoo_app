import '../../../core.dart';
import '../model/validate_points_response_model.dart';
import '../model/view_profile_response_model.dart';
import '../repository/qr_pay_repository.dart';

class QrPayViewModel with ChangeNotifier {
  final QrPayRepository _myRepo = QrPayRepository();
  BusinessData? businessData;

  int? businessId;
  bool showError = false;
  String? errorMessage;
  num? creatooBalance;
  String? transactionId;
  num? transferredPoints;
  bool isLoading = false;
  double percentageAmount = 0.0;

  TextEditingController? amountController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  ApiResponse<ViewProfileResponseModel> businessResponse =
      ApiResponse.loading();

  void setResponse(ApiResponse<ViewProfileResponseModel> response) {
    businessResponse = response;
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  ApiResponse<ValidatePointsResponseModel> validateResponse =
      ApiResponse.initial();

  void setValidateResponse(ApiResponse<ValidatePointsResponseModel> response) {
    validateResponse = response;
  }

  init() async {
    creatooBalance = 0;
    // await getBusinessData();
  }

  Future<bool> getBusinessData() async {
    setResponse(ApiResponse.loading());
    var response = await _myRepo.getBusinessDataApi(
      body: {
        "role_id": 2,
        "id": businessId,
        "token": '$token',
      },
    );

    return response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
        notifyListeners();
        return false;
      },
      (r) {
        setResponse(ApiResponse.completed(r));
        businessData = r.data;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> validatePointsApiCall() async {
    setValidateResponse(ApiResponse.loading());
    notifyListeners();

    var response = await _myRepo.validatePointsApi(
      body: {
        "creator_id": int.parse('$userId'),
        "business_id": businessId,
        "points": roundToTwoDecimalPlaces(percentageAmount),
        "token": '$token',
      },
    );

    return response.fold(
      (l) {
        // Handle error response
        setValidateResponse(ApiResponse.error(l.message));
        showError = true;
        errorMessage = l.message;

        if (l.data != null) {
          creatooBalance = l.data;
        }
        notifyListeners();
        return false;
      },
      (r) {
        // Handle successful response
        setValidateResponse(ApiResponse.completed(r));
        creatooBalance = r.data;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> transferPointsApiCall() async {
    isLoading = true;
    notifyListeners();
    var response = await _myRepo.transferPointsApi(
      body: {
        "creator_id": int.parse('$userId'),
        "business_id": businessId,
        "points": roundToTwoDecimalPlaces(percentageAmount),
        "token": '$token',
      },
    );

    return response.fold(
      (l) {
        Utils.toastMessage(l.message.toString());
        isLoading = false;
        notifyListeners();
      },
      (r) {
        transactionId = r.data?.transactionId;
        transferredPoints = r.data?.transferredPoints;
        isLoading = false;
        notifyListeners();
        Navigator.pushNamed(
            navigatorKey.currentContext!, RoutesName.payTransferSuccessView);
      },
    );
  }

  void notify() {
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchBusinessByUpiId(String upiId) async {
    isLoading = true;
    notifyListeners();
    var response = await _myRepo.getBusinessByUpiIdApi(upiId: upiId);
    isLoading = false;
    notifyListeners();

    return response.fold(
      (l) {
        Utils.toastMessage(l.message.toString());
        return null;
      },
      (r) {
        if (r['status'] == true && r['data'] != null) {
          return r['data'] as Map<String, dynamic>;
        } else {
          Utils.toastMessage(r['message'] ??
              'This UPI ID is not registered with any business.');
          return null;
        }
      },
    );
  }
}
