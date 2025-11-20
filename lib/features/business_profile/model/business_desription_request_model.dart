import 'dart:convert';
import 'dart:io';

class BusinessDescriptionRequestModel {
  String? timeFrom;
  String? timeTo;
  String? pricingRangeText;
  int? businessId;
  File? businessImage1;
  File? businessImage2;
  File? businessImage3;
  File? businessImage4;
  File? businessImage5;
  File? menuCard1;
  File? menuCard2;
  File? menuCard3;
  File? menuCard4;
  File? menuCard5;
  String? token;

  BusinessDescriptionRequestModel({
    this.timeFrom,
    this.timeTo,
    this.pricingRangeText,
    this.businessId,
    this.businessImage1,
    this.businessImage2,
    this.businessImage3,
    this.businessImage4,
    this.businessImage5,
    this.menuCard1,
    this.menuCard2,
    this.menuCard3,
    this.menuCard4,
    this.menuCard5,
    this.token,
  });

  /// Factory constructor for JSON deserialization.
  factory BusinessDescriptionRequestModel.fromJson(Map<String, dynamic> json) {
    return BusinessDescriptionRequestModel(
      timeFrom: json["time_from"],
      timeTo: json["time_to"],
      pricingRangeText: json["pricing_range_text"],
      businessId: json["business_id"],
      businessImage1: _fileFromPath(json["business_image_1"]),
      businessImage2: _fileFromPath(json["business_image_2"]),
      businessImage3: _fileFromPath(json["business_image_3"]),
      businessImage4: _fileFromPath(json["business_image_4"]),
      businessImage5: _fileFromPath(json["business_image_5"]),
      menuCard1: _fileFromPath(json["menu_card_1"]),
      menuCard2: _fileFromPath(json["menu_card_2"]),
      menuCard3: _fileFromPath(json["menu_card_3"]),
      menuCard4: _fileFromPath(json["menu_card_4"]),
      menuCard5: _fileFromPath(json["menu_card_5"]),
      token: json["token"],
    );
  }

  /// Convert model to JSON.
  Map<String, dynamic> toJson() {
    return {
      "time_from": timeFrom,
      "time_to": timeTo,
      "pricing_range_text": pricingRangeText,
      "business_id": businessId,
      "business_image_1": _fileToPath(businessImage1),
      "business_image_2": _fileToPath(businessImage2),
      "business_image_3": _fileToPath(businessImage3),
      "business_image_4": _fileToPath(businessImage4),
      "business_image_5": _fileToPath(businessImage5),
      "menu_card_1": _fileToPath(menuCard1),
      "menu_card_2": _fileToPath(menuCard2),
      "menu_card_3": _fileToPath(menuCard3),
      "menu_card_4": _fileToPath(menuCard4),
      "menu_card_5": _fileToPath(menuCard5),
      "token": token,
    };
  }

  /// Convert JSON String to Model.
  factory BusinessDescriptionRequestModel.fromRawJson(String str) => BusinessDescriptionRequestModel.fromJson(json.decode(str));

  /// Convert Model to JSON String.
  String toRawJson() => json.encode(toJson());

  /// Helper method to convert file paths to `File` objects.
  static File? _fileFromPath(String? path) {
    return (path != null && path.isNotEmpty) ? File(path) : null;
  }

  /// Helper method to get file paths from `File` objects.
  static String? _fileToPath(File? file) {
    return file?.path;
  }
}
