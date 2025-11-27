// lib/models/wishlist_model.dart

class WishlistItem {
  final int id;
  final String title;
  final double price;
  final double? comparePrice;
  final String imageUrl;
  final DateTime addedAt;
  final Map<String, dynamic>? productData; // Store full product data if needed

  WishlistItem({
    required this.id,
    required this.title,
    required this.price,
    this.comparePrice,
    required this.imageUrl,
    required this.addedAt,
    this.productData,
  });

  /// Create WishlistItem from JSON response
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures from API
    final productJson = json['product'] ?? json;

    return WishlistItem(
      id: _parseId(productJson['id']),
      title: _parseString(productJson['title'] ?? productJson['name'] ?? 'Unnamed Product'),
      price: _parsePrice(productJson['price']),
      comparePrice: _parsePrice(productJson['compare_price'] ?? productJson['compare_at_price']),
      imageUrl: _parseImageUrl(productJson['image_url'] ?? productJson['image'] ?? productJson['thumbnail']),
      addedAt: _parseDateTime(json['added_to_wishlist_at'] ?? json['created_at']),
      productData: productJson,
    );
  }

  /// Convert WishlistItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'compare_price': comparePrice,
      'image_url': imageUrl,
      'added_to_wishlist_at': addedAt.toIso8601String(),
      'product': productData,
    };
  }

  /// Check if item has discount
  bool get hasDiscount => comparePrice != null && comparePrice! > price;

  /// Calculate discount percentage
  int? get discountPercentage {
    if (!hasDiscount) return null;
    return (((comparePrice! - price) / comparePrice!) * 100).round();
  }

  /// Get full image URL (handles relative paths)
  String get fullImageUrl {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    const baseUrl = 'https://portfolio2.lemmecode.in';
    final cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$baseUrl$cleanPath';
  }

  /// Create a copy with updated fields
  WishlistItem copyWith({
    int? id,
    String? title,
    double? price,
    double? comparePrice,
    String? imageUrl,
    DateTime? addedAt,
    Map<String, dynamic>? productData,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      comparePrice: comparePrice ?? this.comparePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
      productData: productData ?? this.productData,
    );
  }

  // ========== Helper Methods ==========

  /// Safely parse ID from dynamic value
  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Safely parse string from dynamic value
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Safely parse price from dynamic value
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove currency symbols and commas
      final cleanValue = value.replaceAll(RegExp(r'[₹$,\s]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Safely parse image URL from dynamic value
  static String _parseImageUrl(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Safely parse DateTime from dynamic value
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  @override
  String toString() {
    return 'WishlistItem(id: $id, title: $title, price: $price, comparePrice: $comparePrice, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ========== Extension for List<WishlistItem> ==========

extension WishlistItemListExtension on List<WishlistItem> {
  /// Get total count
  int get totalCount => length;

  /// Get total value of all items
  double get totalValue => fold(0.0, (sum, item) => sum + item.price);

  /// Get total potential savings
  double get totalSavings {
    return fold(0.0, (sum, item) {
      if (item.hasDiscount) {
        return sum + (item.comparePrice! - item.price);
      }
      return sum;
    });
  }

  /// Filter items with discount
  List<WishlistItem> get discountedItems {
    return where((item) => item.hasDiscount).toList();
  }

  /// Sort by price (ascending)
  List<WishlistItem> get sortedByPrice {
    final list = List<WishlistItem>.from(this);
    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  /// Sort by date added (newest first)
  List<WishlistItem> get sortedByDate {
    final list = List<WishlistItem>.from(this);
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  /// Find item by ID
  WishlistItem? findById(int id) {
    try {
      return firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if item exists by ID
  bool containsId(int id) => any((item) => item.id == id);
}