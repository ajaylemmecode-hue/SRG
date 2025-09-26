class LoginResponse {
  final bool status;
  final String message;
  final String? token;
  final Map<String, dynamic>? data;

  LoginResponse({
    required this.status,
    required this.message,
    this.token,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    String? token;

    if (json['data'] is Map) {
      final data = json['data'] as Map;
      if (data.containsKey('token')) {
        token = data['token'];
      }
    }

    return LoginResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      token: token,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}
