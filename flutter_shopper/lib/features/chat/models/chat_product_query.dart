import 'package:flutter_shopper/core/product/models/base_product_query.dart';

class ChatProductsQuery extends BaseProductQuery {
  final List<int> productIds;

  ChatProductsQuery({
    required this.productIds,
    super.page,
    super.pageSize,
    super.sortBy,
    super.sizeIds,
    super.colorIds,
    super.brandIds,
  });

  @override
  ChatProductsQuery copyWith({
    int? page,
    int? pageSize,
    String? sortBy,
    List<int>? sizeIds,
    List<int>? colorIds,
    List<int>? brandIds,
  }) {
    return ChatProductsQuery(
      productIds: productIds,
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
    map['product_ids'] = productIds;
    return map;
  }
}
