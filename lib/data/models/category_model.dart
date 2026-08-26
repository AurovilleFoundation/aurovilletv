import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  CategoryModel copyWith({String? id, String? name}) {
    return CategoryModel(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'].toString(),
      name: (map['name'] ?? map['id'] ?? '') as String,
    );
  }

  @override
  List<Object> get props => [id, name];

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name)';
  }
}
