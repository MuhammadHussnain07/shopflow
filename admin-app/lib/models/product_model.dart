class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final double rating;
  final int stock;
  final String description;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
    required this.stock,
    required this.description,
    required this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'category': category,
    'rating': rating,
    'stock': stock,
    'description': description,
    'imageUrl': imageUrl,
  };
}
