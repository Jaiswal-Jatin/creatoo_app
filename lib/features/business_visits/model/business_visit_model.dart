class BusinessVisit {
  final int id;
  final int? userId;
  final int cardNumber;
  final String? cardName;
  final String tier;
  final String time;
  final String? userName;
  final String? userImage;
  final String? userMobile;

  BusinessVisit({
    required this.id,
    this.userId,
    required this.cardNumber,
    this.cardName,
    required this.tier,
    required this.time,
    this.userName,
    this.userImage,
    this.userMobile,
  });

  factory BusinessVisit.fromJson(Map<String, dynamic> json) {
    return BusinessVisit(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      cardNumber: json['card_number'] ?? 0,
      cardName: json['card_name'],
      tier: json['tier'] ?? 'new',
      time: json['time'] ?? '',
      userName: json['user_name'],
      userImage: json['user_image'],
      userMobile: json['user_mobile'],
    );
  }
}

class BusinessVisitsResponse {
  final bool status;
  final List<BusinessVisit> data;
  final int total;
  final String? message;

  BusinessVisitsResponse({
    required this.status,
    required this.data,
    required this.total,
    this.message,
  });

  factory BusinessVisitsResponse.fromJson(Map<String, dynamic> json) {
    return BusinessVisitsResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BusinessVisit.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      message: json['message'],
    );
  }
}
