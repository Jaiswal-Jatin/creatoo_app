import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value);
  return null;
}

class SearchBusinessResponse {
  bool? status;
  String? message;
  List<BusinessSearchData>? data;
  Pagination? pagination;

  SearchBusinessResponse({
    this.status,
    this.message,
    this.data,
    this.pagination,
  });

  factory SearchBusinessResponse.fromRawJson(String str) =>
      SearchBusinessResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SearchBusinessResponse.fromJson(Map<String, dynamic> json) =>
      SearchBusinessResponse(
        status: json["status"],
        message: json["message"]?.toString(), // Ensure message is a String
        data: json["data"] == null
            ? []
            : List<BusinessSearchData>.from(
                json["data"]!.map((x) => BusinessSearchData.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class BusinessSearchData {
  int? id;
  String? businessFullname;
  String? businessName;
  String? businessEmail;
  String? businessMobile;
  String? businessArea;
  String? businessSiteUrl;
  String? businessImage;
  int? isActive;
  int? roleId;
  String? pricingRangeText;
  String? avgExperience;
  int? set_first_time_discount;
  int? set_regular_discount;
  String? businessCategory;

  BusinessSearchData(
      {this.id,
      this.businessFullname,
      this.businessName,
      this.businessEmail,
      this.businessMobile,
      this.businessArea,
      this.businessSiteUrl,
      this.businessImage,
      this.isActive,
      this.roleId,
      this.pricingRangeText,
      this.avgExperience,
      this.set_first_time_discount,
      this.set_regular_discount,
      this.businessCategory});

  factory BusinessSearchData.fromRawJson(String str) =>
      BusinessSearchData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BusinessSearchData.fromJson(Map<String, dynamic> json) =>
      BusinessSearchData(
          id: _toInt(json["id"]),
          businessFullname: json["business_fullname"]?.toString(),
          businessName: json["business_name"]?.toString(),
          businessEmail: json["business_email"]?.toString(),
          businessMobile: json["business_mobile"]?.toString(),
          businessArea: json["business_area"]?.toString(),
          businessSiteUrl: json["business_site_url"]?.toString(),
          businessImage: json["business_image"]?.toString(),
          isActive: _toInt(json["is_active"]),
          roleId: _toInt(json["role_id"]),
          pricingRangeText: json["pricing_range_text"]?.toString(),
          avgExperience: json["avg_experience"]?.toString(),
          set_first_time_discount: _toInt(json["set_first_time_discount"]),
          set_regular_discount: _toInt(json["set_regular_discount"]),
          businessCategory: json["business_category"]?.toString());

  Map<String, dynamic> toJson() => {
        "id": id,
        "business_fullname": businessFullname,
        "business_name": businessName,
        "business_email": businessEmail,
        "business_mobile": businessMobile,
        "business_area": businessArea,
        "business_site_url": businessSiteUrl,
        "business_image": businessImage,
        "is_active": isActive,
        "role_id": roleId,
        "pricing_range_text": pricingRangeText,
        "avg_experience": avgExperience,
        "set_first_time_discount": set_first_time_discount,
        "set_regular_discount": set_regular_discount,
        "business_category": businessCategory
      };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory Pagination.fromRawJson(String str) =>
      Pagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: _toInt(json["current_page"]),
        lastPage: _toInt(json["last_page"]),
        perPage: _toInt(json["per_page"]),
        total: _toInt(json["total"]),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "last_page": lastPage,
        "per_page": perPage,
        "total": total,
      };
}
