class FilterItem {
  final int id;
  final String name;

  FilterItem({required this.id, required this.name});

  factory FilterItem.fromMap(Map<String, dynamic> map) {
    return FilterItem(id: map['id'] as int, name: map['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
