import 'package:flutter_shopper/core/product/models/filter_item.dart';

class VariantDetailModel {
  final int id;
  final FilterItem size;
  final double price;
  final String availability;

  VariantDetailModel({
    required this.id,
    required this.size,
    required this.price,
    required this.availability,
  });

  factory VariantDetailModel.fromMap(Map<String, dynamic> map) {
    return VariantDetailModel(
      id: map['id'] as int,
      size: FilterItem.fromMap(map['size'] as Map<String, dynamic>),
      // using .toDouble() to safely handle int or double from JSON
      price: (map['price'] as num).toDouble(),
      availability: map['availability'] as String,
    );
  }
}
