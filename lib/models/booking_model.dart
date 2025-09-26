class BookingModel {
  final String id;
  final String serviceName;
  final String category;
  final DateTime dateTime; // ✅ store DateTime
  final String address; // Primary Address
  final String? secondaryAddress; // ✅ Optional Secondary Address
  final String customerName;
  final int price;
  final String status;

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.dateTime,
    required this.address,
    this.secondaryAddress, // ✅ optional
    required this.customerName,
    required this.price,
    required this.status,
  });

  BookingModel copyWith({
    String? id,
    String? serviceName,
    String? category,
    DateTime? dateTime,
    String? address,
    String? secondaryAddress,
    String? customerName,
    int? price,
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
