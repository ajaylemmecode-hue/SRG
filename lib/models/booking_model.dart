import 'package:intl/intl.dart';

class BookingModel {
  int id;
  String serviceName;
  String category;
  DateTime dateTime; // mutable
  String address;
  String? secondaryAddress;
  String customerName;
  double price;
  String status; // mutable

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.dateTime,
    required this.address,
    this.secondaryAddress,
    required this.customerName,
    required this.price,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parse DATE from booking_date (ISO string)
    DateTime datePart;
    try {
      // booking_date: "2025-10-31T00:00:00.000000Z"
      datePart = DateTime.parse(json['booking_date'] ?? '');
    } catch (e) {
      datePart = DateTime.now();
    }

    // ✅ Parse TIME from booking_time ("10:00:00")
    int hour = 0, minute = 0;
    try {
      final timeStr = json['booking_time'] ?? '00:00:00';
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]) ?? 0;
        minute = int.tryParse(parts[1]) ?? 0;
      }
    } catch (e) {
      // keep 00:00
    }

    // ✅ Combine date + time
    final parsedDateTime = DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      hour,
      minute,
    );

    // ✅ Service & Category
    List<dynamic> items = json['items'] ?? [];
    String serviceName = "Service";
    String category = "General";

    if (items.isNotEmpty) {
      final firstItem = items[0] as Map<String, dynamic>?;
      serviceName = firstItem?['name']?.toString() ?? "Service";
      // Optional: infer category from service name or use backend field if available
      category = "Cleaning"; // or use json['category'] if API adds it later
    }

    // ✅ ID
    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else if (json['id'] is String) {
      id = int.tryParse(json['id']) ?? 0;
    }

    // ✅ Address & Customer Name
    // Note: /orders list API does NOT return address or name!
    // But if you enhance backend, or if this comes from /orders/{id}, it may work.
    // For now, use safe fallbacks.
    String address = json['address']?.toString() ?? "Address not available";
    String? secondaryAddress = json['apartment']?.toString();

    String firstName = json['first_name']?.toString() ?? '';
    String lastName = json['last_name']?.toString() ?? '';
    String customerName = (firstName.trim() + ' ' + lastName.trim()).trim();
    if (customerName.isEmpty) customerName = "You";

    // ✅ Price
    double price = 0.0;
    if (json['grand_total'] != null) {
      price = (json['grand_total'] is num)
          ? (json['grand_total'] as num).toDouble()
          : double.tryParse(json['grand_total'].toString()) ?? 0.0;
    }

    // ✅ Status mapping
    String rawStatus = (json['status'] as String?)?.toLowerCase() ?? "pending";
    String status = getStatusFromApi(rawStatus);

    return BookingModel(
      id: id,
      serviceName: serviceName,
      category: category,
      dateTime: parsedDateTime,
      address: address,
      secondaryAddress: secondaryAddress,
      customerName: customerName,
      price: price,
      status: status,
    );
  }

  static String getStatusFromApi(String apiStatus) {
    switch (apiStatus) {
      case 'confirmed':
      case 'booked':
      case 'pending':
      case 'processing':
        return "Confirmed";
      case 'completed':
      case 'delivered':
        return "Completed";
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return "Cancelled";
      default:
        return "Confirmed";
    }
  }

  BookingModel copyWith({
    int? id,
    String? serviceName,
    String? category,
    DateTime? dateTime,
    String? address,
    String? secondaryAddress,
    String? customerName,
    double? price,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      secondaryAddress: secondaryAddress ?? this.secondaryAddress,
      customerName: customerName ?? this.customerName,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}