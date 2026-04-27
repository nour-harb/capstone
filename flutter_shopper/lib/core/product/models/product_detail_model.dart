import 'color_variant_model.dart';

class ProductDetailModel {
  final int id;
  final String productId;
  final String name;
  final String? description;
  final double price;
  final String brand;
  final String? url;
  final List<ColorVariantModel> colors;
  final bool? favorited;

  ProductDetailModel({
    required this.id,
    required this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.brand,
    this.url,
    required this.colors,
    this.favorited,
  });

  factory ProductDetailModel.fromMap(Map<String, dynamic> map) {
    return ProductDetailModel(
      id: map['id'] as int,
      productId: map['product_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      brand: map['brand'] as String,
      url: map['url'] as String?,
      colors:
          (map['colors'] as List<dynamic>?)
              ?.map((c) => ColorVariantModel.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      favorited: map['favorited'] as bool?,
    );
  }
}
