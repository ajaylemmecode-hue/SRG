class Contact {
  final String firstName;
  final String email;
  final String? mobile;
  final String? address;
  final String? state;
  final String? city;
  final String? service;
  final String? area;
  final String? date;
  final String? time;
  final String? orderInspection;
  final String? message;

  Contact({
    required this.firstName,
    required this.email,
    this.mobile,
    this.address,
    this.state,
    this.city,
    this.service,
    this.area,
    this.date,
    this.time,
    this.orderInspection,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "email": email,
      "mobile": mobile,
      "address": address,
      "state": state,
      "city": city,
      "service": service,
      "area": area,
      "date": date,
      "time": time,
      "order_inspection": orderInspection,
      "message": message,
    };
  }
}

/// Model for GET history
class ContactHistory {
  final String? firstName;
  final String? email;
  final String? mobile;
  final String? address;
  final String? state;
  final String? city;
  final String? service;
  final String? area;
  final String? date;
  final String? time;
  final String? orderInspection;
  final String? message;

  ContactHistory({
    this.firstName,
    this.email,
    this.mobile,
    this.address,
    this.state,
    this.city,
    this.service,
    this.area,
    this.date,
    this.time,
    this.orderInspection,
    this.message,
  });

  factory ContactHistory.fromJson(Map<String, dynamic> json) {
    return ContactHistory(
      firstName: json["first_name"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
      address: json["address"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      service: json["service"] ?? "",
      area: json["area"] ?? "",
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      orderInspection: json["order_inspection"]?.toString(),
      message: json["message"] ?? "",
    );
  }
}
