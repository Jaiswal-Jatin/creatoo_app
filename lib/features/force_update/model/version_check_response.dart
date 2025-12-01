class VersionCheckResponse {
  final bool status;
  final bool needsUpdate;
  final String clientVersion;
  final String latestVersion;
  final String message;

  VersionCheckResponse({
    required this.status,
    required this.needsUpdate,
    required this.clientVersion,
    required this.latestVersion,
    required this.message,
  });

  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponse(
      status: json['status'] ?? false,
      needsUpdate: json['needs_update'] ?? false,
      clientVersion: json['client_version'] ?? '',
      latestVersion: json['latest_version'] ?? '',
      message: json['message'] ?? 'A new update is available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'needs_update': needsUpdate,
      'client_version': clientVersion,
      'latest_version': latestVersion,
      'message': message,
    };
  }
}
