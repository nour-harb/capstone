import 'dart:convert';

class CategoryModel {
  final int id;
  final String name;
  final String gender;

  CategoryModel({required this.id, required this.name, required this.gender});

  CategoryModel copyWith({int? id, String? name, String? gender}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'gender': gender};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, gender: $gender)';

  @override
  bool operator ==(covariant CategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.gender == gender;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ gender.hashCode;
}
