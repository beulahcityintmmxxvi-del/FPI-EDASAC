class DepartmentModel {
  final int id;
  final String name;
  final String? code;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.name,
    this.code,
    required this.isActive,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      isActive: json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
    };
  }

  @override
  String toString() => name;
}
