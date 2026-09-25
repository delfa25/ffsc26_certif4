class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
    required this.stock,
  });
}

class ProductsResult {
  final List<Product> products;
  final bool isCached;

  const ProductsResult({
    required this.products,
    required this.isCached,
  });
}
