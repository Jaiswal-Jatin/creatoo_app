import 'package:creatoo/features/business_profile/model/business_description_response_model.dart';
import 'package:creatoo/features/business_profile/model/business_desription_request_model.dart';
import 'package:creatoo/features/business_profile/model/set_discount_request_model.dart';
import 'package:creatoo/features/business_profile/model/set_discount_response_model.dart';
import 'package:creatoo/features/creator_profile/repository/creator_profile_repository.dart';
import 'package:creatoo/features/register_business/model/register_business_model.dart';

import '../../../core.dart';
import '../model/business_profile_response.dart';

class BusinessProfileRepository extends CreatorProfileRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<Either<AppException, BusinessProfileResponse>> fetchBusinessProfileApi(body) async {
    return await _apiServices.callPostAPI(
      AppUrl.viewProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseBusinessProfileResponse,
      body: body,
    );
  }

  Future<Either<AppException, BusinessProfileResponse>> updateBusinessProfileApi(RegisterBusinessModel body) async {
    return await _apiServices.callPostAPIForm(
      AppUrl.editBusinessProfile,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseUpdateBusinessProfileResponse,
      body: body.toJson(),
      path: body.businessImage ?? "",
      imageFieldName: "business_image",
    );
  }

  Future<Either<AppException, BusinessDescriptionResponseModel>> updateBusinessDescriptionApi(BusinessDescriptionRequestModel body) async {
    return await _apiServices.callPostAPI(
      AppUrl.editBusinessDescription,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSetBusinessDescriptionResponse,
      body: body.toJson(),
    );
  }

  Future<Either<AppException, SetDiscountResponseModel>> updateBusinessDiscountApi(SetDiscountRequestModel body) async {
    return await _apiServices.callPostAPI(
      AppUrl.editBusinessDiscount,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseSetDiscountResponse,
      body: body.toJson(),
    );
  }

  Future<Either<AppException, BusinessDescriptionResponseModel>> uploadBusinessOrMenuImages({
    required bool isMenu,
    File? image1,
    File? image2,
    File? image3,
    File? image4,
    File? image5,
    File? image,
    required int businessId,
  }) async {
    List<Map<String, String>> imageFiles = [];

    if (!isMenu && image != null) {
      imageFiles.add({
        "fieldName": "business_image",
        "filePath": image.path,
      });
    }

    String fieldName = (isMenu) ? "menu_card_" : "business_image_";
    if (image1 != null) {
      imageFiles.add({
        "fieldName": "$fieldName" + "1",
        "filePath": image1.path,
      });
    }
    if (image2 != null) {
      imageFiles.add({
        "fieldName": "$fieldName" + "2",
        "filePath": image2.path,
      });
    }
    if (image3 != null) {
      imageFiles.add({
        "fieldName": "$fieldName" + "3",
        "filePath": image3.path,
      });
    }
    if (image4 != null) {
      imageFiles.add({
        "fieldName": "$fieldName" + "4",
        "filePath": image4.path,
      });
    }
    if (image5 != null) {
      imageFiles.add({
        "fieldName": "$fieldName" + "5",
        "filePath": image5.path,
      });
    }

    print(imageFiles);

    return await _apiServices.callPostAPIFormMultipleFiles(
      AppUrl.editBusinessDescription,
      {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
      Parser.parseSetBusinessDescriptionResponse,
      body: {"business_id": businessId, "token": token},
      filePaths: imageFiles,
    );
  }
}
