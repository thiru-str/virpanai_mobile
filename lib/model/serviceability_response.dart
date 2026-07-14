class ServiceabilityResponse {
  final bool serviceable;
  final String message;

  ServiceabilityResponse({
    required this.serviceable,
    required this.message,
  });

  factory ServiceabilityResponse.fromJson(Map<String, dynamic> json) {
    return ServiceabilityResponse(
      serviceable: json['serviceable'] != false,
      message: json['message']?.toString() ?? '',
    );
  }
}

