import 'dart:convert';

class ProductModel {
  final int id;
  final String name;
  final double price;
  final String brand;
  final String gender;
  final int menuCategoryId;
  final int? subcategoryId;
  final String mainImageUrl;
  final String mainColor;
  final int otherColorsCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.gender,
    required this.menuCategoryId,
    this.subcategoryId,
    required this.mainImageUrl,
    required this.mainColor,
    required this.otherColorsCount,
  });

  ProductModel copyWith({
    int? id,
    String? name,
    double? price,
    String? brand,
    String? gender,
    int? menuCategoryId,
    int? subcategoryId,
    String? mainImageUrl,
    String? mainColor,
    int? otherColorsCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      gender: gender ?? this.gender,
      menuCategoryId: menuCategoryId ?? this.menuCategoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      mainColor: mainColor ?? this.mainColor,
      otherColorsCount: otherColorsCount ?? this.otherColorsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'gender': gender,
      'menuCategoryId': menuCategoryId,
      'subcategoryId': subcategoryId,
      'mainImageUrl': mainImageUrl,
      'mainColor': mainColor,
      'otherColorsCount': otherColorsCount,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      brand: map['brand'] ?? '',
      gender: map['gender'] ?? '',
      menuCategoryId: map['menu_category_id'] as int,
      subcategoryId: map['subcategory_id'] as int?,
      mainImageUrl: map['main_image_url'] ?? '',
      mainColor: map['main_color'] ?? '',
      otherColorsCount: map['other_colors_count'] as int,
    );
  }

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, brand: $brand, gender: $gender, menuCategoryId: $menuCategoryId, subcategoryId: $subcategoryId, mainImageUrl: $mainImageUrl, mainColor: $mainColor, otherColorsCount: $otherColorsCount)';
  }

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.price == price &&
        other.brand == brand &&
        other.gender == gender &&
        other.menuCategoryId == menuCategoryId &&
        other.subcategoryId == subcategoryId &&
        other.mainImageUrl == mainImageUrl &&
        other.mainColor == mainColor &&
        other.otherColorsCount == otherColorsCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        brand.hashCode ^
        gender.hashCode ^
        menuCategoryId.hashCode ^
        subcategoryId.hashCode ^
        mainImageUrl.hashCode ^
        mainColor.hashCode ^
        otherColorsCount.hashCode;
  }
}
