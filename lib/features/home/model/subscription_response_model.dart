class SubscriptionResponse {
  Subscription? subscription;

  SubscriptionResponse({this.subscription});

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription': subscription?.toJson(),
    };
  }
}

class Subscription {
  String? id;
  String? planName;
  String? status;
  String? expiryDate;

  Subscription({
    this.id,
    this.planName,
    this.status,
    this.expiryDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id']?.toString(),
      planName: json['plan_name']?.toString(),
      status: json['status']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'status': status,
      'expiry_date': expiryDate,
    };
  }
}
