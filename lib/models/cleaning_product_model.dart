class CleaningProduct {
  final int id;
  final String title;
  final String description;
  final String? image;

  CleaningProduct({
    required this.id,
    required this.title,
    required this.description,
    this.image,
  });

  factory CleaningProduct.fromJson(Map<String, dynamic> json) {
    return CleaningProduct(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
    );
  }
}
