class BookingBusiness {
  final int id;
  final String? businessName;
  final String? businessImage;
  final String? businessCategory;

  BookingBusiness({
    required this.id,
    this.businessName,
    this.businessImage,
    this.businessCategory,
  });

  factory BookingBusiness.fromJson(Map<String, dynamic> json) {
    return BookingBusiness(
      id: json['id'] ?? 0,
      businessName: json['business_name'],
      businessImage: json['business_image'],
      businessCategory: json['business_category'],
    );
  }
}

class BookingUser {
  final int id;
  final String? name;
  final String? mobile;
  final String? userImage;

  BookingUser({
    required this.id,
    this.name,
    this.mobile,
    this.userImage,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      id: json['id'] ?? 0,
      name: json['name'],
      mobile: json['mobile'],
      userImage: json['user_image'],
    );
  }
}

class BookingModel {
  final int id;
  final int userId;
  final int businessId;
  final String businessCategory;
  final String bookingDate;
  final String bookingTime;
  final int? guestsCount;
  final String? serviceName;
  final String? sportName;
  final String? notes;
  final String status; // pending | accepted | rejected | cancelled
  final String? rejectionReason;
  final String? createdAt;

  // ─── Advance Payment Fields ───
  final double? advanceAmount;
  final String advancePaymentStatus; // none | pending | paid | failed
  final String? razorpayOrderId;
  final bool isBookingActive;
  final String? advancePaymentAt;

  // Populated from join
  final BookingBusiness? business;
  final BookingUser? user;

  BookingModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.businessCategory,
    required this.bookingDate,
    required this.bookingTime,
    this.guestsCount,
    this.serviceName,
    this.sportName,
    this.notes,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.advanceAmount,
    this.advancePaymentStatus = 'none',
    this.razorpayOrderId,
    this.isBookingActive = false,
    this.advancePaymentAt,
    this.business,
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      businessCategory: json['business_category'] ?? 'restaurant',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      guestsCount: json['guests_count'],
      serviceName: json['service_name'],
      sportName: json['sport_name'],
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      advanceAmount: json['advance_amount'] != null
          ? double.tryParse(json['advance_amount'].toString())
          : null,
      advancePaymentStatus: json['advance_payment_status'] ?? 'none',
      razorpayOrderId: json['razorpay_order_id'],
      isBookingActive: json['is_booking_active'] == true || json['is_booking_active'] == 1,
      advancePaymentAt: json['advance_payment_at'],
      business: json['business'] != null
          ? BookingBusiness.fromJson(json['business'])
          : null,
      user: json['user'] != null ? BookingUser.fromJson(json['user']) : null,
    );
  }

  /// Returns true if this booking requires advance payment that is still pending
  bool get needsAdvancePayment =>
      advancePaymentStatus == 'pending' && advanceAmount != null && advanceAmount! > 0;

  /// Returns true if this booking is accepted and either no advance or advance already paid
  bool get isFullyConfirmed =>
      status == 'accepted' && isBookingActive;
}

class BookingListResponse {
  final bool status;
  final String message;
  final List<BookingModel> data;

  BookingListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BookingModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BookingCreateResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  BookingCreateResponse({required this.status, required this.message, this.data});

  factory BookingCreateResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}

/// Response from GET /setting/advance-payment/public
class AdvancePaymentSettings {
  final double platformFee;
  final double gstPercent;

  AdvancePaymentSettings({required this.platformFee, required this.gstPercent});

  factory AdvancePaymentSettings.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return AdvancePaymentSettings(
      platformFee: double.tryParse((d?['advance_platform_fee'] ?? '10').toString()) ?? 10,
      gstPercent: double.tryParse((d?['advance_gst_percent'] ?? '18').toString()) ?? 18,
    );
  }
}

/// Response from POST /booking/create-advance-order
class AdvanceOrderResponse {
  final bool status;
  final String message;
  final String? razorpayOrderId;
  final double? amount;
  final double? advanceBase;
  final double? gst;
  final double? gstPercent;
  final double? platformFee;
  final String? keyId;
  final int? bookingId;

  AdvanceOrderResponse({
    required this.status,
    required this.message,
    this.razorpayOrderId,
    this.amount,
    this.advanceBase,
    this.gst,
    this.gstPercent,
    this.platformFee,
    this.keyId,
    this.bookingId,
  });

  factory AdvanceOrderResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>?;
    return AdvanceOrderResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      razorpayOrderId: d?['razorpay_order_id'],
      amount: d?['amount'] != null ? double.tryParse(d!['amount'].toString()) : null,
      advanceBase: d?['advance_base'] != null ? double.tryParse(d!['advance_base'].toString()) : null,
      gst: d?['gst'] != null ? double.tryParse(d!['gst'].toString()) : null,
      gstPercent: d?['gst_percent'] != null ? double.tryParse(d!['gst_percent'].toString()) : null,
      platformFee: d?['platform_fee'] != null ? double.tryParse(d!['platform_fee'].toString()) : null,
      keyId: d?['key_id'],
      bookingId: d?['booking_id'],
    );
  }
}
