/// Distributor product model.
///
/// Maps to the Supabase `products` table with a join on `categories`.
library;

class DistributorProduct {
  final String id;
  final String name;
  final String? barcode;
  final String category;
  final double price;
  final int stock;
  final DateTime? updatedAt;

  const DistributorProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.category,
    required this.price,
    required this.stock,
    this.updatedAt,
  });

  factory DistributorProduct.fromJson(Map<String, dynamic> json) {
    final categoryName = json['categories'] is Map
        ? (json['categories']['name'] as String? ?? '')
        : (json['category_name'] as String? ?? '');

    return DistributorProduct(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      barcode: json['barcode'] as String?,
      category: categoryName,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistributorProduct &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          barcode == other.barcode &&
          category == other.category &&
          price == other.price &&
          stock == other.stock;

  @override
  int get hashCode => Object.hash(id, name, barcode, category, price, stock);
}
