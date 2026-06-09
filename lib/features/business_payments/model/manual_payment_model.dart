class ManualPayment {
  final int id;
  final int userId;
  final int businessId;
  final double billAmount;
  final int pointsRedeemed;
  final double pointsValue;
  final double finalAmount;
  final int? discountPercentage;
  final double? discountAmount;
  final String status;
  final String paymentMethod;
  final DateTime? confirmedAt;
  final DateTime createdAt;
  final String? userName;
  final String? userMobile;
  final String? userImage;
  final String? businessName;
  final String? businessImage;

  ManualPayment({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.billAmount,
    required this.pointsRedeemed,
    required this.pointsValue,
    required this.finalAmount,
    this.discountPercentage,
    this.discountAmount,
    required this.status,
    required this.paymentMethod,
    this.confirmedAt,
    required this.createdAt,
    this.userName,
    this.userMobile,
    this.userImage,
    this.businessName,
    this.businessImage,
  });

  factory ManualPayment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final business = json['business'] as Map<String, dynamic>?;
    return ManualPayment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      billAmount: double.tryParse(json['bill_amount']?.toString() ?? '0') ?? 0,
      pointsRedeemed: json['points_redeemed'] != null
          ? (json['points_redeemed'] is String
              ? (double.tryParse(json['points_redeemed'].toString())?.toInt() ?? 0)
              : (json['points_redeemed'] as num).toInt())
          : 0,
      pointsValue: double.tryParse(json['points_value']?.toString() ?? '0') ?? 0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0,
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] is String
              ? (double.tryParse(json['discount_percentage'])?.toInt() ?? 0)
              : (json['discount_percentage'] as num).toInt())
          : null,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['payment_method'] ?? 'MANUAL',
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      userName: user?['name'],
      userMobile: user?['mobile'],
      userImage: user?['user_image'],
      businessName: business?['business_name'],
      businessImage: business?['business_image'],
    );
  }
}

class ManualPaymentResponse {
  final bool status;
  final List<ManualPayment> data;
  final String? message;
  final int? pointsEarned;

  ManualPaymentResponse({
    required this.status,
    required this.data,
    this.message,
    this.pointsEarned,
  });

  factory ManualPaymentResponse.fromJson(Map<String, dynamic> json) {
    return ManualPaymentResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ManualPayment.fromJson(e))
              .toList() ??
          [],
      message: json['message'],
      pointsEarned: json['points_earned'],
    );
  }
}
