import 'package:creatoo/core.dart';

import '../model/payment_detail_model.dart';
import '../model/payment_detail_response.dart';
import '../repository/payment_detail_repository.dart';

class PaymentDetailViewModel with ChangeNotifier {
  final PaymentDetailRepository _myRepo = PaymentDetailRepository();
  bool isLoading = false;
  bool isReadOnly = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController bankNameController;
  late TextEditingController accountController;
  late TextEditingController confirmAccountController;
  late TextEditingController branchNameController;
  late TextEditingController ifscController;
  late TextEditingController upiController;
  late TextEditingController phoneController;
  PaymentMethod paymentMethod = PaymentMethod.bank;
  late PaymentDetailModel paymentDetailModel;

  late ApiResponse<PaymentDetailResponse> apiResponse = ApiResponse.initial();

  setResponse(ApiResponse<PaymentDetailResponse> response) => apiResponse = response;

  init() async {
    initialiseFields();
    // await fetchPaymentDetails();
  }

  Future<void> submitPaymentDetails() async {
    // setResponse(ApiResponse.loading());
    updateBody();
    isLoading = true;
    notifyListeners();
    var response = await _myRepo.sendPaymentDetailsApi(paymentDetailModel);
    response.fold(
      (l) {
        // setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        isReadOnly = true;
        Navigator.pop(navigatorKey.currentContext!);
      },
    );
    isLoading = false;
    notifyListeners();
  }

  // Future<void> fetchPaymentDetails() async {
  //   setResponse(ApiResponse.loading());
  //   // updateBody();
  //   // notifyListeners();
  //   var response = await _myRepo.fetchPaymentDetailsApi();
  //   response.fold(
  //     (l) {
  //       setResponse(ApiResponse.error(l.message));
  //       Utils.toastMessage(l.message.toString());
  //     },
  //     (r) async {
  //       setResponse(ApiResponse.completed(r));
  //       // Utils.toastMessage(r.message.toString());
  //       if (r.data != null) {
  //         initialiseFields(update: true, data: r.data);
  //       }
  //     },
  //   );
  //   notifyListeners();
  // }

  updateBody() {
    paymentDetailModel.userId = userId;
    paymentDetailModel.bankName = bankNameController.text;
    paymentDetailModel.bankAccountNumber = accountController.text;
    paymentDetailModel.branchName = branchNameController.text;
    paymentDetailModel.ifsc = ifscController.text;
    paymentDetailModel.upiId = upiController.text;
    paymentDetailModel.defaultMethod = paymentMethod.name;
    paymentDetailModel.paymentMobileNumber = phoneController.text;
  }

  initialiseFields({bool update = false, PaymentDetail? data}) {
    if (update) {
      paymentDetailModel = PaymentDetailModel();
      if (data != null) {
        isReadOnly = true;
        if (data.defaultMethod == null) {
          paymentMethod = PaymentMethod.bank;
        } else {
          if (data.defaultMethod == PaymentMethod.bank.name) {
            paymentMethod = PaymentMethod.bank;
          }
          if (data.defaultMethod == PaymentMethod.upi.name) {
            paymentMethod = PaymentMethod.upi;
          }
          if (data.defaultMethod == PaymentMethod.phone.name) {
            paymentMethod = PaymentMethod.phone;
          }
        }
        bankNameController = TextEditingController(text: data.bankName ?? "");
        branchNameController = TextEditingController(text: data.branchName ?? "");
        accountController = TextEditingController(text: data.bankAccountNumber ?? "");
        ifscController = TextEditingController(text: data.ifsc ?? "");
        upiController = TextEditingController(text: data.upiId ?? "");
        phoneController = TextEditingController(text: data.paymentMobileNumber ?? "");
      }
    } else {
      isReadOnly = false;
      paymentDetailModel = PaymentDetailModel();
      bankNameController = TextEditingController();
      branchNameController = TextEditingController();
      accountController = TextEditingController();
      ifscController = TextEditingController();
      upiController = TextEditingController();
      phoneController = TextEditingController();
    }
  }

  toggleReadOnly({bool value = true}) {
    if (value) {
      isReadOnly = !isReadOnly;
    } else {
      isReadOnly = value;
    }
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod value) {
    paymentMethod = value;
    toggleReadOnly(value: false);
    notifyListeners();
  }
}
