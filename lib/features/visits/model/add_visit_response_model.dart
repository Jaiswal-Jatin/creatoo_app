class AddVisitResponse {
  final bool status;
  final String? message;
  final String? tier;
  final Map<String, dynamic>? card;
  final List<dynamic>? visitHistory;

  AddVisitResponse({
    required this.status,
    this.message,
    this.tier,
    this.card,
    this.visitHistory,
  });

  factory AddVisitResponse.fromJson(Map<String, dynamic> json) {
    return AddVisitResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String?,
      tier: json['tier'] as String?,
      card: json['card'] as Map<String, dynamic>?,
      visitHistory: json['visit_history'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'tier': tier,
      'card': card,
      'visit_history': visitHistory,
    };
  }

  @override
  String toString() => 'AddVisitResponse(status: $status, message: $message, tier: $tier)';
}
