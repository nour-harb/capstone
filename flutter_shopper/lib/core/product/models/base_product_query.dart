import 'dart:convert';
import 'package:flutter/foundation.dart';

class BaseProductQuery {
  final int page;
  final int pageSize;
  final String sortBy;
  final List<int> sizeIds;
  final List<int> colorIds;
  final List<int> brandIds;

  BaseProductQuery({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'newest',
    this.sizeIds = const [],
    this.colorIds = const [],
    this.brandIds = const [],
  });

  BaseProductQuery copyWith({
    int? page,
    int? pageSize,
    String? sortBy,
    List<int>? sizeIds,
    List<int>? colorIds,
    List<int>? brandIds,
  }) {
    return BaseProductQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sizeIds: sizeIds ?? this.sizeIds,
      colorIds: colorIds ?? this.colorIds,
      brandIds: brandIds ?? this.brandIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'sort_by': sortBy,
      if (sizeIds.isNotEmpty) 'size_ids': sizeIds,
      if (colorIds.isNotEmpty) 'color_ids': colorIds,
      if (brandIds.isNotEmpty) 'brand_ids': brandIds,
    };
  }

  factory BaseProductQuery.fromMap(Map<String, dynamic> map) {
    return BaseProductQuery(
      page: map['page'] as int? ?? 1,
      pageSize: map['page_size'] as int? ?? 20,
      sortBy: map['sort_by'] as String? ?? 'newest',
      sizeIds: List<int>.from(map['size_ids'] ?? []),
      colorIds: List<int>.from(map['color_ids'] ?? []),
      brandIds: List<int>.from(map['brand_ids'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseProductQuery.fromJson(String source) =>
      BaseProductQuery.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant BaseProductQuery other) {
    if (identical(this, other)) return true;

    return other.page == page &&
        other.pageSize == pageSize &&
        other.sortBy == sortBy &&
        listEquals(other.sizeIds, sizeIds) &&
        listEquals(other.colorIds, colorIds) &&
        listEquals(other.brandIds, brandIds);
  }

  @override
  int get hashCode {
    return page.hashCode ^
        pageSize.hashCode ^
        sortBy.hashCode ^
        sizeIds.hashCode ^
        colorIds.hashCode ^
        brandIds.hashCode;
  }
}
