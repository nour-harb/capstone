import 'dart:convert';
import 'package:flutter_shopper/core/product/models/base_product_query.dart';

class CategoryProductQuery extends BaseProductQuery {
  final int menuCategoryId;
  final int? subcategoryId;

  CategoryProductQuery({
    required this.menuCategoryId,
    this.subcategoryId,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sizeIds,
    super.colorIds,
    super.brandIds,
  });

  @override
  CategoryProductQuery copyWith({
    int? menuCategoryId,
    int? subcategoryId,
    int? page,
    int? pageSize,
    String? sortBy,
    List<int>? sizeIds,
    List<int>? colorIds,
    List<int>? brandIds,
  }) {
    return CategoryProductQuery(
      menuCategoryId: menuCategoryId ?? this.menuCategoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sizeIds: sizeIds ?? this.sizeIds,
      colorIds: colorIds ?? this.colorIds,
      brandIds: brandIds ?? this.brandIds,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'menu_category_id': menuCategoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
    });

    return map;
  }

  factory CategoryProductQuery.fromMap(Map<String, dynamic> map) {
    return CategoryProductQuery(
      menuCategoryId: map['menu_category_id'] as int,
      subcategoryId: map['subcategory_id'] as int?,
      page: map['page'] as int? ?? 1,
      pageSize: map['page_size'] as int? ?? 20,
      sortBy: map['sort_by'] as String? ?? 'newest',
      sizeIds: List<int>.from(map['size_ids'] ?? []),
      colorIds: List<int>.from(map['color_ids'] ?? []),
      brandIds: List<int>.from(map['brand_ids'] ?? []),
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory CategoryProductQuery.fromJson(String source) =>
      CategoryProductQuery.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant CategoryProductQuery other) {
    if (identical(this, other)) return true;
    return super == other &&
        other.menuCategoryId == menuCategoryId &&
        other.subcategoryId == subcategoryId;
  }

  @override
  int get hashCode {
    return super.hashCode ^ menuCategoryId.hashCode ^ subcategoryId.hashCode;
  }
}
