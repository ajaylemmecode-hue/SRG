// lib/models/furnished_model.dart
class FurnishedFlat {
  final int id;
  final String title;
  final double price;
  final double comparePrice;
  final String? shortDescription;
  final String description;
  final String imageUrl;
  final int categoryId;
  final int subCategoryId;
  final int status;
  final bool inWishlist;

  FurnishedFlat({
    required this.id,
    required this.title,
    required this.price,
    required this.comparePrice,
    this.shortDescription,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.subCategoryId,
    required this.status,
    required this.inWishlist,
  });

  factory FurnishedFlat.fromJson(Map<String, dynamic> json) {
    return FurnishedFlat(
      id: json['id'],
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      comparePrice: (json['compare_price'] as num?)?.toDouble() ?? 0,
      shortDescription: json['short_description'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      status: json['status'],
      inWishlist: json['in_wishlist'] ?? false,
    );
  }
}
