class ForgotModel {
  final bool status;
  final String message;
  final Map<String, dynamic>? errors;

  ForgotModel({required this.status, required this.message, this.errors});

  factory ForgotModel.fromJson(Map<String, dynamic> json) {
    return ForgotModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'],
    );
  }
}
