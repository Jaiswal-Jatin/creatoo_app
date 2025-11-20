import 'dart:convert';

class PaymentModel {
  int? userId;
  int? postId;
  String? paymentStatus;
  String? paymentStatusResponse;
  String? token;

  PaymentModel({
    this.userId,
    this.postId,
    this.paymentStatus,
    this.paymentStatusResponse,
    this.token,
  });

  factory PaymentModel.fromRawJson(String str) => PaymentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    userId: json["user_id"],
    postId: json["post_id"],
    paymentStatus: json["payment_status"],
    paymentStatusResponse: json["payment_status_response"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "post_id": postId,
    "payment_status": paymentStatus,
    "payment_status_response": paymentStatusResponse,
    "token": token,
  };
}
