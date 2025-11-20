import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../../../core.dart';
import '../model/scanner_model_response.dart';
import '../model/setting_request_model.dart';
import '../repository/scanner_repository.dart';

class ScannerViewModel with ChangeNotifier {
  final ScannerRepository _scannerRepository = ScannerRepository();

  final formKey = GlobalKey<FormState>();
  TextEditingController discountController = TextEditingController();
  TextEditingController minOrderController = TextEditingController();
  TextEditingController expDateController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  // MobileScannerController _controller = MobileScannerController();
  late BusinessSettings businessSettings;

  String? selectedValue;
  bool showTextField = false;
  String qrValue = "";
  bool isModified = false;
  bool isDownloading = false;

  ApiResponse<ScannerModelResponse> scannerResponse = ApiResponse.initial();
  setResponse(ApiResponse<ScannerModelResponse> response) => scannerResponse = response;

  init(String value) async {
    qrValue = "$baseUrl$value";
    // expDateController = TextEditingController(text: selectedValue);
    // businessSettings = BusinessSettings();
    // await fetchBusinessSettings();
  }

  void onDropdownChangeExpiry(String value) {
    selectedValue = value;
    if (selectedValue == "Custom") {
      expDateController.clear();
      showTextField = true;
    }
    checkIfModified();
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  setValues() async {
    if (scannerResponse.data?.data?.setDiscount != null) {
      var data = scannerResponse.data!.data!;
      discountController = TextEditingController(text: data.setDiscount.toString());
      minOrderController = TextEditingController(text: data.minOrder.toString());

      if (data.setExpiry == 15 || data.setExpiry == 30 || data.setExpiry == 360) {
        selectedValue = data.setExpiry.toString();
        showTextField = false;
        expDateController = TextEditingController();
      } else {
        showTextField = true;
        expDateController = TextEditingController(text: data.setExpiry.toString());
        selectedValue = "Custom";
      }

      noteController = TextEditingController(text: data.note ?? '');

      businessSettings = BusinessSettings(
        businessId: userId,
        setDiscount: int.parse(discountController.text),
        minOrder: int.parse(minOrderController.text),
        setExpiry: selectedValue == "Custom" ? int.parse(expDateController.text) ?? 0 : int.parse(selectedValue!),
        note: noteController.text,
      );
    }

    notifyListeners();
  }

  // Method to check if any value has been modified
  checkIfModified() {
    if (discountController.text != businessSettings.setDiscount.toString() ||
        minOrderController.text != businessSettings.minOrder.toString() ||
        noteController.text != businessSettings.note ||
        (selectedValue != "Custom" && selectedValue != businessSettings.setExpiry.toString()) ||
        (selectedValue == "Custom" && expDateController.text != businessSettings.setExpiry.toString())) {
      isModified = true;
    } else {
      isModified = false;
    }
    notifyListeners();
  }

  Future<void> updateBusinessSetting() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    businessSettings = BusinessSettings(
      businessId: userId,
      setDiscount: int.parse(discountController.text),
      minOrder: int.parse(minOrderController.text),
      setExpiry: selectedValue == "Custom" ? int.parse(expDateController.text) ?? 0 : int.parse(selectedValue!),
      note: noteController.text,
    );

    final Either<AppException, ScannerModelResponse> response =
        await _scannerRepository.updateBusinessSettingApi(businessSettings.toJson());
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) {
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        setValues();
      },
    );
    notifyListeners();
  }

  Future<void> fetchBusinessSettings() async {
    setResponse(ApiResponse.loading());
    Map<String, dynamic> body = {
      "business_id": userId,
    };
    final Either<AppException, ScannerModelResponse> response = await _scannerRepository.getBusinessSettingApi(body);

    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message);
      },
      (r) {
        setResponse(ApiResponse.completed(r));
        setValues();
      },
    );
    notifyListeners();
  }

  Future<File?> getImage() async {
    try {
      isDownloading = true;
      notifyListeners();
      Dio dio = Dio();

      // Fetch the image bytes from the URL
      Response<ResponseBody> response = await dio.get<ResponseBody>(
        qrValue,
        options: Options(responseType: ResponseType.stream),
      );

      // Collect bytes from the response stream
      List<int> imageBytes = [];
      await for (var chunk in response.data!.stream) {
        imageBytes.addAll(chunk);
      }

      // Save the image directly to the gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(imageBytes), // Convert to Uint8List
        quality: 100, // High quality
        name: "creatoo_business_qr", // Custom file name
      );

      if (result['isSuccess']) {
        print("Image saved successfully to gallery: ${result['filePath']}");

        if (Platform.isAndroid) {
          Utils.snackBar("QR code downloaded and added to gallery.", result: Result.success);
        } else if (Platform.isIOS) {
          Utils.snackBar("QR code added to your Photos app.", result: Result.success);
        }
      } else {
        Utils.snackBar("Failed to save QR code to gallery.", result: Result.error);
      }

      isDownloading = false;
      notifyListeners();

      return null;
    } catch (e) {
      isDownloading = false;
      notifyListeners();
      print('Error downloading image: $e');
      Utils.snackBar("Failed to download QR code.", result: Result.error);
      return null;
    }
  }

  void clear() {
    notifyListeners();
  }
}
