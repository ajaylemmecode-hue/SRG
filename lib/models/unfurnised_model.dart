class UnfurnishedFlat {
  final int id;
  final String title;
  final int price;
  final int comparePrice;
  final String description;
  final String imageUrl;

  UnfurnishedFlat({
    required this.id,
    required this.title,
    required this.price,
    required this.comparePrice,
    required this.description,
    required this.imageUrl,
  });

  factory UnfurnishedFlat.fromJson(Map<String, dynamic> json) {
    return UnfurnishedFlat(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      comparePrice: json['compare_price'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
