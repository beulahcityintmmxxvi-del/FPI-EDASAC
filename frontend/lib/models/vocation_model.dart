/// Vocation Model
/// Represents a vocational skill program

class VocationModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final bool? isActive;
  final String? icon;
  final String? durationWeeks;

  VocationModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.isActive,
    this.icon,
    this.durationWeeks,
  });

  factory VocationModel.fromJson(Map<String, dynamic> json) {
    return VocationModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['is_active'] as bool?,
      icon: json['icon']?.toString(),
      durationWeeks: json['duration_weeks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'is_active': isActive,
      'icon': icon,
      'duration_weeks': durationWeeks,
    };
  }
}
