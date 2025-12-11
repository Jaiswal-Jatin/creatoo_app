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
    // Check if the value is already a complete URL
    if (value.startsWith('http://') || value.startsWith('https://')) {
      qrValue = value;
    } else {
      // Remove leading slash from value if present to avoid double slashes
      final cleanValue = value.startsWith('/') ? value.substring(1) : value;
      qrValue = "$baseUrl$cleanValue";
    }
    print("ScannerViewModel: qrValue set to: $qrValue");
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
      // Validate QR URL
      if (qrValue.isEmpty) {
        print("ScannerViewModel: getImage() - qrValue is empty");
        Utils.snackBar("QR code URL not found.", result: Result.error);
        return null;
      }
      
      print("ScannerViewModel: getImage() - Downloading from: $qrValue");
      
      isDownloading = true;
      notifyListeners();
      
      Dio dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 30);
      dio.options.receiveTimeout = Duration(seconds: 30);

      // Fetch the image bytes from the URL
      Response<ResponseBody> response = await dio.get<ResponseBody>(
        qrValue,
        options: Options(responseType: ResponseType.stream),
      );

      print("ScannerViewModel: getImage() - Response status: ${response.statusCode}");

      // Collect bytes from the response stream
      List<int> imageBytes = [];
      await for (var chunk in response.data!.stream) {
        imageBytes.addAll(chunk);
      }

      print("ScannerViewModel: getImage() - Image bytes received: ${imageBytes.length}");

      if (imageBytes.isEmpty) {
        print("ScannerViewModel: getImage() - No image bytes received");
        Utils.snackBar("Failed to download QR code - no data received.", result: Result.error);
        isDownloading = false;
        notifyListeners();
        return null;
      }

      // Save the image directly to the gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(imageBytes), // Convert to Uint8List
        quality: 100, // High quality
        name: "creatoo_business_qr_${DateTime.now().millisecondsSinceEpoch}", // Unique file name
      );

      print("ScannerViewModel: getImage() - Save result: $result");

      if (result['isSuccess'] == true) {
        print("Image saved successfully to gallery: ${result['filePath']}");

        if (Platform.isAndroid) {
          Utils.snackBar("QR code downloaded and added to gallery.", result: Result.success);
        } else if (Platform.isIOS) {
          Utils.snackBar("QR code added to your Photos app.", result: Result.success);
        }
      } else {
        print("ScannerViewModel: getImage() - Failed to save: ${result['errorMessage'] ?? 'Unknown error'}");
        Utils.snackBar("Failed to save QR code to gallery.", result: Result.error);
      }

      isDownloading = false;
      notifyListeners();

      return null;
    } on DioException catch (e) {
      isDownloading = false;
      notifyListeners();
      print('ScannerViewModel: getImage() - DioException: ${e.type} - ${e.message}');
      print('ScannerViewModel: getImage() - Response: ${e.response?.statusCode} - ${e.response?.data}');
      Utils.snackBar("Failed to download QR code. Please try again.", result: Result.error);
      return null;
    } catch (e) {
      isDownloading = false;
      notifyListeners();
      print('ScannerViewModel: getImage() - Error: $e');
      Utils.snackBar("Failed to download QR code.", result: Result.error);
      return null;
    }
  }

  void clear() {
    notifyListeners();
  }
}
