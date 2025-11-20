import '../../../core.dart';
import '../../scanner/model/scanner_model_response.dart';
import '../model/business_list_response.dart';
import '../model/creatoo_points_response.dart';
import '../model/request_creatoo_points_model.dart';
import '../repository/earn_creatoo_points_repository.dart';

class EarnCreatooPointsViewModel with ChangeNotifier {
  final _myRepo = EarnCreatooPointsRepository();

  int? discount;
  int? minAmount;
  double percentageAmount = 0.0;
  bool businessSelected = false;
  RequestCreatooPointsModel model = RequestCreatooPointsModel();
  TextEditingController amountController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool? isValid;
  bool isLoading = false;

  ApiResponse<CreatooPointsResponse> apiResponse = ApiResponse.initial();

  setResponse(ApiResponse<CreatooPointsResponse> response) {
    apiResponse = response;
  }

  void init() {
    amountController = TextEditingController();
    pointsController = TextEditingController();
    model.image = "";
    businessSelected = false;
  }

  void notify() {
    notifyListeners();
  }

  double roundToTwoDecimalPlaces(double value) {
    return (value * 100).round() / 100;
  }

  Future<void> requestCreatooPoints() async {
    setResponse(ApiResponse.loading());
    model.creatorId = userId;
    model.token = '$token';

    notifyListeners();
    var response = await _myRepo.requestCreatooPointsApi(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        Navigator.pop(navigatorKey.currentContext!);
      },
    );
    notifyListeners();
  }

  Future<List<Business>> fetchBusinessList(String searchKey) async {
    isLoading = true;
    List<Business> businessList = [];
    if (searchKey.length < 3) {
      return businessList;
    }
    var body = {"search_key": searchKey};
    var response = await _myRepo.fetchBusinessListApi(body);
    response.fold(
      (l) {
        isLoading = false;
        return businessList;
      },
      (r) {
        isLoading = false;
        businessList = r.data!;
        return businessList;
      },
    );
    isLoading = false;
    return businessList;
  }

  Future<void> getImageAttachment() async {
    File? file = await ImageHelper.pickImage();
    if (file != null) {
      model.image = file.path;
      isValid = true;
    } else {
      Utils.toastMessage("Failed to attach image");
    }
    notifyListeners();
  }

  bool validate() {
    isValid = formKey.currentState!.validate();

    if (model.image == null || model.image!.isEmpty) {
      isValid = false;
    }

    print(isValid);
    return isValid!;
  }

  Future<void> fetchBusinessSettings({required int businessId}) async {
    Map<String, dynamic> body = {
      "business_id": businessId,
    };
    final Either<AppException, ScannerModelResponse> response = await _myRepo.getBusinessSettingApi(body);

    response.fold(
      (l) {
        Utils.toastMessage(l.message);
      },
      (r) {
        discount = r.data?.setDiscount;
        minAmount = r.data?.minOrder;
      },
    );
    notifyListeners();
  }
}
