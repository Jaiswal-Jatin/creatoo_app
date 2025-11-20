import 'package:creatoo/core.dart';
import 'package:creatoo/features/add_post/model/add_post_model.dart';
import 'package:creatoo/features/add_post_payment_summary/model/add_post_response_model.dart';
import 'package:creatoo/features/add_post_payment_summary/model/setting_response_model.dart';
import 'package:creatoo/features/add_post_payment_summary/repository/add_post_payment_summary_repository.dart';

import '../model/payment_model.dart';
import '../model/payment_response_model.dart';

class AddPostSummaryViewModel with ChangeNotifier {
  final AddPostPaymentSummaryRepository _myRepo = AddPostPaymentSummaryRepository();
  // late RazorpayService razorpayService;
  late AddPostResponse data;
  late AddPostModel model;
  String? token;
  bool isLoading = false;

  ApiResponse<SettingResponse> settingResponse = ApiResponse.initial();

  setSettingResponse(ApiResponse<SettingResponse> response) {
    settingResponse = response;
  }

  ApiResponse<PaymentResponse> paymentResponse = ApiResponse.loading();

  setResponse(ApiResponse<PaymentResponse> response) {
    paymentResponse = response;
  }

  init(AddPostModel addPostModel) async {
    model = addPostModel;
    await getSettings();
    // razorpayService = RazorpayService(handlePaymentSuccess, handlePaymentError);
    // base64AppLogo = await Utils.convertBase64Image(Images.appLogo);
  }

  makePayment() async {
    isLoading = true;
    Navigator.pushNamed(navigatorKey.currentContext!, RoutesName.loading);
    await addPost();
    isLoading = false;
    notifyListeners();
  }

  void startPayment(Post post) async {
    // razorpayService.openCheckout(
    //   amount: post.totalAmount!,
    //   orderId: post.orderId!,
    //   companyName: Constants.appName,
    //   paymentDescription: post.name!,
    //   contact: user!.mobile!,
    //   email: user!.email ?? "",
    //   logo: "https://portal.creatoo.co.in/assets/images/creatoo_logo.png",
    // ); // Replace with actual amount
    notifyListeners();
  }

  Future<void> addPost() async {
    // setResponse(ApiResponse.loading());
    notifyListeners();
    var response = await _myRepo.addPostApi(model.toJson());
    response.fold(
      (l) {
        Navigator.pop(navigatorKey.currentContext!);
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        // setResponse(ApiResponse.completed(data));
        // AddPostResponseModel postResponse = data as AddPostResponseModel;
        data = r.data!;
        // Utils.toastMessage(r.message.toString());
        startPayment(data.post!);
      },
    );
    notifyListeners();
  }
  //
  // //Razor pay Payment service code
  // void handlePaymentSuccess(PaymentSuccessResponse paymentSuccessResponse) async {
  //   PaymentModel model = PaymentModel(
  //     postId: data.post!.id!,
  //     userId: data.post!.userId!,
  //     token: token,
  //     paymentStatus: PaymentStatus.success.name,
  //     paymentStatusResponse: "${paymentSuccessResponse.data}",
  //   );
  //
  //   await addPostPaymentStatus(model);
  //   Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);
  // }
  //
  // void handlePaymentError(PaymentFailureResponse paymentFailureResponse) async {
  //   // Payment error logic
  //   print('Payment Error : ${paymentFailureResponse.error}');
  //   PaymentModel model = PaymentModel(
  //     postId: data.post!.id!,
  //     userId: data.post!.userId!,
  //     token: token,
  //     paymentStatus: PaymentStatus.failed.name,
  //     paymentStatusResponse: "${paymentFailureResponse.error}",
  //   );
  //   await addPostPaymentStatus(model); //update failure status in db
  //   Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);
  // }

  Future<void> addPostPaymentStatus(PaymentModel model) async {
    disposeData();
    notifyListeners();
    var response = await _myRepo.addPostPaymentStatusApi(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
      },
    );
    notifyListeners();
  }

  Future<void> getSettings() async {
    setSettingResponse(ApiResponse.loading());
    var response = await _myRepo.settingApi({"user_id": model.userId});
    response.fold(
      (l) {
        setSettingResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setSettingResponse(ApiResponse.completed(r));
        model.setting = settingResponse.data!.data;
        // Utils.toastMessage(r.message.toString());
      },
    );
    notifyListeners();
  }

  void disposeData() {
    // razorpayService.dispose();
  }
}
