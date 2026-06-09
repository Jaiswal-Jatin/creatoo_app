import 'manual_payment_model.dart';

class BusinessPaymentStatsResponse {
  final bool status;
  final BusinessPaymentStatsData? data;

  BusinessPaymentStatsResponse({required this.status, this.data});

  factory BusinessPaymentStatsResponse.fromJson(Map<String, dynamic> json) {
    return BusinessPaymentStatsResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? BusinessPaymentStatsData.fromJson(json['data']) : null,
    );
  }
}

class BusinessPaymentStatsData {
  final double dailyTotal;
  final double monthlyTotal;
  final List<ManualPayment> recentPayments;

  BusinessPaymentStatsData({
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.recentPayments,
  });

  factory BusinessPaymentStatsData.fromJson(Map<String, dynamic> json) {
    return BusinessPaymentStatsData(
      dailyTotal: (json['daily_total'] ?? 0).toDouble(),
      monthlyTotal: (json['monthly_total'] ?? 0).toDouble(),
      recentPayments: (json['recent_payments'] as List<dynamic>?)
              ?.map((e) => ManualPayment.fromJson(e))
              .toList() ??
          [],
    );
  }
}
