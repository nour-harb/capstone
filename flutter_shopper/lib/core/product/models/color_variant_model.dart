import 'package:flutter_shopper/core/product/models/variant_detail_model.dart';

class ColorVariantModel {
  final int id; // productColor.id
  final String name;
  final List<String> images;
  final List<VariantDetailModel> variants;

  ColorVariantModel({
    required this.id,
    required this.name,
    required this.images,
    required this.variants,
  });

  factory ColorVariantModel.fromMap(Map<String, dynamic> map) {
    return ColorVariantModel(
      id: map['id'] as int,
      name: map['name'] as String,
      images:
          (map['images'] as List<dynamic>?)
              ?.map((img) => img['url'] as String)
              .toList() ??
          [],
      variants:
          (map['variants'] as List<dynamic>?)
              ?.map(
                (v) => VariantDetailModel.fromMap(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
