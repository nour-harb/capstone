import 'package:flutter_shopper/core/product/models/base_product_query.dart';

class SearchProductQuery extends BaseProductQuery {
  final String? q;
  final String gender;
  final int? menuCategoryId;

  SearchProductQuery({
    this.q,
    required this.gender,
    this.menuCategoryId,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sizeIds,
    super.colorIds,
    super.brandIds,
  });

  @override
  SearchProductQuery copyWith({
    String? q,
    String? gender,
    int? menuCategoryId,
    int? page,
    int? pageSize,
    String? sortBy,
    List<int>? sizeIds,
    List<int>? colorIds,
    List<int>? brandIds,
  }) {
    return SearchProductQuery(
      q: q ?? this.q,
      gender: gender ?? this.gender,
      menuCategoryId: menuCategoryId ?? this.menuCategoryId,
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
      'gender': gender,
      if (q != null) 'q': q,
      if (menuCategoryId != null) 'menu_category_id': menuCategoryId,
    });
    return map;
  }
}
