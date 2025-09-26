class RegisterResponse {
  final bool status;
  final String message;
  final String? token;
  final Map<String, dynamic>? data;

  RegisterResponse({
    required this.status,
    required this.message,
    this.token,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // token may be at root or inside data, adapt
    String? token;
    if (json.containsKey('token')) token = json['token'];
    if (json['data'] is Map && (json['data'] as Map).containsKey('token')) {
      token = (json['data'] as Map)['token'];
    }

    return RegisterResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      token: token,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}
